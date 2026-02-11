public with sharing class UtilityMethods {
    
    public static String callRetry(HttpRequest request, String callName) {
        
        Http http = new Http();
        HttpResponse response;
        for(Integer i = 0; i < 3; i++){
            try{
                response = http.send(request);
                if(response.getStatusCode() != 500) {
                    System.debug(response.getBody());
                    return response.getBody();
                }
            } catch(Exception e){
                System.debug('callRetry: Http request' + callName + 'failed on attempt ' + i + ': ' + e.getMessage());
                continue;
            }
        }
        return null;
    }
}