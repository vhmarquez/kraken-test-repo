/**
 * DEPLOY ERROR TEST: Invalid type reference (Invalid type)
 *
 * Expected error: "Invalid type: NonExistentApexClassName"
 * Error category: Invalid type reference
 */
public class DeployErrorInvalidType {
    public static void causeError() {
        NonExistentApexClassName obj = new NonExistentApexClassName();
        System.debug(obj);
    }
}
