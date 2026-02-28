@isTest
public class WoWCharacterTest {
    @testSetup
    static void setup() {
        TestDataFactory.createWoWMetadata();
    }

    @isTest
    static void testCreateCharacterLead() {
        String profileJson = '{"id": 123, "character_class": {"name": {"en_US": "Warrior"}}, "active_spec": {"name": {"en_US": "Arms"}}, "realm": {"name": {"en_US": "Aegwynn"}}, "race": {"name": {"en_US": "Orc"}}, "faction": {"name": {"en_US": "Horde"}}, "level": 60, "equipped_item_level": 200}';
        Test.setMock(HttpCalloutMock.class, new UtilityMethodsMock(200, 'OK', profileJson, new Map<String, String>()));
        
        Test.startTest();
        WoWCharacter.createCharacterLead('aegwynn', 'testchar');
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Lead].size());
    }

    @isTest
    static void testCreateCharacterApplicantAndModel() {
        Realm__c realm = [SELECT Id FROM Realm__c WHERE Name = 'Aegwynn' LIMIT 1];
        insert new Guild_Applicant__c(Name='Temp', Realm__c=realm.Id);
        Guild_Applicant__c applicant = [SELECT Id FROM Guild_Applicant__c LIMIT 1];
        
        String profileJson = '{"id": 123, "character_class": {"name": {"en_US": "Warrior"}}, "active_spec": {"name": {"en_US": "Arms"}}, "realm": {"name": {"en_US": "Aegwynn"}}, "race": {"name": {"en_US": "Orc"}}, "faction": {"name": {"en_US": "Horde"}}, "level": 60, "equipped_item_level": 200, "active_title": {"name": {"en_US": "Slayer"}}}';
        String mediaJson = '{"assets": [{"key": "avatar", "value": "url1"}, {"key": "inset", "value": "url2"}, {"key": "main", "value": "url3"}]}';
        String equipJson = '{"equipped_items": ['+
            '{"slot": {"name": "Head"}, "item": {"id": 100}},'+
            '{"slot": {"name": "Neck"}, "item": {"id": 101}},'+
            '{"slot": {"name": "Shoulders"}, "item": {"id": 102}},'+
            '{"slot": {"name": "Chest"}, "item": {"id": 103}},'+
            '{"slot": {"name": "Waist"}, "item": {"id": 104}},'+
            '{"slot": {"name": "Legs"}, "item": {"id": 105}},'+
            '{"slot": {"name": "Feet"}, "item": {"id": 106}},'+
            '{"slot": {"name": "Wrist"}, "item": {"id": 107}},'+
            '{"slot": {"name": "Hands"}, "item": {"id": 108}},'+
            '{"slot": {"name": "Ring 1"}, "item": {"id": 109}},'+
            '{"slot": {"name": "Ring 2"}, "item": {"id": 110}},'+
            '{"slot": {"name": "Trinket 1"}, "item": {"id": 111}},'+
            '{"slot": {"name": "Trinket 2"}, "item": {"id": 112}},'+
            '{"slot": {"name": "Back"}, "item": {"id": 113}},'+
            '{"slot": {"name": "Main Hand"}, "item": {"id": 114}},'+
            '{"slot": {"name": "Off Hand"}, "item": {"id": 115}},'+
            '{"slot": {"name": "Tabard"}, "item": {"id": 116}}' +
        ']}';
        String itemMediaJson = '{"assets": [{"value": "item_url"}]}';

        Map<String, String> responses = new Map<String, String>{
            '/profile/wow/character/aegwynn/testchar?namespace=profile-us' => profileJson,
            'character-media' => mediaJson,
            'equipment' => equipJson,
            'media/item' => itemMediaJson
        };
        
        Test.setMock(HttpCalloutMock.class, new MultiMock(responses));

        Test.startTest();
        List<List<String>> args = new List<List<String>>{ new List<String>{'aegwynn', 'testchar', applicant.Id} };
        List<SObject> results = WoWCharacter.createCharacterApplicant(args);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, [SELECT Id FROM Character_Model__c WHERE Name = 'Testchar'].Id);
    }
}
