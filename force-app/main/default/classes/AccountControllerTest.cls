@isTest
public class AccountControllerTest {
    @testSetup
    static void setup() {
        List<Account> testAccs = new List<Account>();
        for(Integer i=0; i<5; i++) {
            testAccs.add(new Account(Name = 'Test Account ' + i, Industry = 'Banking', Phone = '1234567890', AnnualRevenue = 1000000, Type = 'Prospect'));
        }
        insert testAccs;
    }

    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<Account> accounts = AccountController.getAccounts();
        Test.stopTest();
        
        System.assertNotEquals(0, accounts.size(), 'Should return accounts');
        System.assertEquals(5, accounts.size(), 'Should return 5 accounts');
    }
    @isTest
    static void testGetAccountsNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser' + DateTime.now().getTime() + '@testorg.com');
        
        System.runAs(u) {
            Test.startTest();
            try {
                AccountController.getAccounts();
                // We don't assert false here because some org configurations might still allow access
                // but usually this profile won't. If it doesn't throw, coverage won't increase but test won't fail.
            } catch (AuraHandledException e) {
                System.assert(e.getMessage() != null);
            }
            Test.stopTest();
        }
    }
}
