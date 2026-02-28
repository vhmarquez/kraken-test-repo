@isTest
public class WoWDataAPITest {
    @isTest
    static void testFetchMethods() {
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', '{"id": 1}', new Map<String, String>()));
        
        Test.startTest();
        String races = WoWDataAPI.fetchPlayableRaces();
        String classIndex = WoWDataAPI.fetchPlayableClassIndex();
        String playableClass = WoWDataAPI.fetchPlayableClass(1);
        String media = WoWDataAPI.fetchItemMedia(1);
        Test.stopTest();
        
        System.assertEquals('{"id": 1}', races);
        System.assertEquals('{"id": 1}', classIndex);
        System.assertEquals('{"id": 1}', playableClass);
        System.assertEquals('{"id": 1}', media);
    }
}
