public with sharing class KrakenDataTableConfigSelector extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue() {
        return null;
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows configOptions = new VisualEditor.DynamicPickListRows();
        List<KrakenDataTableConfig__c> configs = [SELECT Id, DisplayName__c FROM KrakenDataTableConfig__c ORDER BY DisplayName__c ASC];
        for (KrakenDataTableConfig__c config : configs) {
            configOptions.addRow(new VisualEditor.DataRow(config.DisplayName__c, config.Id));
        }
        return configOptions;
    }
}