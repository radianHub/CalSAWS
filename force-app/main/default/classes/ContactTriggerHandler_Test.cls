/***************************************************************************************************
Name        : ContactTriggerHandler_Test
Created By  : John Wrightsman - Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: 2/23/2018
Description : Unit test class for Contact Trigger Handler
Changes:
******************************************************************************************************/
@IsTest
public with sharing class ContactTriggerHandler_Test {

    @IsTest static void testCreateAccountFromJobSeekerContact() {
        Id jobSeekerRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Job Seeker' LIMIT 1].Id;
        Id employerRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Employer' LIMIT 1].Id;
        Id individualAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Individual' LIMIT 1].Id;

        // Create a contact of Job Seeker and of Employer
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'JobSeekerLastName', FirstName = 'JobSeekerFirstName', RecordTypeId = jobSeekerRecordTypeId));
        contacts.add(new Contact(LastName = 'EmployerLastName', FirstName = 'EmployerFirstName', RecordTypeId = employerRecordTypeId));
        Insert contacts;

        // We should only get an account created for Job Seeker
        List<Account> accounts = [SELECT Id, Name, RecordTypeId FROM Account];
        for (Account a : accounts) {
            System.debug(a);
        }
        System.assertEquals(1, accounts.size());
        System.assertEquals('JobSeekerFirstName JobSeekerLastName Household', accounts.get(0).Name);
    }

}