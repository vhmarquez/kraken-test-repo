@isTest
public class WoWPlayableRaceClassCombinationTest {
    @isTest
    static void testCreateCombinations() {
        insert new Class__c(Name = 'Warrior', Class_ID__c = 1);
        insert new Race__c(Name = 'Orc');
        
        String mockBody = '{"playable_races": [{"id": 1, "name": "Orc"}]}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', mockBody, new Map<String, String>()));
        
        Test.startTest();
        WoWPlayableRaceClassCombination.createRaceClassCombinations();
        Test.stopTest();
        
        System.assert([SELECT Id FROM ClassRace__c].size() > 0);
    }
}
