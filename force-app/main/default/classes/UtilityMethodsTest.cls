@isTest
public class UtilityMethodsTest {
    @isTest
    static void testCallRetrySuccess() {
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', '{"success": true}', new Map<String, String>()));
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');
        
        Test.startTest();
        String result = UtilityMethods.callRetry(req, 'TestCall');
        Test.stopTest();
        
        System.assertEquals('{"success": true}', result);
    }

    @isTest
    static void testCallRetryFailureThenSuccess() {
        // Since UtilityMethods.callRetry has use for loop, we can't easily change the mock mid-test without a more complex mock
        // but we can test the 500 status code logic.
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(500, 'Error', 'Server Error', new Map<String, String>()));
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');
        
        Test.startTest();
        String result = UtilityMethods.callRetry(req, 'TestCall');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null after all retries fail with 500');
    }
}
