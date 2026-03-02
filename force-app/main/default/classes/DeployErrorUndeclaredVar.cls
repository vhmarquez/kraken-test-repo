/**
 * DEPLOY ERROR TEST: Variable does not exist (Apex compile error)
 *
 * Expected error: "Variable does not exist: undeclaredVariable"
 * Error category: Variable does not exist
 */
public class DeployErrorUndeclaredVar {
    public static void causeError() {
        System.debug(undeclaredVariable);
        String result = anotherMissingVar + ' test';
    }
}
