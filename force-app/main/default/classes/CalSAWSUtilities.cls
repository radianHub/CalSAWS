public with sharing class CalSAWSUtilities {
    
    public class Error {
        public String error_description;
        public String error;
        public String message;
    }

    public static Error parseError(String json) {
        return (Error) System.JSON.deserialize(json, Error.class);
    }

    public static List<CalSAWSPerson> parsePersons(String json) {
        return (List<CalSAWSPerson>) System.JSON.deserialize(json, List<CalSAWSPerson>.class);
    }

    public static CalSAWSPerson parsePerson(String json) {
        return (CalSAWSPerson) System.JSON.deserialize(json, CalSAWSPerson.class);
    }
}