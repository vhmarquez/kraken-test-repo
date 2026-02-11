@IsTest
private class ChatterFeedControllerTest {
    @TestSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        FeedItem parentPost = new FeedItem(
            ParentId = testAccount.Id,
            Body = 'Test Body',
            IsRichText = true
        );
        insert parentPost;

        FeedItem replyPost = new FeedItem(
            ParentId = parentPost.Id,
            Body = 'Reply Body',
            IsRichText = true
        );
        insert replyPost;

        ConnectApi.ChatterFeeds.likeFeedElement(null, parentPost.Id);
    }

    @IsTest
    static void testGetFeedItems() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<FeedItem> items = ChatterFeedController.getFeedItems(acc.Id);
        Test.stopTest();
        System.assertEquals(2, items.size(), 'Should return parent and reply');
        System.assert(items[0].FeedLikes.size() > 0, 'Should have likes');
    }

    @IsTest
    static void testCreateFeedItemWithMention() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String bodyWithMention = 'Test with @[' + UserInfo.getUserId() + ']';
        Test.startTest();
        ChatterFeedController.createFeedItem(acc.Id, bodyWithMention);
        Test.stopTest();
        
        List<FeedItem> items = [SELECT Id FROM FeedItem WHERE ParentId = :acc.Id];
        System.assertEquals(2, items.size(), 'Should create new item with mention');
    }

    @IsTest
    static void testLikeAndUnlikeFeedItem() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        FeedItem parent = [SELECT Id FROM FeedItem WHERE ParentId = :acc.Id LIMIT 1];
        Test.startTest();
        ChatterFeedController.likeFeedItem(parent.Id);
        Test.stopTest();
        
        List<FeedItem> items = [SELECT Id, (SELECT Id FROM FeedLikes) FROM FeedItem WHERE Id = :parent.Id];
        System.assertEquals(2, items[0].FeedLikes.size(), 'Should add a like');

        Test.startTest();
        ChatterFeedController.unlikeFeedItem(parent.Id);
        Test.stopTest();
        
        items = [SELECT Id, (SELECT Id FROM FeedLikes) FROM FeedItem WHERE Id = :parent.Id];
        System.assertEquals(1, items[0].FeedLikes.size(), 'Should remove the like');
    }

    @IsTest
    static void testCreateFeedItemFailure() {
        Test.startTest();
        try {
            ChatterFeedController.createFeedItem(null, 'Invalid');
            System.assert(false, 'Expected an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Failed to post comment'), 'Expected error message');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetFeedItemsFailure() {
        Test.startTest();
        try {
            ChatterFeedController.getFeedItems(null);
            System.assert(false, 'Expected an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Failed to load feed'), 'Expected error message');
        }
        Test.stopTest();
    }
}