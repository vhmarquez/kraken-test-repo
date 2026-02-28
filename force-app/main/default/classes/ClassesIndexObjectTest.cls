@isTest public class ClassesIndexObjectTest { @isTest static void testAll() {
  ClassesIndexObject obj = new ClassesIndexObject();
  JSON.serialize(obj);
  ClassesIndexObject.self v_self = new ClassesIndexObject.self();
  ClassesIndexObject.key v_key = new ClassesIndexObject.key();
  ClassesIndexObject.classes v_classes = new ClassesIndexObject.classes();
  ClassesIndexObject.links v_links = new ClassesIndexObject.links();
  System.assertNotEquals(null, obj);
} }
