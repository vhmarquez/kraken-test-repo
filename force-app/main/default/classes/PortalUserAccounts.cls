public with sharing class PortalUserAccounts {

    @AuraEnabled(cacheable=true)
    public static List<Account> getUserAccounts(Id contactId){
        List<Account> userAccounts = [SELECT Id, Name FROM Account WHERE DAO_Primary_Admin__c = :contactId];
        return userAccounts;
    }
    
}