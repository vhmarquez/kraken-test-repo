@isTest
public class ESCCDeviceControllerTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Org');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Title = 'Manager');
        insert con;
        TestDataFactory.createDevices(acc.Id, con.Id, 5);
    }

    @isTest
    static void testGetTreeData() {
        Test.startTest();
        List<ESCCDeviceController.TreeNode> nodes = ESCCDeviceController.getTreeData(new List<String>{'E-ISAC'}, 10, 0);
        Test.stopTest();
        System.assertNotEquals(0, nodes.size());
    }

    @isTest
    static void testGetTotalCount() {
        Test.startTest();
        Integer count = ESCCDeviceController.getTotalCount(new List<String>{'E-ISAC'});
        Test.stopTest();
        System.assertEquals(5, count);
    }

    @isTest
    static void testGetCSVData() {
        Test.startTest();
        String csv = ESCCDeviceController.getCSVData(new List<String>{});
        Test.stopTest();
        System.assert(csv.contains('Organization'));
    }
}
