public with sharing class WoWPlayableClasses {
    
    public static void createPlayableClasses(){

        String getClassIndex = WoWDataAPI.fetchPlayableClassIndex();
        ClassesIndexObject classesIndex = (ClassesIndexObject) JSON.deserialize(getClassIndex.replaceAll('_links', 'links'), ClassesIndexObject.class);

        List<Class__c> classes = new List<Class__c>();
        for(ClassesIndexObject.classes c : classesIndex.classes){
            classes.add(new Class__c(Name=c.name, Class_ID__c=c.id));
        }

        try{
            if(Schema.sObjectType.Class__c.isCreateable()
            && Schema.sObjectType.Class__c.isUpdateable()){
                upsert classes;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred when trying to upsert a Character Class: ' + e.getMessage());
        }
    }

    public static void createPlayableClassSpecs(){
        
        List<Class__c> playableClasses = [SELECT Id, Name, Class_ID__c FROM Class__c];

        List<Specialization__c> specialization = new List<Specialization__c>();
        for(Class__c c : playableClasses){
            String getClass = WoWDataAPI.fetchPlayableClass(c.Class_ID__c);
            ClassObject playableClass = (ClassObject) JSON.deserialize(getClass.replaceAll('_links', 'links'), ClassObject.class);

            for(ClassObject.specializations spec : playableClass.specializations){
                specialization.add(new Specialization__c(Name=spec.name, Class__c=c.Id));
            }
        }

        try{
            if(Schema.sObjectType.Specialization__c.isCreateable()
             && Schema.sObjectType.Specialization__c.isUpdateable()){
                upsert specialization;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred when trying to upsert a Specialization: ' + e.getMessage());
        }
    }
}