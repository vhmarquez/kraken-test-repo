public with sharing class KrakenDataTableController {
    @AuraEnabled(cacheable=true)
    public static DataTableResult getRecords(String objectName, String fieldList, String sortBy, String sortDirection, Integer pageNumber, Integer pageSize) {
        if (String.isBlank(objectName) || String.isBlank(fieldList)) {
            throw new AuraHandledException('Object or fields not specified.');
        }

        String safeObjectName = String.escapeSingleQuotes(objectName);
        List<String> fields = fieldList.split(',');
        String safeFields = '';
        for (String field : fields) {
            safeFields += String.escapeSingleQuotes(field.trim()) + ', ';
        }
        safeFields = safeFields.removeEnd(', ');

        String safeSortBy = sortBy != null ? String.escapeSingleQuotes(sortBy) : 'Id';
        String safeSortDirection = sortDirection == 'desc' ? 'DESC' : 'ASC';

        Integer offset = (pageNumber - 1) * pageSize;

        String countQuery = 'SELECT COUNT() FROM ' + safeObjectName;
        Integer totalRecords = Database.countQuery(countQuery);

        String query = 'SELECT Id, ' + safeFields + ' FROM ' + safeObjectName +
                       ' ORDER BY ' + safeSortBy + ' ' + safeSortDirection +
                       ' LIMIT :pageSize OFFSET :offset';

        List<sObject> records = Database.query(query);

        return new DataTableResult(records, totalRecords);
    }

    @AuraEnabled
    public static void updateRecords(String objectName, List<Map<String, Object>> records) {
        if (String.isBlank(objectName) || records == null || records.isEmpty()) {
            throw new AuraHandledException('Invalid input for update.');
        }

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            throw new AuraHandledException('Invalid object name.');
        }

        List<sObject> toUpdate = new List<sObject>();
        for (Map<String, Object> recMap : records) {
            sObject obj = objType.newSObject((Id)recMap.get('Id'));
            for (String field : recMap.keySet()) {
                if (field != 'Id') {
                    obj.put(field, recMap.get(field));
                }
            }
            toUpdate.add(obj);
        }

        try {
            update toUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldOption> getFieldOptions(String objectName) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Object name not specified.');
        }

        String safeObjectName = String.escapeSingleQuotes(objectName);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get(safeObjectName)
            ?.getDescribe()
            .fields
            .getMap();

        if (fieldMap == null) {
            throw new AuraHandledException('Invalid object name.');
        }

        List<FieldOption> fieldOptions = new List<FieldOption>();
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
            if (field.isAccessible()) {
                fieldOptions.add(new FieldOption(field.getLabel(), field.getName()));
            }
        }
        fieldOptions.sort();
        return fieldOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectOption> getObjectOptions() {
        List<ObjectOption> objectOptions = new List<ObjectOption>();
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult describe = sObjectType.getDescribe();
            if (describe.isAccessible() && describe.isQueryable()) {
                objectOptions.add(new ObjectOption(describe.getLabel(), describe.getName()));
            }
        }
        objectOptions.sort();
        return objectOptions;
    }

    @AuraEnabled
    public static Id saveConfig(String displayName, String objectName, String selectedFields) {
        if (String.isBlank(displayName) || String.isBlank(objectName) || String.isBlank(selectedFields)) {
            throw new AuraHandledException('All fields are required.');
        }

        KrakenDataTableConfig__c config = new KrakenDataTableConfig__c(
            DisplayName__c = displayName,
            ObjectApiName__c = objectName,
            SelectedFields__c = selectedFields
        );
        insert config;
        return config.Id;
    }

    @AuraEnabled
    public static void updateConfig(String configId, String displayName, String objectName, String selectedFields) {
        if (String.isBlank(configId) || String.isBlank(displayName) || String.isBlank(objectName) || String.isBlank(selectedFields)) {
            throw new AuraHandledException('All fields are required.');
        }

        KrakenDataTableConfig__c config = new KrakenDataTableConfig__c(
            Id = configId,
            DisplayName__c = displayName,
            ObjectApiName__c = objectName,
            SelectedFields__c = selectedFields
        );
        update config;
    }

    @AuraEnabled
    public static void deleteConfig(String configId) {
        if (String.isBlank(configId)) {
            throw new AuraHandledException('Config Id not specified.');
        }

        KrakenDataTableConfig__c config = new KrakenDataTableConfig__c(Id = configId);
        delete config;
    }

    @AuraEnabled(cacheable=true)
    public static KrakenDataTableConfig__c getConfig(String configId) {
        if (String.isBlank(configId)) {
            throw new AuraHandledException('Config Id not specified.');
        }

        return [SELECT ObjectApiName__c, SelectedFields__c FROM KrakenDataTableConfig__c WHERE Id = :configId LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static List<KrakenDataTableConfig__c> getAllConfigs() {
        return [SELECT Id, DisplayName__c, ObjectApiName__c, SelectedFields__c FROM KrakenDataTableConfig__c ORDER BY DisplayName__c ASC];
    }

    public class DataTableResult {
        @AuraEnabled public List<sObject> records;
        @AuraEnabled public Integer totalRecords;

        public DataTableResult(List<sObject> records, Integer totalRecords) {
            this.records = records;
            this.totalRecords = totalRecords;
        }
    }

    public class FieldOption implements Comparable {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public FieldOption(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public Integer compareTo(Object other) {
            FieldOption otherOption = (FieldOption) other;
            return this.label.compareTo(otherOption.label);
        }
    }

    public class ObjectOption implements Comparable {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public ObjectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public Integer compareTo(Object other) {
            ObjectOption otherOption = (ObjectOption) other;
            return this.label.compareTo(otherOption.label);
        }
    }
}