public with sharing class WoWPlayableRaceClassCombination {

    public static void createRaceClassCombinations() {
        List<Class__c> playableClasses = [SELECT Id, Name, Class_ID__c FROM Class__c];
        List<Race__c> playableRaces = [SELECT Id, Name FROM Race__c];

        List<ClassRace__c> raceClasses = new List<ClassRace__c>();
        for(Class__c c : playableClasses){

            String getClass = WoWDataAPI.fetchPlayableClass(c.Class_ID__c);
            ClassObject playableClass = (ClassObject) JSON.deserialize(getClass.replaceAll('_links', 'links'), ClassObject.class);

            for(ClassObject.playable_races race : playableClass.playable_races){
                
                Race__c playableRaceRecord;
                for(Race__c raceRecord : playableRaces){
                    if(raceRecord.Name == race.name){
                        playableRaceRecord = raceRecord;
                    }
                }
                raceClasses.add(new ClassRace__c(Class__c=c.Id, Race__c=playableRaceRecord.Id));
            }
        }

        try{
            if(Schema.sObjectType.ClassRace__c.isCreateable()
            && Schema.sObjectType.ClassRace__c.isUpdateable()){
                upsert raceClasses;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred when trying to upsert a ClassRace Combination: ' + e.getMessage());
        }
    }
}