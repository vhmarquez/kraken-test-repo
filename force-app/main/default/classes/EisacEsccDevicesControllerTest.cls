@isTest
public class EisacEsccDevicesControllerTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'Eisac Org');
        insert acc;
        Contact con = new Contact(LastName = 'Eisac Contact', AccountId = acc.Id);
        insert con;
        TestDataFactory.createDevices(acc.Id, con.Id, 3);
    }

    @isTest
    static void testGetDeviceData() {
        Test.startTest();
        EisacEsccDevicesController.DeviceTreeData result = EisacEsccDevicesController.getDeviceData('eisac', 10, 1);
        Test.stopTest();
        System.assertNotEquals(0, result.organizations.size());
        System.assertEquals(1, result.totalOrganizations);
    }

    @isTest
    static void testExportToCSV() {
        Test.startTest();
        String csv = EisacEsccDevicesController.exportToCSV('eisac');
        Test.stopTest();
        System.assert(csv.contains('Organization'));
    }
}
