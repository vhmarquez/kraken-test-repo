public with sharing class WoWDataAPI {

    public static String fetchPlayableRaces(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Data_API/data/wow/playable-race/index?locale=en_US&namespace=static-us');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWDataAPI.fetchPlayableRaces()');
    }

    public static String fetchPlayableClassIndex(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Data_API/data/wow/playable-class/index?locale=en_US&namespace=static-us');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWDataAPI.fetchPlayableClasses()');
    }

    public static String fetchPlayableClass(Decimal classId){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Data_API/data/wow/playable-class/' + classId + '?locale=en_US&namespace=static-us');
        request.setMethod('GET');

        return UtilityMethods.callRetry(request, 'WoWDataAPI.fetchClass()');
    }
    
    public static String fetchItemMedia(Integer itemId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Data_API/data/wow/media/item/' + itemId + '?locale=en_US&namespace=static-us');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWDataAPI.fetchItemMedia()');
    }
}