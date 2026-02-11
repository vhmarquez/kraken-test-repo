public with sharing class ESCCDeviceControllerPlus {
    
    @AuraEnabled(cacheable=true)
    public static List<TreeNode> getTreeData(List<String> viewFilters, Integer limitSize, Integer offset) {
        List<String> conditions = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
        if (viewFilters != null && !viewFilters.isEmpty()) {
            Id userAccountId = getCurrentUserAccountId();
            Id userContactId = getCurrentUserContactId();
            
            if (viewFilters.contains('My Org') && userAccountId != null) {
                conditions.add('Organization__c = :userAccountId');
                bindVars.put('userAccountId', userAccountId);
            }
            if (viewFilters.contains('Mine') && userContactId != null) {
                conditions.add('Contact__c = :userContactId');
                bindVars.put('userContactId', userContactId);
            }
            if (viewFilters.contains('E-ISAC')) {
                // Placeholder: Update as needed
                conditions.add('Device_Type__c = \'Satellite\'');
            }
            // For 'Display Contacts', add no condition (or update if it means filter for records with contacts)
        }
        
        String whereClause = conditions.isEmpty() ? '' : 'WHERE ' + String.join(conditions, ' AND ');
        
        String query = 'SELECT Organization__r.Name, Organization__c, Contact__r.Name, Contact__c, Job_Title__c, ' +
                       'Device_Level__c, Device_Type__c, Device_Number__c, Id ' +
                       'FROM Resilient_Communication_Device__c ' + whereClause +
                       ' ORDER BY Organization__r.Name, Contact__r.Name, Device_Level__c LIMIT :limitSize OFFSET :offset';
        
        bindVars.put('limitSize', limitSize);
        bindVars.put('offset', offset);
        
        List<Resilient_Communication_Device__c> devices = Database.queryWithBinds(query, bindVars, AccessLevel.USER_MODE);
        
        // Group into three-level tree: Organization > Contact > Device
        Map<Id, TreeNode> orgNodes = new Map<Id, TreeNode>();
        Map<String, TreeNode> contactNodes = new Map<String, TreeNode>(); // Key: OrgId_ContactId
        
        for (Resilient_Communication_Device__c dev : devices) {
            TreeNode orgNode = orgNodes.get(dev.Organization__c);
            if (orgNode == null) {
                orgNode = new TreeNode(dev.Organization__r.Name, dev.Organization__c, new List<TreeNode>());
                orgNodes.put(dev.Organization__c, orgNode);
            }
            
            String contactKey = dev.Organization__c + '_' + dev.Contact__c;
            TreeNode contactNode = contactNodes.get(contactKey);
            if (contactNode == null) {
                String contactDisplay = dev.Contact__r.Name + ' - ' + dev.Job_Title__c;
                contactNode = new TreeNode(contactDisplay, dev.Contact__c, new List<TreeNode>());
                contactNodes.put(contactKey, contactNode);
                orgNode.children.add(contactNode);
            }
            
            TreeNode deviceNode = new TreeNode(
                '', dev.Id, null, '', dev.Device_Level__c, dev.Device_Type__c, dev.Device_Number__c
            );
            contactNode.children.add(deviceNode);
        }
        
        return orgNodes.values();
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getTotalCount(List<String> viewFilters) {
        List<String> conditions = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
        if (viewFilters != null && !viewFilters.isEmpty()) {
            Id userAccountId = getCurrentUserAccountId();
            Id userContactId = getCurrentUserContactId();
            
            if (viewFilters.contains('My Org') && userAccountId != null) {
                conditions.add('Organization__c = :userAccountId');
                bindVars.put('userAccountId', userAccountId);
            }
            if (viewFilters.contains('Mine') && userContactId != null) {
                conditions.add('Contact__c = :userContactId');
                bindVars.put('userContactId', userContactId);
            }
            if (viewFilters.contains('E-ISAC')) {
                conditions.add('Device_Type__c = \'Satellite\'');
            }
        }
        
        String whereClause = conditions.isEmpty() ? '' : 'WHERE ' + String.join(conditions, ' AND ');
        
        String query = 'SELECT COUNT() FROM Resilient_Communication_Device__c ' + whereClause;
        
        return Database.countQueryWithBinds(query, bindVars, AccessLevel.USER_MODE);
    }
    
    @AuraEnabled
    public static String getCSVData(List<String> viewFilters) {
        List<String> conditions = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
        if (viewFilters != null && !viewFilters.isEmpty()) {
            Id userAccountId = getCurrentUserAccountId();
            Id userContactId = getCurrentUserContactId();
            
            if (viewFilters.contains('My Org') && userAccountId != null) {
                conditions.add('Organization__c = :userAccountId');
                bindVars.put('userAccountId', userAccountId);
            }
            if (viewFilters.contains('Mine') && userContactId != null) {
                conditions.add('Contact__c = :userContactId');
                bindVars.put('userContactId', userContactId);
            }
            if (viewFilters.contains('E-ISAC')) {
                conditions.add('Device_Type__c = \'Satellite\'');
            }
        }
        
        String whereClause = conditions.isEmpty() ? '' : 'WHERE ' + String.join(conditions, ' AND ');
        
        String query = 'SELECT Organization__r.Name, Contact__r.Name, Job_Title__c, ' +
                       'Device_Level__c, Device_Type__c, Device_Number__c ' +
                       'FROM Resilient_Communication_Device__c ' + whereClause +
                       ' ORDER BY Organization__r.Name, Contact__r.Name';
        
        List<Resilient_Communication_Device__c> devices = Database.queryWithBinds(query, bindVars, AccessLevel.USER_MODE);
        String csv = 'Organization,Contact Name,Title,Device Level,Device Type,Device Number\n';
        for (Resilient_Communication_Device__c dev : devices) {
            csv += escapeCSV(dev.Organization__r.Name) + ',' + escapeCSV(dev.Contact__r.Name) + ',' +
                   escapeCSV(dev.Job_Title__c) + ',' + escapeCSV(dev.Device_Level__c) + ',' +
                   escapeCSV(dev.Device_Type__c) + ',' + escapeCSV(dev.Device_Number__c) + '\n';
        }
        return csv;
    }
    
    private static String escapeCSV(String val) {
        if (val == null) return '';
        return '"' + val.replace('"', '""') + '"';
    }
    
    private static Id getCurrentUserAccountId() {
        User u = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        return u.Contact?.AccountId;
    }
    
    private static Id getCurrentUserContactId() {
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        return u.ContactId;
    }
    
    public class TreeNode {
        @AuraEnabled public String name;
        @AuraEnabled public String id;
        @AuraEnabled public List<TreeNode> children;
        @AuraEnabled public String title;
        @AuraEnabled public String deviceLevel;
        @AuraEnabled public String deviceType;
        @AuraEnabled public String deviceNumber;
        
        public TreeNode(String name, String id, List<TreeNode> children) {
            this.name = name;
            this.id = id;
            this.children = children != null ? children : new List<TreeNode>();
        }
        
        public TreeNode(String name, String id, List<TreeNode> children, String title, String deviceLevel, String deviceType, String deviceNumber) {
            this(name, id, children);
            this.title = title;
            this.deviceLevel = deviceLevel;
            this.deviceType = deviceType;
            this.deviceNumber = deviceNumber;
        }
    }
}