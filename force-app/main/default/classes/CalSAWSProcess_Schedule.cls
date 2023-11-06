public with sharing class CalSAWSProcess_Schedule implements Schedulable{
    public Map<String, String> endpoints;
    public static final String JOBNAME = 'CalSAWS Data Sync';
    public Integer bSize;

    public CalSAWSProcess_Schedule(Integer bSize) {
        this.endpoints = new Map<String, String>();
        this.bSize = bSize;
        List<CalSAWS_Endpoint__mdt> endpointList = [
            SELECT URL__c, MasterLabel
            FROM CalSAWS_Endpoint__mdt
        ];
        for (CalSAWS_Endpoint__mdt url : endpointList) {
            endpoints.put(url.MasterLabel, url.URL__c);
        }
    }

    public void execute(SchedulableContext sc) {
        if (!Test.isRunningTest()) {
            // * PROCESS NEW OR UPDATED PERSONS
            CalSAWSUtilities.processPersons(endpoints);
            // * PROCESS EXISTING CONTACTS USINGS SSN TO FIND UPDATED DATA
            CalSAWSPersonSearch_Batch b = new CalSAWSPersonSearch_Batch(endpoints);
            Database.executeBatch(b, bSize);
        }
    }

    public static void scheduleJob(String cronExp, Integer batchSize) {
        unscheduleJob();
        if (cronExp != null) {
            Id jobId = System.schedule(JOBNAME, cronExp, new CalSAWSProcess_Schedule(batchSize));
        }
    }

    public static void unscheduleJob() {
        for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :(JOBNAME + '%')]) {
            System.abortJob(ct.Id);
        }
    }
}