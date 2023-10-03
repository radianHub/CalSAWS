public with sharing class CalSAWSProcess_Schedule implements Schedulable{
    public Map<String, String> endpoints;

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
}