public with sharing class CursorContacts {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Integer pageSize, Integer page) {
        
        Database.Cursor cursor = Database.getCursor('SELECT Id, Name, Email, CreatedDate, Status__c, Role__c FROM Contact WITH USER_MODE');

        Integer totalRecordCount = cursor.getNumRecords();
        Integer currentRecordCount = pageSize * page;
        
        Integer offset = totalRecordCount - currentRecordCount;
        if(offset < pageSize){
            pageSize = offset;
        }

        List<Contact> scope = cursor.fetch(currentRecordCount, pageSize);
        if(scope.size() > 0){
            return scope;
        } else {
            return null;
        }

    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalContacts(){
        
        // Database.Cursor cursor = Database.getCursor('SELECT Id FROM Contact WITH USER_MODE');

        // return cursor.getNumRecords();
        return [SELECT Count() FROM Contact WITH USER_MODE];
    
    }

}