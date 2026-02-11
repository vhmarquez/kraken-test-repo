public with sharing class WoWProfileAPI {
    
    public static String fetchRealmIndex(){
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Profile_API/data/wow/realm/index?locale=en_US&namespace=dynamic-us');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWProfileAPI.fetchRealmIndex()');
    }

    public static String fetchCharacterProfileSummary(String realmSlug, String characterName){

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Profile_API/profile/wow/character/'+realmSlug+'/'+characterName.toLowerCase()+'?namespace=profile-us');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWProfileAPI.fetchCharacterProfileSummary()');
    }

    public static String fetchCharacterMediaSummary(String realmSlug, String characterName){

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Profile_API/profile/wow/character/'+realmSlug+'/'+characterName.toLowerCase()+'/character-media?namespace=profile-us&locale=en_US');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWProfileAPI.fetchCharacterMediaSummary()' );
    }

    public static String fetchCharacterEquipmentSummary(String realmSlug, String characterName){

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:US_Profile_API/profile/wow/character/'+realmSlug+'/'+characterName.toLowerCase()+'/equipment?namespace=profile-us&locale=en_US');
        request.setMethod('GET');
        
        return UtilityMethods.callRetry(request, 'WoWProfileAPI.fetchCharacterEquipmentSummary()' );
    }
}