public with sharing class WoWRealms {

    public static void createAllRealms() {

        String getRealms = WoWProfileAPI.fetchRealmIndex();
        RealmIndexObject realmIndex = (RealmIndexObject) JSON.deserialize(getRealms.replaceAll('_links', 'links'), RealmIndexObject.class);
        
        List<Realm__c> realms = new List<Realm__c>();
        for(RealmIndexObject.realms realm : realmIndex.realms){
            realms.add(new Realm__c(Realm_ID__c=realm.id, Name=realm.name, Realm_Slug__c=realm.slug));
        }

        try{
            if(Schema.sObjectType.Realm__c.isCreateable()
            && Schema.sObjectType.Realm__c.isUpdateable()){
                upsert realms;
            }
        } catch(DmlException e){
            System.debug('The following exception has occurred when trying to upsert Realms: ' + e.getMessage());
        }
    }
}