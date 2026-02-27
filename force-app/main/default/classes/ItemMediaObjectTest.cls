@isTest public class ItemMediaObjectTest { @isTest static void testAll() {
  ItemMediaObject obj = new ItemMediaObject();
  JSON.serialize(obj);
  ItemMediaObject.self v_self = new ItemMediaObject.self();
  ItemMediaObject.assets v_assets = new ItemMediaObject.assets();
  ItemMediaObject.links v_links = new ItemMediaObject.links();
  System.assertNotEquals(null, obj);
} }
