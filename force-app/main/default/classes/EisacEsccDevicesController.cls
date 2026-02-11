/**
 * @description Controller for eisacEsccDevices Lightning Web Component
 * Handles data fetching for ESCC (E-ISAC) communication devices in a hierarchical structure
 * @author Victor Marquez
 * @date 2025-10-11
 */
public with sharing class EisacEsccDevicesController {

    /**
     * @description Wrapper class for device data with hierarchical structure
     */
    public class DeviceTreeData {
        @AuraEnabled public List<OrganizationNode> organizations { get; set; }
        @AuraEnabled public Integer totalOrganizations { get; set; }
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer totalPages { get; set; }
    }

    /**
     * @description Organization/Account node in the tree
     */
    public class OrganizationNode {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public List<ContactNode> contacts { get; set; }
        @AuraEnabled public Boolean isExpanded { get; set; }
    }

    /**
     * @description Contact node in the tree
     */
    public class ContactNode {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String jobTitle { get; set; }
        @AuraEnabled public List<DeviceNode> devices { get; set; }
        @AuraEnabled public Boolean isExpanded { get; set; }
    }

    /**
     * @description Device node in the tree
     */
    public class DeviceNode {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String deviceNumber { get; set; }
        @AuraEnabled public String deviceLevel { get; set; }
        @AuraEnabled public String deviceType { get; set; }
    }

    /**
     * @description Fetches ESCC device data based on filter criteria
     * @param filterType Type of filter: 'eisac', 'myorg', or 'mine'
     * @param pageSize Number of organizations per page
     * @param pageNumber Current page number (1-based)
     * @return DeviceTreeData Hierarchical device data with pagination info
     */
    @AuraEnabled(cacheable=true)
    public static DeviceTreeData getDeviceData(String filterType, Integer pageSize, Integer pageNumber) {
        try {
            // Validate inputs
            if (String.isBlank(filterType)) {
                filterType = 'eisac';
            }
            if (pageSize == null || pageSize <= 0) {
                pageSize = 10;
            }
            if (pageNumber == null || pageNumber <= 0) {
                pageNumber = 1;
            }

            // Calculate offset for pagination
            Integer offset = (pageNumber - 1) * pageSize;

            // Get current user's Contact and Account for filtering
            Id currentUserId = UserInfo.getUserId();
            Id userContactId = null;
            Id userAccountId = null;

            if (filterType == 'mine' || filterType == 'myorg') {
                User currentUser = [
                    SELECT ContactId, Contact.AccountId
                    FROM User
                    WHERE Id = :currentUserId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                if (currentUser != null) {
                    userContactId = currentUser.ContactId;
                    userAccountId = currentUser.Contact?.AccountId;
                }
            }

            // Build query based on filter type
            Set<Id> accountIds = new Set<Id>();
            String deviceWhereClause = '';

            if (filterType == 'mine' && userContactId != null) {
                deviceWhereClause = 'Contact__c = :userContactId';
            } else if (filterType == 'myorg' && userAccountId != null) {
                deviceWhereClause = 'Organization__c = :userAccountId';
            }

            // Query devices with filters
            String deviceQuery = 'SELECT Id, Organization__c, Contact__c, Contact__r.Name, ' +
                'Contact__r.Title, Device_Number__c, Device_Level__c, Device_Type__c, Job_Title__c ' +
                'FROM Resilient_Communication_Device__c';

            if (String.isNotBlank(deviceWhereClause)) {
                deviceQuery += ' WHERE ' + deviceWhereClause;
            }

            deviceQuery += ' WITH SECURITY_ENFORCED ORDER BY Organization__c, Contact__c';

            List<Resilient_Communication_Device__c> devices = Database.query(deviceQuery);

            // Build map of Account IDs
            for (Resilient_Communication_Device__c device : devices) {
                if (device.Organization__c != null) {
                    accountIds.add(device.Organization__c);
                }
            }

            // Get total count of accounts for pagination
            Integer totalAccounts = accountIds.size();
            Integer totalPages = (Integer) Math.ceil((Decimal) totalAccounts / pageSize);

            // Query accounts with pagination
            List<Account> accounts = [
                SELECT Id, Name
                FROM Account
                WHERE Id IN :accountIds
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT :pageSize
                OFFSET :offset
            ];

            // Build organizational hierarchy
            DeviceTreeData result = buildTreeStructure(accounts, devices);
            result.totalOrganizations = totalAccounts;
            result.currentPage = pageNumber;
            result.totalPages = totalPages;

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching device data: ' + e.getMessage());
        }
    }

    /**
     * @description Builds hierarchical tree structure from accounts and devices
     * @param accounts List of Account records
     * @param devices List of Resilient_Communication_Device__c records
     * @return DeviceTreeData Organized hierarchical data
     */
    private static DeviceTreeData buildTreeStructure(
        List<Account> accounts,
        List<Resilient_Communication_Device__c> devices
    ) {
        DeviceTreeData result = new DeviceTreeData();
        result.organizations = new List<OrganizationNode>();

        // Create map of devices by account
        Map<Id, List<Resilient_Communication_Device__c>> devicesByAccount =
            new Map<Id, List<Resilient_Communication_Device__c>>();

        for (Resilient_Communication_Device__c device : devices) {
            if (!devicesByAccount.containsKey(device.Organization__c)) {
                devicesByAccount.put(device.Organization__c, new List<Resilient_Communication_Device__c>());
            }
            devicesByAccount.get(device.Organization__c).add(device);
        }

        // Build tree for each account
        for (Account acc : accounts) {
            OrganizationNode orgNode = new OrganizationNode();
            orgNode.id = acc.Id;
            orgNode.name = acc.Name;
            orgNode.isExpanded = false;
            orgNode.contacts = new List<ContactNode>();

            // Get devices for this account
            List<Resilient_Communication_Device__c> accountDevices =
                devicesByAccount.get(acc.Id);

            if (accountDevices != null) {
                // Group devices by contact
                Map<Id, List<Resilient_Communication_Device__c>> devicesByContact =
                    new Map<Id, List<Resilient_Communication_Device__c>>();

                for (Resilient_Communication_Device__c device : accountDevices) {
                    if (device.Contact__c != null) {
                        if (!devicesByContact.containsKey(device.Contact__c)) {
                            devicesByContact.put(device.Contact__c, new List<Resilient_Communication_Device__c>());
                        }
                        devicesByContact.get(device.Contact__c).add(device);
                    }
                }

                // Build contact nodes
                for (Id contactId : devicesByContact.keySet()) {
                    List<Resilient_Communication_Device__c> contactDevices = devicesByContact.get(contactId);

                    if (!contactDevices.isEmpty()) {
                        ContactNode contactNode = new ContactNode();
                        contactNode.id = contactId;
                        contactNode.name = contactDevices[0].Contact__r.Name;
                        contactNode.jobTitle = contactDevices[0].Job_Title__c != null ?
                            contactDevices[0].Job_Title__c :
                            (contactDevices[0].Contact__r.Title != null ? contactDevices[0].Contact__r.Title : '');
                        contactNode.isExpanded = false;
                        contactNode.devices = new List<DeviceNode>();

                        // Build device nodes
                        for (Resilient_Communication_Device__c device : contactDevices) {
                            DeviceNode deviceNode = new DeviceNode();
                            deviceNode.id = device.Id;
                            deviceNode.deviceNumber = device.Device_Number__c;
                            deviceNode.deviceLevel = device.Device_Level__c;
                            deviceNode.deviceType = device.Device_Type__c;

                            contactNode.devices.add(deviceNode);
                        }

                        orgNode.contacts.add(contactNode);
                    }
                }
            }

            result.organizations.add(orgNode);
        }

        return result;
    }

    /**
     * @description Exports device data to CSV format
     * @param filterType Type of filter: 'eisac', 'myorg', or 'mine'
     * @return String CSV formatted device data
     */
    @AuraEnabled
    public static String exportToCSV(String filterType) {
        try {
            // Get all data without pagination
            DeviceTreeData allData = getDeviceData(filterType, 10000, 1);

            // Build CSV
            String csv = 'Organization,Contact,Job Title,Device Number,Device Level,Device Type\n';

            for (OrganizationNode org : allData.organizations) {
                for (ContactNode contact : org.contacts) {
                    for (DeviceNode device : contact.devices) {
                        csv += '"' + org.name + '",';
                        csv += '"' + contact.name + '",';
                        csv += '"' + (contact.jobTitle != null ? contact.jobTitle : '') + '",';
                        csv += '"' + (device.deviceNumber != null ? device.deviceNumber : '') + '",';
                        csv += '"' + (device.deviceLevel != null ? device.deviceLevel : '') + '",';
                        csv += '"' + (device.deviceType != null ? device.deviceType : '') + '"\n';
                    }
                }
            }

            return csv;

        } catch (Exception e) {
            throw new AuraHandledException('Error exporting to CSV: ' + e.getMessage());
        }
    }
}