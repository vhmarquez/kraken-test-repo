/**
 * DEPLOY ERROR TEST: Illegal assignment / type mismatch
 *
 * Expected error: "Illegal assignment from String to Integer"
 * Error category: Illegal assignment / type mismatch
 */
public class DeployErrorTypeMismatch {
    public static void causeError() {
        Integer myNumber = 'this is not an integer';
        String myString = 42;
        Boolean myBool = new Account();
    }
}
