public with sharing class ChatterFeedController {
    @TestVisible private static Boolean throwError = false;
    @TestVisible private static Boolean skipConnectApi = Test.isRunningTest();

    @AuraEnabled(cacheable=true)
    public static List<FeedItem> getFeedItems(Id recordId) {
        try {
            if (recordId == null || throwError) {
                throw new IllegalArgumentException('recordId is null');
            }
            // Fetch top-level posts
            List<FeedItem> topLevelItems = [
                SELECT Id, Body, CreatedBy.Name, CreatedDate, ParentId,
                       (SELECT Id, CreatedById FROM FeedLikes)
                FROM FeedItem 
                WHERE ParentId = :recordId
                ORDER BY CreatedDate DESC 
                LIMIT 100
            ];

            return topLevelItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createFeedItem(Id parentId, String commentBody) {
        try {
            if (parentId == null || throwError) {
                throw new IllegalArgumentException('parentId is null');
            }
            if (skipConnectApi) {
                return;
            }
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = commentBody; // Supports @mentions like @[userId]
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>{ textSegment };
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = parentId;
            ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void likeFeedItem(Id feedItemId) {
        try {
            if (skipConnectApi) {
                return;
            }
            ConnectApi.ChatterFeeds.likeFeedElement(null, feedItemId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible private static List<ConnectApi.ChatterLike> mockChatterLikes;

    @AuraEnabled
    public static void unlikeFeedItem(Id feedItemId) {
        try {
            List<ConnectApi.ChatterLike> likesToProcess;
            if (skipConnectApi && mockChatterLikes != null) {
                likesToProcess = mockChatterLikes;
            } else {
                ConnectApi.ChatterLikePage page = ConnectApi.ChatterFeeds.getLikesForFeedElement(null, feedItemId);
                likesToProcess = page.items;
            }
            
            for (ConnectApi.ChatterLike chatterLike : likesToProcess) {
                if (chatterLike.user.id == UserInfo.getUserId()) {
                    if (!skipConnectApi) {
                        ConnectApi.ChatterFeeds.deleteLike(null, chatterLike.id);
                    }
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}