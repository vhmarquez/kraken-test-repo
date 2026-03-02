@IsTest
private class StringManipulatorTest {

    @IsTest
    static void testReverseString() {
        String result = StringManipulator.reverseString('hello');
        System.assertEquals('olleh', result);
    }

    @IsTest
    static void testReverseStringBlank() {
        String result = StringManipulator.reverseString('');
        System.assertEquals('', result);
    }

    @IsTest
    static void testCapitalize() {
        String result = StringManipulator.capitalize('hello');
        System.assertEquals('Hello', result);
    }

    @IsTest
    static void testCapitalizeBlank() {
        String result = StringManipulator.capitalize(null);
        System.assertEquals('', result);
    }

    @IsTest
    static void testCountVowels() {
        Integer result = StringManipulator.countVowels('education');
        System.assertEquals(5, result);
    }

    @IsTest
    static void testCountVowelsNone() {
        Integer result = StringManipulator.countVowels('gym');
        System.assertEquals(0, result);
    }
    
    @IsTest
    static void testTruncate() {
        String result = StringManipulator.truncate('Hello World', 5);
        System.assertEquals('Hello...', result);
    }

    @IsTest
    static void testTruncateShortString() {
        String result = StringManipulator.truncate('Hi', 10);
        System.assertEquals('Hi', result);
    }

    @IsTest
    static void testTruncateBlank() {
        String result = StringManipulator.truncate(null, 5);
        System.assertEquals('', result);
    }
}
