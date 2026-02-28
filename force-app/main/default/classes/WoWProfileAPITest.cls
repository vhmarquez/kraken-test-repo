@isTest
public class WoWProfileAPITest {
    @isTest
    static void testFetchMethods() {
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', '{"id": 1}', new Map<String, String>()));
        
        Test.startTest();
        String index = WoWProfileAPI.fetchRealmIndex();
        String profile = WoWProfileAPI.fetchCharacterProfileSummary('test', 'test');
        String media = WoWProfileAPI.fetchCharacterMediaSummary('test', 'test');
        String equip = WoWProfileAPI.fetchCharacterEquipmentSummary('test', 'test');
        Test.stopTest();
        
        System.assertEquals('{"id": 1}', index);
        System.assertEquals('{"id": 1}', profile);
    }
}
