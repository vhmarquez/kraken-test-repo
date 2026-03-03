public with sharing class StringManipulator {

    public static String reverseString(String input) {
        if (String.isBlank(input)) {
            return '';
        }
        String reversed = '';
        for (Integer i = input.length() - 1; i >= 0; i--) {
            reversed += input.substring(i, i + 1);
        }
        return reversed;
    }

    public static String capitalize(String input) {
        if (String.isBlank(input)) {
            return '';
        }
        return input.substring(0, 1).toUpperCase() + input.substring(1).toLowerCase();
    }

    public static Integer countVowels(String input) {
        if (String.isBlank(input)) {
            return 0;
        }
        Integer count = 0;
        String vowels = 'aeiouAEIOU';
        for (Integer i = 0; i < input.length(); i++) {
            if (vowels.contains(input.substring(i, i + 1))) {
                count++;
            }
        }
        return count;
    }

    public static String truncate(String input, Integer maxLength) {
        if (String.isBlank(input)) {
            return '';
        }
        if (input.length() <= maxLength) {
            return input;
        }
        return input.substring(0, maxLength) + '...';
    }
}
