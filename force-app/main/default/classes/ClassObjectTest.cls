@isTest public class ClassObjectTest { @isTest static void testAll() {
  ClassObject obj = new ClassObject();
  JSON.serialize(obj);
  ClassObject.specializations v_specializations = new ClassObject.specializations();
  ClassObject.self v_self = new ClassObject.self();
  ClassObject.pvp_talent_slots v_pvp_talent_slots = new ClassObject.pvp_talent_slots();
  ClassObject.power_type v_power_type = new ClassObject.power_type();
  ClassObject.playable_races v_playable_races = new ClassObject.playable_races();
  ClassObject.media v_media = new ClassObject.media();
  ClassObject.key v_key = new ClassObject.key();
  ClassObject.gender_name v_gender_name = new ClassObject.gender_name();
  ClassObject.additional_power_types v_additional_power_types = new ClassObject.additional_power_types();
  ClassObject.links v_links = new ClassObject.links();
  System.assertNotEquals(null, obj);
} }
