@isTest
public class WoWRealmsTest {
    @isTest
    static void testCreateAllRealms() {
        String mockBody = '{"realms": [{"id": 1, "name": "Aegwynn", "slug": "aegwynn"}]}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', mockBody, new Map<String, String>()));
        
        Test.startTest();
        WoWRealms.createAllRealms();
        Test.stopTest();
        
        List<Realm__c> realms = [SELECT Id FROM Realm__c];
        System.assert(realms.size() > 0);
    }
}
