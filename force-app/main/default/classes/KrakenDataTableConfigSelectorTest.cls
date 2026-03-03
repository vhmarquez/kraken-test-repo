@isTest
public class KrakenDataTableConfigSelectorTest {
    @isTest
    static void testSelector() {
        KrakenDataTableConfig__c config = new KrakenDataTableConfig__c(
            DisplayName__c = 'Test Config',
            ObjectApiName__c = 'Account',
            SelectedFields__c = 'Name,Id'
        );
        insert config;

        KrakenDataTableConfigSelector selector = new KrakenDataTableConfigSelector();
        
        Test.startTest();
        VisualEditor.DataRow defaultValue = selector.getDefaultValue();
        VisualEditor.DynamicPickListRows values = selector.getValues();
        Test.stopTest();

        System.assertEquals(null, defaultValue);
        System.assertNotEquals(0, values.size());
    }
}
