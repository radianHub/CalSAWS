public with sharing class CalSAWSCase_Queueable implements Queueable, Database.AllowsCallouts {
    // Map<String, String> endpoints;
    // Map<String, Contact> cinContactMap;

    // public CalSAWSCase_Queueable(Map<String, String> endpoints, Map<String, Contact> cinContactMap) {
    //     this.endpoints = endpoints;
    //     this.cinContactMap = cinContactMap;
    // }

    public void execute(QueueableContext qc) {
        // CalSAWSUtilities.processCases(endpoints, cinContactMap);
    }
}