@isTest
public class WoWPlayableClassesTest {
    @isTest
    static void testCreatePlayableClasses() {
        String mockBody = '{"classes": [{"id": 1, "name": "Warrior"}]}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', mockBody, new Map<String, String>()));
        
        Test.startTest();
        WoWPlayableClasses.createPlayableClasses();
        Test.stopTest();
        
        System.assert([SELECT Id FROM Class__c].size() > 0);
    }

    @isTest
    static void testCreatePlayableClassSpecs() {
        insert new Class__c(Name = 'Warrior', Class_ID__c = 1);
        String mockBody = '{"specializations": [{"id": 1, "name": "Arms"}]}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', mockBody, new Map<String, String>()));
        
        Test.startTest();
        WoWPlayableClasses.createPlayableClassSpecs();
        Test.stopTest();
        
        System.assert([SELECT Id FROM Specialization__c].size() > 0);
    }
}
