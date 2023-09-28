public with sharing class CalSAWSUtilities {
    
    public class Error {
        public String error_description;
        public String error;
    }

    public static Error parseError(String json) {
        return (Error) System.JSON.deserialize(json, Error.class);
    }
}