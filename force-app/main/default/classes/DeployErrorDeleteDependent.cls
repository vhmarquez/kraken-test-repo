/**
 * DEPLOY ERROR TEST: Cannot delete dependent metadata
 *
 * This class creates a dependency chain. If you attempt to delete
 * UtilityMethods (or any class this depends on) via destructiveChanges.xml
 * while this class still exists, you'll get:
 *
 * Expected error: "Cannot delete... This component has dependencies"
 * Error category: Cannot delete dependent metadata
 *
 * To test: deploy a destructiveChanges.xml that tries to remove a class
 * or object that other components reference.
 *
 * Example destructiveChanges.xml is at:
 *   deploy-error-tests/destructiveChanges/destructiveChanges.xml
 */
public class DeployErrorDeleteDependent {
    // Intentionally depends on an existing class to create a real dependency
    public static String getValue() {
        // References Account standard object - cannot be deleted
        Account a = new Account(Name = 'Test');
        return a.Name;
    }
}
