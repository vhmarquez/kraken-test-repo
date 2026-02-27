@isTest public class RacesIndexObjectTest { @isTest static void testAll() {
  RacesIndexObject obj = new RacesIndexObject();
  JSON.serialize(obj);
  RacesIndexObject.self v_self = new RacesIndexObject.self();
  RacesIndexObject.races v_races = new RacesIndexObject.races();
  RacesIndexObject.key v_key = new RacesIndexObject.key();
  RacesIndexObject.links v_links = new RacesIndexObject.links();
  System.assertNotEquals(null, obj);
} }
