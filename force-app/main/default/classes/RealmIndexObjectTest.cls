@isTest public class RealmIndexObjectTest { @isTest static void testAll() {
  RealmIndexObject obj = new RealmIndexObject();
  JSON.serialize(obj);
  RealmIndexObject.self v_self = new RealmIndexObject.self();
  RealmIndexObject.realms v_realms = new RealmIndexObject.realms();
  RealmIndexObject.links v_links = new RealmIndexObject.links();
  RealmIndexObject.key v_key = new RealmIndexObject.key();
  System.assertNotEquals(null, obj);
} }
