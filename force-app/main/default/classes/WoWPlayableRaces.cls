public with sharing class WoWPlayableRaces {
    
    public static void createPlayableRaces(){

        String getRaces = WoWDataAPI.fetchPlayableRaces();
        RacesIndexObject raceIndex = (RacesIndexObject) JSON.deserialize(getRaces.replaceAll('_links', 'links'), RacesIndexObject.class);

        List<Race__c> races = new List<Race__c>();
        for(RacesIndexObject.races race : raceIndex.races){
            races.add(new Race__c(Name=race.name));
        }

        try{
            if(Schema.sObjectType.Race__c.isCreateable()
            && Schema.sObjectType.Race__c.isUpdateable()){
                upsert races;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred when trying to upsert Races: ' + e.getMessage());
        }
    }
}