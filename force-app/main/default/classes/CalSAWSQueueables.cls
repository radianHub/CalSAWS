public with sharing class CalSAWSQueueables implements Queueable, Database.AllowsCallouts {
    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;

    public CalSAWSQueueables(Map<String, String> endpoints, Map<String, Contact> cinContactMap) {
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;
    }

    public void execute(QueueableContext qc) {
        if (!Test.isRunningTest()) {
            Id jobId = System.enqueueJob(new CalSAWSCase_Queueable(endpoints, cinContactMap));
            Id jobId2 = System.enqueueJob(new CalSAWSProgram_Queueable(endpoints, cinContactMap));
        }
    }
}