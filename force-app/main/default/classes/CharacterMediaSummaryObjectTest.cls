@isTest public class CharacterMediaSummaryObjectTest { @isTest static void testAll() {
  CharacterMediaSummaryObject obj = new CharacterMediaSummaryObject();
  JSON.serialize(obj);
  CharacterMediaSummaryObject.self v_self = new CharacterMediaSummaryObject.self();
  CharacterMediaSummaryObject.realm v_realm = new CharacterMediaSummaryObject.realm();
  CharacterMediaSummaryObject.key v_key = new CharacterMediaSummaryObject.key();
  CharacterMediaSummaryObject.character v_character = new CharacterMediaSummaryObject.character();
  CharacterMediaSummaryObject.assets v_assets = new CharacterMediaSummaryObject.assets();
  CharacterMediaSummaryObject.links v_links = new CharacterMediaSummaryObject.links();
  System.assertNotEquals(null, obj);
} }
