public with sharing class CalSAWSQueueables implements Queueable, Database.AllowsCallouts {
    Map<String, String> endpoints;
    Map<String, String> cinContactMap;

    public CalSAWSQueueables(Map<String, String> endpoints, Map<String, String> cinContactMap) {
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;
    }

    public void execute(QueueableContext qc) {
        // if (!Test.isRunningTest()) {
            CalSAWSUtilities.processCases(endpoints, cinContactMap);
            CalSAWSUtilities.processPrograms(endpoints, cinContactMap);
        // }
    }
}