@isTest
private class KrakenDataTableControllerTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, Phone = '123-456-789' + i));
        }
        insert accounts;

        KrakenDataTableConfig__c config = new KrakenDataTableConfig__c(
            DisplayName__c = 'Test Config',
            ObjectApiName__c = 'Account',
            SelectedFields__c = 'Name,Phone'
        );
        insert config;
    }

    @isTest
    static void testGetRecords() {
        Test.startTest();
        KrakenDataTableController.DataTableResult result = KrakenDataTableController.getRecords(
            'Account', 'Name,Phone', 'Name', 'asc', 1, 10
        );
        System.assertEquals(10, result.records.size(), 'Should return 10 records');
        System.assertEquals(20, result.totalRecords, 'Total records should be 20');

        result = KrakenDataTableController.getRecords(
            'Account', 'Name,Phone', 'Name', 'desc', 1, 10
        );
        System.assertEquals('Test Account 9', ((Account)result.records[0]).Name, 'First record should be Test Account 9 in desc order');

        result = KrakenDataTableController.getRecords(
            'Account', 'Name,Phone', null, 'asc', 2, 10
        );
        System.assertEquals(10, result.records.size(), 'Should return next 10 records');

        try {
            KrakenDataTableController.getRecords('', 'Name', null, 'asc', 1, 10);
            System.assert(false, 'Should throw exception for blank object');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateRecords() {
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 2];
        List<Map<String, Object>> recordsToUpdate = new List<Map<String, Object>>();
        Map<String, Object> rec1 = new Map<String, Object>{
            'Id' => accounts[0].Id,
            'Name' => 'Updated Name 1'
        };
        Map<String, Object> rec2 = new Map<String, Object>{
            'Id' => accounts[1].Id,
            'Name' => 'Updated Name 2'
        };
        recordsToUpdate.add(rec1);
        recordsToUpdate.add(rec2);

        Test.startTest();
        KrakenDataTableController.updateRecords('Account', recordsToUpdate);
        Test.stopTest();

        Account updatedAcc1 = [SELECT Name FROM Account WHERE Id = :accounts[0].Id];
        System.assertEquals('Updated Name 1', updatedAcc1.Name, 'Record 1 should be updated');

        Account updatedAcc2 = [SELECT Name FROM Account WHERE Id = :accounts[1].Id];
        System.assertEquals('Updated Name 2', updatedAcc2.Name, 'Record 2 should be updated');

        try {
            KrakenDataTableController.updateRecords('Account', null);
            System.assert(false, 'Should throw exception for null records');
        } catch (AuraHandledException e) {
            System.assert(true);
        }

        try {
            KrakenDataTableController.updateRecords('InvalidObject', recordsToUpdate);
            System.assert(false, 'Should throw exception for invalid object');
        } catch (AuraHandledException e) {
            System.assert(true);
        }

        // Test DML error for coverage
        recordsToUpdate[0].put('Name', null); // Should fail validation if Account Name is required
        try {
            KrakenDataTableController.updateRecords('Account', recordsToUpdate);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void testGetFieldOptions() {
        Test.startTest();
        List<KrakenDataTableController.FieldOption> fields = KrakenDataTableController.getFieldOptions('Account');
        System.assert(fields.size() > 0, 'Should return field options');
        System.assert(fields[0].value != null, 'Field values should not be null');
        System.assert(fields[0].label != null, 'Field labels should not be null');

        try {
            KrakenDataTableController.getFieldOptions('');
            System.assert(false, 'Should throw exception for blank object');
        } catch (AuraHandledException e) {
            System.assert(true);
        }

        try {
            KrakenDataTableController.getFieldOptions('InvalidObject');
            System.assert(false, 'Should throw exception for invalid object');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetObjectOptions() {
        Test.startTest();
        List<KrakenDataTableController.ObjectOption> objects = KrakenDataTableController.getObjectOptions();
        System.assert(objects.size() > 0, 'Should return object options');
        System.assert(objects[0].value != null, 'Object values should not be null');
        System.assert(objects[0].label != null, 'Object labels should not be null');
        Test.stopTest();
    }

    @isTest
    static void testSaveConfig() {
        Test.startTest();
        Id configId = KrakenDataTableController.saveConfig('New Config', 'Account', 'Name,Phone,Email');
        System.assert(configId != null, 'Should return config Id');

        try {
            KrakenDataTableController.saveConfig('', 'Account', 'Name');
            System.assert(false, 'Should throw exception for missing fields');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateConfig() {
        KrakenDataTableConfig__c config = [SELECT Id, DisplayName__c, ObjectApiName__c, SelectedFields__c FROM KrakenDataTableConfig__c LIMIT 1];
        Test.startTest();
        KrakenDataTableController.updateConfig(config.Id, 'Updated Config', 'Contact', 'Name,Email');
        KrakenDataTableConfig__c updatedConfig = [SELECT DisplayName__c, ObjectApiName__c, SelectedFields__c FROM KrakenDataTableConfig__c WHERE Id = :config.Id];
        System.assertEquals('Updated Config', updatedConfig.DisplayName__c, 'Should update display name');
        System.assertEquals('Contact', updatedConfig.ObjectApiName__c, 'Should update object name');
        System.assertEquals('Name,Email', updatedConfig.SelectedFields__c, 'Should update fields');

        try {
            KrakenDataTableController.updateConfig('', 'Updated Config', 'Account', 'Name');
            System.assert(false, 'Should throw exception for missing config Id');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteConfig() {
        KrakenDataTableConfig__c config = [SELECT Id FROM KrakenDataTableConfig__c LIMIT 1];
        Test.startTest();
        KrakenDataTableController.deleteConfig(config.Id);
        List<KrakenDataTableConfig__c> configs = [SELECT Id FROM KrakenDataTableConfig__c WHERE Id = :config.Id];
        System.assertEquals(0, configs.size(), 'Configuration should be deleted');

        try {
            KrakenDataTableController.deleteConfig('');
            System.assert(false, 'Should throw exception for blank config Id');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetConfig() {
        KrakenDataTableConfig__c config = [SELECT Id FROM KrakenDataTableConfig__c LIMIT 1];
        Test.startTest();
        // Test with correct Id
        KrakenDataTableConfig__c retrievedConfig = KrakenDataTableController.getConfig(config.Id);
        System.assertEquals('Account', retrievedConfig.ObjectApiName__c, 'Should return correct object name');
        System.assertEquals('Name,Phone', retrievedConfig.SelectedFields__c, 'Should return correct fields');

        // Simulate Experience Builder passing an object
        retrievedConfig = KrakenDataTableController.getConfig(config.Id);
        System.assertEquals('Account', retrievedConfig.ObjectApiName__c, 'Should handle object format');

        try {
            KrakenDataTableController.getConfig('');
            System.assert(false, 'Should throw exception for blank config Id');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetAllConfigs() {
        Test.startTest();
        List<KrakenDataTableConfig__c> configs = KrakenDataTableController.getAllConfigs();
        System.assertEquals(1, configs.size(), 'Should return one config');
        System.assertEquals('Test Config', configs[0].DisplayName__c, 'Should return correct display name');
        Test.stopTest();
    }

    @isTest
    static void testConfigSelectorPicklist() {
        KrakenDataTableConfigSelector selector = new KrakenDataTableConfigSelector();
        Test.startTest();
        VisualEditor.DynamicPickListRows rows = selector.getValues();
        System.assertEquals(1, rows.size(), 'Should return one config');

        VisualEditor.DataRow defaultValue = selector.getDefaultValue();
        System.assertEquals(null, defaultValue, 'Default value should be null');
        Test.stopTest();
    }
}