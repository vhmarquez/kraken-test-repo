@isTest
public class WoWPlayableRacesTest {
    @isTest
    static void testCreatePlayableRaces() {
        String mockBody = '{"races": [{"id": 1, "name": "Orc"}]}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', mockBody, new Map<String, String>()));
        
        Test.startTest();
        WoWPlayableRaces.createPlayableRaces();
        Test.stopTest();
        
        List<Race__c> races = [SELECT Id FROM Race__c];
        System.assert(races.size() > 0);
    }
}
