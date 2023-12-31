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

    // * UNUSED
    // public static CalSAWSPerson parsePerson(String json) {
    //     return (CalSAWSPerson) System.JSON.deserialize(json, CalSAWSPerson.class);
    // }

    public static List<CalSAWSCase> parseCase(String json) {
        return (List<CalSAWSCase>) System.JSON.deserialize(json, List<CalSAWSCase>.class);
    }

    public static List<CalSAWSProgram> parsePrograms(String json) {
        return (List<CalSAWSProgram>) System.JSON.deserialize(json, List<CalSAWSProgram>.class);
    }

    @future(callout=true)
    public static void processPersons(Map<String, String> endpoints) {
        List<CalSAWSPerson> personList = new List<CalSAWSPerson>();

        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        // * FETCH NEW AND UPDATED PERSONS FOR THE PAST 48 HOURS
        List<CalSAWSPerson> getPersonList = CalSAWSCallouts.getPersons(token, endpoints.get('Persons'));

        // * FETCH GREATER DETAIL FOR EACH PERSON GATHERED PREVIOUSLY
        if (getPersonList != null && getPersonList.size() > 0) {
            for (CalSAWSPerson person : getPersonList) {
                List<CalSAWSPerson> personV2 = CalSAWSCallouts.getPersonByCin(
                    token,
                    endpoints.get('Persons'),
                    person.cin
                );
                personList.add(personV2[0]);
            }
        }

        Id jobId = System.enqueueJob(new CalSAWSPerson_Queueable(personList, endpoints));
    }
    
    public static List<CalSAWSPerson> processPerson(Map<String, String> endpoints, String ssn, CalSAWSAuthentication.Token token) {
        // CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        return CalSAWSCallouts.getPersonBySsn(
            token,
            endpoints.get('Persons'),
            ssn
        );
    }

    @future(callout=true)
    public static void processCases(Map<String, String> endpoints, Map<String, String> cinContactMap) {
        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        Map<String, List<CalSAWSCase>> cinCaseMap = new Map<String, List<CalSAWSCase>>();
        // * FETCH CASE DETAILS FOR EACH CIN NUMBER
        for (String cin : cinContactMap.keySet()) {
            List<CalSAWSCase> cs = CalSAWSCallouts.getCaseByCin(
                token,
                endpoints.get('Cases'),
                cin
            );
            cinCaseMap.put(cin, cs);
        }

        CalSAWSCase.upsertCases(cinContactMap, cinCaseMap);

        // System.debug(':::STARTING CASE BATCH:::');
        // CalSAWSCase_Batch b = new CalSAWSCase_Batch(endpoints, cinContactMap, cinCaseMap);
        // Database.executeBatch(b, 400);
    }

    @future(callout=true)
    public static void processPrograms(Map<String, String> endpoints, Map<String, String> cinContactMap) {
        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

        Map<String, List<CalSAWSProgram>> cinProgramMap = new Map<String, List<CalSAWSProgram>>();
        Date today = Date.today();
        // * FETCH PROGRAM DETAILS FOR EACH CIN NUMBER
        for (String cin : cinContactMap.keySet()) {
            List<CalSAWSProgram> pg = CalSAWSCallouts.getProgramsByCin(
                token,
                endpoints.get('Programs'),
                cin,
                today
            );
            cinProgramMap.put(cin, pg);
        }

        CalSAWSProgram.upsertPrograms(cinContactMap, cinProgramMap);

        // System.debug(':::STARTING PROGRAM BATCH:::');
        // CalSAWSProgram_Batch b = new CalSAWSProgram_Batch(endpoints, cinContactMap, cinProgramMap);
        // Database.executeBatch(b, 400);
    }

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

}