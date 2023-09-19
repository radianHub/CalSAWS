@IsTest

public class HireTriggerHandler_Test {

    static TestMethod void testmethod1() {
        Contact oContact = new Contact(FirstName = 'Test', LastName = 'Test', Resume_completed_tailored_to_position__c = True,
            Professional_appearance_interview_attire__c = True, Has_good_punctuality_and_attendance__c = True);
        insert oContact;

        Account oAccount = new Account(Name = 'Test');
        RecordType accountRecordType = [select Id from RecordType WHERE Name = 'Employer' AND SobjectType = 'Account' limit 1];
        oAccount.RecordTypeId = accountRecordType.Id;
        insert oAccount;
        
        Launchpad__Job__c job = new Launchpad__Job__c(Launchpad__Account__c = oAccount.Id, Name = 'Test');
        insert job;
            
        Launchpad__Applicant_Tracking__c jobApplication = new Launchpad__Applicant_Tracking__c(
            Launchpad__Participant__c = oContact.Id,
            Launchpad__Job_Order__c = job.Id,
            Launchpad__Date_of_Hire__c = Date.today(),
            Launchpad__Hours_Per_Week__c = 40
        );

        insert jobApplication;
        
        // Change stage to 'Hired' so that a Hire object is created
        jobApplication.Launchpad__Stage__c = 'Hired';
        update jobApplication;
        List<Launchpad__Hire__c> hires = [SELECT Job_Application__c, Hours_per_Week__c FROM Launchpad__Hire__c];
        System.assertEquals(1, hires.size());
        System.assertEquals(jobApplication.Id, hires.get(0).Job_Application__c);
        //System.assertEquals(jobApplication.Launchpad__Hours_Per_Week__c, hires.get(0).Hours_per_Week__c);
    }

}