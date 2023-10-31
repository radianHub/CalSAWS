public with sharing class CalSAWSPerson_Queueable implements Queueable {
    List<CalSAWSPerson> personList;
    Map<String, String> endpoints;

    public CalSAWSPerson_Queueable(List<CalSAWSPerson> personList, Map<String, String> endpoints) {
        this.personList = personList;
        this.endpoints = endpoints;
    }

    public void execute(QueueableContext qc) {
        System.debug(':::STARTING PERSON BATCH:::');
        CalSAWSPerson_Batch b = new CalSAWSPerson_Batch(personList, endpoints);
        Database.executeBatch(b);
    }
}