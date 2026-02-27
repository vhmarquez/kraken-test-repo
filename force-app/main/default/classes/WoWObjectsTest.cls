@isTest
public class WoWObjectsTest {
    @isTest static void testCharacterEquipmentSummaryObject() {
        CharacterEquipmentSummaryObject obj = new CharacterEquipmentSummaryObject();
        obj.equipped_items = new List<CharacterEquipmentSummaryObject.equipped_items>();
        System.assertNotEquals(null, obj.equipped_items);
    }
    @isTest static void testCharacterMediaSummaryObject() {
        CharacterMediaSummaryObject obj = new CharacterMediaSummaryObject();
        obj.assets = new List<CharacterMediaSummaryObject.assets>();
        System.assertNotEquals(null, obj.assets);
    }
    @isTest static void testCharacterProfileSummaryObject() {
        CharacterProfileSummaryObject obj = new CharacterProfileSummaryObject();
        obj.name = 'Test';
        System.assertEquals('Test', obj.name);
    }
    @isTest static void testClassObject() {
        ClassObject obj = new ClassObject();
        obj.name = 'Test';
        System.assertEquals('Test', obj.name);
    }
    @isTest static void testClassesIndexObject() {
        ClassesIndexObject obj = new ClassesIndexObject();
        obj.classes = new List<ClassesIndexObject.classes>();
        System.assertNotEquals(null, obj.classes);
    }
    @isTest static void testItemMediaObject() {
        ItemMediaObject obj = new ItemMediaObject();
        obj.assets = new List<ItemMediaObject.assets>();
        System.assertNotEquals(null, obj.assets);
    }
    @isTest static void testRacesIndexObject() {
        RacesIndexObject obj = new RacesIndexObject();
        obj.races = new List<RacesIndexObject.races>();
        System.assertNotEquals(null, obj.races);
    }
    @isTest static void testRealmIndexObject() {
        RealmIndexObject obj = new RealmIndexObject();
        obj.realms = new List<RealmIndexObject.realms>();
        System.assertNotEquals(null, obj.realms);
    }
}
