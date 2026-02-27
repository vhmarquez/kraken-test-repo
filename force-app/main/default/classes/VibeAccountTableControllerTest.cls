@isTest
public class VibeAccountTableControllerTest {
    @testSetup
    static void setup() {
        List<Account> testAccs = new List<Account>();
        for(Integer i=0; i<20; i++) {
            testAccs.add(new Account(Name = 'Vibe ' + i, Phone = '123' + i, Website = 'www.' + i + '.com'));
        }
        insert testAccs;
    }

    @isTest
    static void testGetAccountsPaged() {
        Test.startTest();
        VibeAccountTableController.PagedResult result = VibeAccountTableController.getAccounts(1, 10, 'Name', 'ASC', null);
        Test.stopTest();
        
        System.assertEquals(10, result.records.size(), 'Page size should be 10');
        System.assertEquals(20, result.totalRecords, 'Total records should be 20');
        System.assertEquals(1, result.pageNumber);
    }

    @isTest
    static void testGetAccountsWithSearch() {
        Test.startTest();
        VibeAccountTableController.PagedResult result = VibeAccountTableController.getAccounts(1, 10, 'Name', 'ASC', 'Vibe 1');
        Test.stopTest();
        
        // Vibe 1, Vibe 10, Vibe 11, ... Vibe 19 (11 records total if it matches substring)
        System.assert(result.totalRecords >= 1, 'Should find at least one record');
    }

    @isTest
    static void testGetAccountsInvalidInputs() {
        Test.startTest();
        // Test null/0 page info
        VibeAccountTableController.PagedResult result = VibeAccountTableController.getAccounts(0, 0, 'InvalidField', 'INVALID', '');
        Test.stopTest();
        
        System.assertEquals(10, result.pageSize, 'Should default to 10');
        System.assertEquals(1, result.pageNumber, 'Should default to 1');
    }
}
