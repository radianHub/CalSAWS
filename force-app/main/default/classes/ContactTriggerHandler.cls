/***************************************************************************************************
Name        : ContactTriggerHandler
Created By  : John Wrightsman - Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: 2/23/2018
Description : Trigger Handler for Contact
Changes:
******************************************************************************************************/
public with sharing class ContactTriggerHandler {

    /**
     * @description: Create an Individual Account for each Job Seeker Contact
     * @param: List of newly created Contacts
     **/
    public static void createAccountForJobSeekerContacts(List<Contact> newContacts) {
        Id jobSeekerRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Job Seeker' LIMIT 1].Id;
        Id individualAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Individual' LIMIT 1].Id;
        List<Account> accountsToAdd = new List<Account>();
        Map<String, Contact> contactsByAccountNameMap = new Map<String, Contact>();
        for (Contact oContact : newContacts) {
            // Only add accounts for Job Seeker Contacts who do not already have an Account
            if (oContact.RecordTypeId == jobSeekerRecordTypeId && String.isBlank(oContact.accountid)) {
                Account oAccount = mapNewJobSeekerAccountFields(oContact, individualAccountRecordTypeId);
                accountsToAdd.add(oAccount);
                contactsByAccountNameMap.put(oAccount.Name, oContact);
            }
        }

        if (accountsToAdd.size() > 0) {
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.AllowFieldTruncation = true;
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            Database.SaveResult[] srList = Database.Insert(accountsToAdd, dmlOptions);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) { for (Database.Error err : sr.getErrors()) { System.debug('Error adding Account - statusCode:' + err.getStatusCode() + ': ' + err.getMessage() + '  Account fields that affected this error: ' + err.getFields()); } }
            }

            // Set the account id on the contact
            for (Account oAccount : accountsToAdd) {
                if (oAccount.Id != null) {
                    contactsByAccountNameMap.get(oAccount.Name).AccountId = oAccount.Id;
                }
            }
        }
    }

    /**
     * @description: Create a new Account from fields on a Contact
     * @param: oContact - the Contact
     * @param: recTypeId - the record type id for the Account
     * @return: a new Account
     **/
    private static Account mapNewJobSeekerAccountFields(Contact oContact, Id recTypeId) {
        return new Account(
            RecordTypeId = recTypeId,
            Contact_ID__c = oContact.Id,
            Name = (oContact.FirstName == null ? '' : (oContact.FirstName + ' ')) + oContact.LastName + ' Household',
            Phone = String.isNotBlank(oContact.HomePhone) ? oContact.HomePhone : oContact.MobilePhone,
            Launchpad__Geo_Location__Latitude__s = oContact.Launchpad__Geo_Location__Latitude__s,
            Launchpad__Geo_Location__Longitude__s = oContact.Launchpad__Geo_Location__Longitude__s,
            Launchpad__Location__Latitude__s = oContact.Launchpad__Location__Latitude__s,
            Launchpad__Location__Longitude__s = oContact.Launchpad__Location__Longitude__s,
            BillingCity = oContact.MailingCity,
            BillingPostalCode = oContact.MailingPostalCode,
            BillingState = oContact.MailingState,
            BillingStreet = oContact.MailingStreet
        );
    }


}