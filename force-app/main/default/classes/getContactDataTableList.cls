public with sharing class getContactDataTableList {

    // @AuraEnabled(cacheable=true)
    // public static Map<String, List<Contact>> getList(Integer limitNumber){

    //     limitNumber = 5;
    //     String queryString = 'SELECT Id, Name, Role__c, Email, CreatedDate, Status__c FROM Contact WITH SECURITY_ENFORCED';
    //     Map<String, List<Contact>> pageRecords = new Map<String, List<Contact>>();
    //     List<Contact> contacts = new List<Contact>();
    //     try {
        
    //         contacts = Database.query(queryString);
    //         System.debug(contacts);
        
    //     } catch (QueryException e) {
        
    //         system.debug('Query Exception: ' + e.getMessage());
        
    //     }

    //     Integer page = 1;
    //     List<Contact> contactRecords = new List<Contact>();
    //     Integer recordCount = 0;
    //     for(Contact con : contacts){
    //         if(recordCount == (limitNumber)){
    //             pageRecords.put('page_' + page, contactRecords.clone());
    //             page++;
    //             recordCount = 0;
    //             contactRecords.clear();
    //         }
            
    //         contactRecords.add(con);
    //         recordCount++;
    //     }

    //     System.debug('All Page Records: ' + pageRecords);
        
    //     return pageRecords;
    // }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getList(Integer limitNumber){

        limitNumber = 5;
        String queryString = 'SELECT Id, Name, Role__c, Email, CreatedDate, Status__c FROM Contact WITH SECURITY_ENFORCED';
        List<Contact> contacts = new List<Contact>();
        try {
        
            contacts = Database.query(queryString);
            System.debug(contacts);
        
        } catch (QueryException e) {
        
            system.debug('Query Exception: ' + e.getMessage());
        
        }
        
        return contacts;
    }

}