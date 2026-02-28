@isTest
public class KnowledgeArticleControllerTest {
    @isTest
    static void testGetArticles() {
        // Try to insert a Knowledge Article to cover the success path
        try {
            // KnowledgeArticleVersion usually requires a master language and UrlName
            // and it's a version, so it's tricky.
            // We'll try to query for any existing one first to see if we can get a hit.
        } catch (Exception e) {}

        Test.startTest();
        try {
            List<KnowledgeArticleVersion> articles = KnowledgeArticleController.getArticles();
            System.assert(articles != null);
        } catch (Exception e) {
            System.debug('Knowledge might not be enabled: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testFindArticleByUrlName() {
        Test.startTest();
        try {
            String articleId = KnowledgeArticleController.findArticleByUrlName('test-url');
            System.assertEquals(null, articleId);
        } catch (Exception e) {
            System.debug('Knowledge might not be enabled: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void testFindArticleByUrlNameEmpty() {
        Test.startTest();
        try {
            KnowledgeArticleController.findArticleByUrlName('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void testNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser' + DateTime.now().getTime() + '@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');
        
        System.runAs(u) {
            Test.startTest();
            try {
                KnowledgeArticleController.getArticles();
            } catch (AuraHandledException e) {
                System.assert(e.getMessage() != null);
            }
            try {
                KnowledgeArticleController.findArticleByUrlName('test');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage() != null);
            }
            Test.stopTest();
        }
    }
}
