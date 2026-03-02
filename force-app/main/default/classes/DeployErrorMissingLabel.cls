/**
 * DEPLOY ERROR TEST: Missing custom label
 *
 * Expected error: "Variable does not exist: System.Label.Nonexistent_Deploy_Error_Label"
 * Error category: Missing custom label
 */
public class DeployErrorMissingLabel {
    public static void causeError() {
        String labelValue = System.Label.Nonexistent_Deploy_Error_Label;
        System.debug(labelValue);
    }
}
