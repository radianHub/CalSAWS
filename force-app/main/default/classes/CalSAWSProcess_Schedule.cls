public with sharing class CalSAWSProcess_Schedule implements Schedulable{
    public Map<String, String> endpoints;
    public static final String JOBNAME = 'CalSAWS Data Sync';

    public CalSAWSProcess_Schedule() {
        List<CalSAWS_Endpoint__mdt> endpointList = [
            SELECT URL__c, MasterLabel
            FROM CalSAWS_Endpoint__mdt
        ];
        for (CalSAWS_Endpoint__mdt url : endpointList) {
            this.endpoints.put(url.MasterLabel, url.URL__c);
        }
    }

    public void execute(SchedulableContext sc) {
        CalSAWSUtilities.processPersons(endpoints);
    }

    public static void scheduleJob(String cronExp) {
        unscheduleJob();
        if (cronExp != null) {
            Id jobId = System.schedule(JOBNAME, cronExp, new CalSAWSProcess_Schedule());
        }
    }

    public static void unscheduleJob() {
        for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :(JOBNAME + '%')]) {
            System.abortJob(ct.Id);
        }
    }
}