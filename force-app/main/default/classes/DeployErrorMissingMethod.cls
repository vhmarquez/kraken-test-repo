/**
 * DEPLOY ERROR TEST: Method does not exist
 *
 * Expected error: "Method does not exist or incorrect signature: void nonExistentMethod() from the type Account"
 * Error category: Method does not exist
 */
public class DeployErrorMissingMethod {
    public static void causeError() {
        Account a = new Account();
        a.nonExistentMethod();

        String s = 'test';
        s.totallyFakeMethod(123, true);
    }
}
