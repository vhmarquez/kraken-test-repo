@isTest
public class MultiMock implements HttpCalloutMock {
    Map<String, String> responses;
    public MultiMock(Map<String, String> responses) {
        this.responses = responses;
    }
    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        String body = '{"error": "not found"}';
        String bestKey = null;
        for (String key : responses.keySet()) {
            if (endpoint.contains(key)) {
                if (bestKey == null || key.length() > bestKey.length()) {
                    bestKey = key;
                }
            }
        }
        if (bestKey != null) {
            body = responses.get(bestKey);
        }
        HttpResponse res = new HttpResponse();
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}
