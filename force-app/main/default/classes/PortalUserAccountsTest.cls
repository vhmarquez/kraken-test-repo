@isTest
private class PortalUserAccountsTest {
    
    @isTest
    public static void getAccountSuccess() {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        insert contact;
        
        Account account = new Account();
        account.Name = 'Test Account';
        account.DAO_Primary_Admin__c = contact.Id;
        insert account;
        
        List<Account> userDAOOrgs = PortalUserAccounts.getUserAccounts(contact.Id);
        System.assert(userDAOOrgs != null, 'User is DAO of an Org.');
    }
    
    @isTest
    public static void getAccountFail() {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        insert contact;
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        List<Account> userDAOOrgs = PortalUserAccounts.getUserAccounts(contact.Id);
        System.debug(userDAOOrgs);
        System.assert(userDAOORgs.size() == 0, 'User is not DAO of any Org.');
        
    }
    
    @isTest
    public static void getAccountSuccessMultiple() {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        insert contact;
        
        List<Account> accounts = new List<Account>();
        
        Account account = new Account();
        account.Name = 'Test Account';
        account.DAO_Primary_Admin__c = contact.Id;
        accounts.add(account);
        
        Account account1 = new Account();
        account1.Name = 'Test Account 1';
        account1.DAO_Primary_Admin__c = contact.Id;
        accounts.add(account1);
        
        insert accounts;
        
        List<Account> userDAOOrgs = PortalUserAccounts.getUserAccounts(contact.Id);
        System.assert(userDAOOrgs.size() > 1, 'User is DAO of multiple Orgs');
    }
    
}