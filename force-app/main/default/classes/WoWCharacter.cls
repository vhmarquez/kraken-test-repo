public with sharing class WoWCharacter {

    public static void createCharacterLead(String realmSlug, String characterName) {

        String characterProfile = WoWProfileAPI.fetchCharacterProfileSummary(realmSlug, characterName);
        CharacterProfileSummaryObject characterProfileObject = (CharacterProfileSummaryObject) JSON.deserialize(characterProfile.replaceAll('_links', 'links'), CharacterProfileSummaryObject.class);
        
        Id classId = [SELECT Id FROM Class__c WHERE Name =: characterProfileObject.character_class.name.en_US LIMIT 1].Id;
        Id specId = [SELECT Id FROM Specialization__c WHERE Class__c =: classId AND Name =: characterProfileObject.active_spec.name.en_US LIMIT 1].Id;
        Id realmId = [SELECT Id FROM Realm__c WHERE Name =: characterProfileObject.realm.name.en_US LIMIT 1].Id;
        Id raceId = [SELECT Id FROM Race__c WHERE Name =: characterProfileObject.race.name.en_US.escapeJava() LIMIT 1].Id;

        Lead characterLead = new Lead(
            LastName=characterName.capitalize(),
            Company='WoW API',
            Realm__c=realmId,
            Faction__c=characterProfileObject.faction.name.en_US,
            Class__c=classId,
            Main_Spec__c=SpecId,
            Level__c=characterProfileObject.level,
            Item_Level__c=characterProfileObject.equipped_item_level,
            Race__c=raceId
        );

        try{
            if(Schema.SObjectType.Lead.isCreateable()
            && Schema.SObjectType.Lead.isUpdateable()){
                upsert characterLead;
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred when trying to upsert a Character Lead: ' + e.getMessage());
        }
    }

    // public static void createCharacterApplicant(Id realmId, String characterName) {

    //     String realmSlug = [SELECT Id, Realm_Slug__c FROM Realm__c WHERE Id =: realmId].Realm_Slug__c;
    //     characterName = characterName.toLowerCase();

    //     String characterProfile = WoWProfileAPI.fetchCharacterProfileSummary(realmSlug, characterName);
    //     CharacterProfileSummaryObject characterProfileObject = (CharacterProfileSummaryObject) JSON.deserialize(characterProfile.replaceAll('_links', 'links'), CharacterProfileSummaryObject.class);

    //     Id classId = [SELECT Id FROM Class__c WHERE Name =: characterProfileObject.character_class.name.en_US LIMIT 1].Id;
    //     Id specId = [SELECT Id FROM Specialization__c WHERE Class__c =: classId AND Name =: characterProfileObject.active_spec.name.en_US LIMIT 1].Id;
    //     Id raceId = [SELECT Id FROM Race__c WHERE Name =: characterProfileObject.race.name.en_US.escapeJava() LIMIT 1].Id;

    //     Guild_Applicant__c characterApplicant = new Guild_Applicant__c(
    //         Name=characterName.capitalize(),
    //         Realm__c=realmId,
    //         Faction__c=characterProfileObject.faction.name.en_US,
    //         Class__c=classId,
    //         Main_Spec__c=SpecId,
    //         Level__c=characterProfileObject.level,
    //         Item_Level__c=characterProfileObject.equipped_item_level,
    //         Race__c=raceId,
    //         Title__c=characterProfileObject.active_title.name.en_US
    //     );

    //     try{
    //         if(Schema.SObjectType.Lead.isCreateable()
    //         && Schema.SObjectType.Lead.isUpdateable()){
    //             upsert characterApplicant;
    //         }
    //     } catch (DmlException e) {
    //         System.debug('The following exception has occurred when trying to upsert a Character Lead: ' + e.getMessage());
    //     }
    // }

    @InvocableMethod(Label='Wow Character' Description='Creates a new Character Lead from the WoW Profile API')
    public static List<SObject> createCharacterApplicant(List<List<String>> args){

        String realmSlug = args[0][0];
        String characterName = args[0][1].toLowerCase();
        String recordId = args[0][2];

        String characterProfile = WoWProfileAPI.fetchCharacterProfileSummary(realmSlug, characterName);
        CharacterProfileSummaryObject characterProfileObject = (CharacterProfileSummaryObject) JSON.deserialize(characterProfile.replaceAll('_links', 'links'), CharacterProfileSummaryObject.class);

        Id classId = [SELECT Id FROM Class__c WHERE Name =: characterProfileObject.character_class.name.en_US LIMIT 1].Id;
        Id specId = [SELECT Id FROM Specialization__c WHERE Class__c =: classId AND Name =: characterProfileObject.active_spec.name.en_US LIMIT 1].Id;
        Id realmId = [SELECT Id FROM Realm__c WHERE Name =: characterProfileObject.realm.name.en_US LIMIT 1].Id;
        Id raceId = [SELECT Id FROM Race__c WHERE Name =: characterProfileObject.race.name.en_US.escapeJava() LIMIT 1].Id;

        Character_Model__c characterModel = createCharacterModel(realmSlug, characterName, characterProfileObject.id);

        List<SObject> guildApplicant = new List<SObject>();
        SObject characterApplicant = new Guild_Applicant__c(
            Id=recordId,
            Character_ID__c=characterProfileObject.id,
            Name=characterName.capitalize(),
            Realm__c=realmId,
            Faction__c=characterProfileObject.faction.name.en_US,
            Class__c=classId,
            Main_Spec__c=SpecId,
            Level__c=characterProfileObject.level,
            Item_Level__c=characterProfileObject.equipped_item_level,
            Race__c=raceId,
            Title__c=characterProfileObject.active_title.name.en_US,
            Character_Model__c=characterModel.Id
        );

        guildApplicant.add(characterApplicant);

        System.debug(guildApplicant);

        return guildApplicant;
    }

    public static Character_Model__c createCharacterModel(String realmSlug, String characterName, Integer externalId) {

        String characterMedia = WoWProfileAPI.fetchCharacterMediaSummary(realmSlug, characterName);
        String characterEquipment = WoWProfileAPI.fetchCharacterEquipmentSummary(realmSlug, characterName);

        CharacterMediaSummaryObject characterMediaObject = (CharacterMediaSummaryObject) JSON.deserialize(characterMedia.replaceAll('_links', 'links'), CharacterMediaSummaryObject.class);
        CharacterEquipmentSummaryObject characterEquipmentObject = (CharacterEquipmentSummaryObject) JSON.deserialize(characterEquipment.replaceAll('set', 'set_bonus').replaceAll('_links', 'links').replaceAll('links', 'links_extra'), CharacterEquipmentSummaryObject.class);

        Map<String,String> itemMap = mapItemNameToURL(characterEquipmentObject);

        Character_Model__c characterModel = new Character_Model__c(
            Character_ID__c=externalId,
            Name=characterName.capitalize(),
            Avatar__c=characterMediaObject.assets[0].value,
            Inset__c=characterMediaObject.assets[1].value,
            Main_Raw__c=characterMediaObject.assets[2].value,
            Head__c=itemMap.get('Head'),
            Neck__c=itemMap.get('Neck'),
            Shoulders__c=itemMap.get('Shoulders'),
            Chest__c=itemMap.get('Chest'),
            Waist__c=itemMap.get('Waist'),
            Legs__c=itemMap.get('Legs'),
            Feet__c=itemMap.get('Feet'),
            Wrist__c=itemMap.get('Wrist'),
            Hands__c=itemMap.get('Hands'),
            Finger__c=itemMap.get('Finger'),
            Finger_2__c=itemMap.get('Finger_2'),
            Trinket_1__c=itemMap.get('Trinket_1'),
            Trinket_2__c=itemMap.get('Trinket_2'),
            Back__c=itemMap.get('Back'),
            Main_Hand__c=itemMap.get('Main_Hand'),
            Off_Hand__c=itemMap.get('Off_Hand'),
            Tabard__c=itemMap.get('Tabard')
        );

        try{
            if(Schema.SObjectType.Character_Model__c.isCreateable()
            && Schema.SObjectType.Character_Model__c.isUpdateable()){
                upsert characterModel;
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred when trying to upsert a Character Model: ' + e.getMessage());
        }
        
        return characterModel;
    }

    public static Map<String,String> mapItemNameToURL(CharacterEquipmentSummaryObject characterEquipmentObject){
        Map<String,String> itemMap = new Map<String,String>();
        for(CharacterEquipmentSummaryObject.equipped_items item : characterEquipmentObject.equipped_items){
            switch on item.slot.name {
                when 'Head' {
                    itemMap.put('Head', getItemMediaURL(item.item.id));
                }
                when 'Neck' {
                    itemMap.put('Neck', getItemMediaURL(item.item.id));
                }
                when 'Shoulders' {
                    itemMap.put('Shoulders', getItemMediaURL(item.item.id));
                }
                when 'Chest' {
                    itemMap.put('Chest', getItemMediaURL(item.item.id));
                }
                when 'Waist' {
                    itemMap.put('Waist', getItemMediaURL(item.item.id));
                }
                when 'Legs' {
                    itemMap.put('Legs', getItemMediaURL(item.item.id));
                }
                when 'Feet' {
                    itemMap.put('Feet', getItemMediaURL(item.item.id));
                }
                when 'Wrist' {
                    itemMap.put('Wrist', getItemMediaURL(item.item.id));
                }
                when 'Hands' {
                    itemMap.put('Hands', getItemMediaURL(item.item.id));
                }
                when 'Ring 1' {
                    itemMap.put('Finger', getItemMediaURL(item.item.id));
                }
                when 'Ring 2' {
                    itemMap.put('Finger_2', getItemMediaURL(item.item.id));
                }
                when 'Trinket 1' {
                    itemMap.put('Trinket_1', getItemMediaURL(item.item.id));
                }
                when 'Trinket 2' {
                    itemMap.put('Trinket_2', getItemMediaURL(item.item.id));
                }
                when 'Back' {
                    itemMap.put('Back', getItemMediaURL(item.item.id));
                }
                when 'Main Hand' {
                    itemMap.put('Main_Hand', getItemMediaURL(item.item.id));
                }
                when 'Off Hand' {
                    itemMap.put('Off_Hand', getItemMediaURL(item.item.id));
                }
                when 'Tabard'{
                    itemMap.put('Tabard', getItemMediaURL(item.item.id));
                }
            }
        }

        return itemMap;
    }

    public static String getItemMediaURL(Integer itemId){
        
        String itemMedia = WoWDataAPI.fetchItemMedia(itemId);
        ItemMediaObject itemObject = (ItemMediaObject) JSON.deserialize(itemMedia.replaceAll('_links', 'links'), ItemMediaObject.class);

        return itemObject.assets[0].value;
    }
}