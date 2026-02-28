@isTest
public class CursorContactsTest {
    @testSetup
    static void setup() {
        List<Contact> cons = new List<Contact>();
        for(Integer i=0; i<10; i++) {
            cons.add(new Contact(LastName = 'CursorContact ' + i));
        }
        insert cons;
    }

    @isTest
    static void testGetContacts() {
        Test.startTest();
        // Page 1, size 5. currentRecordCount = 5. offset = 10 - 5 = 5. pageSize = 5.
        // fetch(5, 5) returns records 5-9.
        List<Contact> result = CursorContacts.getContacts(5, 1);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(5, result.size());
    }

    @isTest
    static void testGetTotalContacts() {
        Test.startTest();
        Integer total = CursorContacts.getTotalContacts();
        Test.stopTest();
        System.assertEquals(10, total);
    }
}
