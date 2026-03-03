/**
 * DEPLOY ERROR TEST: Missing or invalid Flow
 *
 * Expected error: "Invalid type: Flow.Interview.Nonexistent_Deploy_Error_Flow"
 * Error category: Missing or invalid Flow
 */
public class DeployErrorMissingFlow {
    public static void causeError() {
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('varName', 'test');
        Flow.Interview.Nonexistent_Deploy_Error_Flow myFlow =
            new Flow.Interview.Nonexistent_Deploy_Error_Flow(inputs);
        myFlow.start();
    }
}
