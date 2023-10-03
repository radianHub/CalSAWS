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

    public static List<CalSAWSCase> parseCase(String json) {
        return (List<CalSAWSCase>) System.JSON.deserialize(json, List<CalSAWSCase>.class);
    }

    // public static List<CalSAWSProgram> parsePrograms(String json) {

    // }

    public static void processUpsertResultList(Database.UpsertResult[] upsertResultList, String sObjName) {
        for (Database.UpsertResult r : upsertResultList) {
            if (!r.isSuccess()) {
                for (Database.Error e : r.getErrors()) {
                    System.debug(
                        'Error upserting ' + sObjName +
                        ' - status code: ' + e.getStatusCode() +
                        ';  Message: ' + e.getMessage() +
                        '; Fields that affected this error: ' + e.getFields()
                    );
                }
            }
        }
    }

    public static void processPersons(Map<String, String> endpoints) {
        List<CalSAWSPerson> personList = new List<CalSAWSPerson>();

        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        // * FETCH NEW AND UPDATED PERSONS FOR THE PAST 48 HOURS
        List<CalSAWSPerson> getPersonList = CalSAWSCallouts.getPersons(token, endpoints.get('Persons'));

        // * FETCH GREATER DETAIL FOR EACH PERSON GATHERED PREVIOUSLY
        for (CalSAWSPerson person : getPersonList) {
            CalSAWSPerson personV2 = CalSAWSCallouts.getPersonById(
                token,
                endpoints.get('Persons'),
                person.persId
            );
            personList.add(personV2);
        }

        // * START THE BATCH CHAINING PROCESS
        System.debug(':::STARTING PERSON BATCH:::');
        CalSAWSPerson_Batch b = new CalSAWSPerson_Batch(personList, endpoints);
        Database.executeBatch(b);
    }

    public static void processCases(Map<String, String> endpoints, Map<String, Contact> cinContactMap) {
        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        List<List<CalSAWSCase>> caseList = new List<List<CalSAWSCase>>();
        // * FETCH CASE DETAILS FOR EACH CIN NUMBER
        for (String cin : cinContactMap.keySet()) {
            List<CalSAWSCase> cs = CalSAWSCallouts.getCaseByCin(
                token,
                endpoints.get('Cases'),
                cin
            );
            caseList.add(cs);
        }

        System.debug(':::STARTING CASE BATCH:::');
        CalSAWSCase_Batch b = new CalSAWSCase_Batch(caseList, endpoints, cinContactMap);
        Database.executeBatch(b);
    }
}