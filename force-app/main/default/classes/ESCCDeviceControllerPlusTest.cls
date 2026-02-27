@isTest
public class ESCCDeviceControllerPlusTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Org Plus');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact Plus', AccountId = acc.Id, Title = 'Director');
        insert con;
        TestDataFactory.createDevices(acc.Id, con.Id, 2);
    }

    @isTest
    static void testGetTreeData() {
        Test.startTest();
        List<ESCCDeviceControllerPlus.TreeNode> nodes = ESCCDeviceControllerPlus.getTreeData(new List<String>{'E-ISAC'}, 10, 0);
        Test.stopTest();
        System.assertNotEquals(0, nodes.size());
    }

    @isTest
    static void testGetTotalCount() {
        Test.startTest();
        Integer count = ESCCDeviceControllerPlus.getTotalCount(new List<String>{'E-ISAC'});
        Test.stopTest();
        System.assertEquals(2, count);
    }

    @isTest
    static void testGetCSVData() {
        Test.startTest();
        String csv = ESCCDeviceControllerPlus.getCSVData(new List<String>{});
        Test.stopTest();
        System.assert(csv.contains('Organization'));
    }
}
