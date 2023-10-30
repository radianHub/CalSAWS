@isTest 
private class GoalTriggerTest {
    static testMethod void GoalTest() {
       Contact b = new Contact(lastname='Test',firstname='Test');
      
       insert b;
    
         Profile p = [SELECT Id FROM Profile WHERE Name='Job Seeker Community Profile']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, contactid=b.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

        insert u;
       goal__c c= new goal__c(client__c = b.id, Goal__c = 'test goal');
        insert c;
    }
}