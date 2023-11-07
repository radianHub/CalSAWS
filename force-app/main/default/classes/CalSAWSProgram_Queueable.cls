public with sharing class CalSAWSProgram_Queueable implements Queueable, Database.AllowsCallouts {

    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;

    public CalSAWSProgram_Queueable(Map<String, String> endpoints, Map<String, Contact> cinContactMap) {
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;
    }

    public void execute(QueueableContext qc) {
        CalSAWSUtilities.processPrograms(endpoints, cinContactMap);
    }
}