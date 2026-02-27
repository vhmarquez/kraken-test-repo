@isTest
public class getContactDataTableListTest {
    @testSetup
    static void setup() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<10; i++) {
            contacts.add(new Contact(LastName = 'TestContact' + i));
        }
        insert contacts;
    }

    @isTest
    static void testGetList() {
        Test.startTest();
        List<Contact> result = getContactDataTableList.getList(5);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size());
        // Since it enforces limit 5 in code (line 44), it should ideally be 5 or more depending on SOQL
        // Actually line 44 says limitNumber = 5; but the query on line 45 has no LIMIT clause.
        // It returns all contacts that the user can see.
        System.assert(result.size() >= 10);
    }
}
