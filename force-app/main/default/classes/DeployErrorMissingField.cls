/**
 * DEPLOY ERROR TEST: Missing custom field (No such column)
 *
 * Expected error: "No such column 'Nonexistent_Deploy_Test_Field__c' on entity 'Account'"
 * Error category: Missing custom field
 */
public class DeployErrorMissingField {
    public static void causeError() {
        List<Account> accts = [SELECT Nonexistent_Deploy_Test_Field__c FROM Account LIMIT 1];
    }
}
