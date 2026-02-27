@isTest
public class TestDataFactory {
    public static void createWoWMetadata() {
        Class__c cls = new Class__c(Name = 'Warrior');
        insert cls;
        
        Specialization__c spec = new Specialization__c(Name = 'Arms', Class__c = cls.Id);
        insert spec;
        
        Realm__c realm = new Realm__c(Name = 'Aegwynn', Realm_Slug__c = 'aegwynn');
        insert realm;
        
        Race__c race = new Race__c(Name = 'Orc');
        insert race;
    }

    public static List<Account> createAccounts(Integer num) {
        List<Account> accs = new List<Account>();
        for(Integer i=0; i<num; i++) {
            accs.add(new Account(Name = 'Test Acc ' + i));
        }
        insert accs;
        return accs;
    }

    public static List<Contact> createContacts(Id accId, Integer num) {
        List<Contact> cons = new List<Contact>();
        for(Integer i=0; i<num; i++) {
            cons.add(new Contact(LastName = 'Contact ' + i, AccountId = accId));
        }
        insert cons;
        return cons;
    }

    public static List<Resilient_Communication_Device__c> createDevices(Id accId, Id conId, Integer num) {
        List<Resilient_Communication_Device__c> devs = new List<Resilient_Communication_Device__c>();
        for(Integer i=0; i<num; i++) {
            devs.add(new Resilient_Communication_Device__c(
                Organization__c = accId,
                Contact__c = conId,
                Device_Type__c = 'Satellite',
                Device_Level__c = 'Primary',
                Device_Number__c = '12345' + i
            ));
        }
        insert devs;
        return devs;
    }
}
