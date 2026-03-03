/**
 * DEPLOY ERROR TEST: Entity not org-accessible (missing object)
 *
 * Expected error: "sObject type 'Nonexistent_Deploy_Object__c' is not supported"
 * Error category: Entity not org-accessible / missing object
 */
public class DeployErrorMissingObject {
    public static void causeError() {
        Nonexistent_Deploy_Object__c obj = new Nonexistent_Deploy_Object__c();
        insert obj;
    }
}
