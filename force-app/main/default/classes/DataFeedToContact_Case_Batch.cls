/***************************************************************************************************
Name        : DataFeedToContact_Case_Batch
Created By  : Padma Ramkumar, Revelant Technologies
Email       : padma.ramkumar@revelanttech.com
Created Date: Oct 2017
Description : This batch will  converts data we receive from a nightly feed we call the CIS Data Feed, that comes through Jitterbit.
This feed brings in data for Contacts and CalwinCase participation, and converts it to Contacts and related CalWINs_Case__c records.
Also Changed the Data Feed object's Business status field to Processed for purge after a week.
Changes:
***************************************************************************************************/

global class DataFeedToContact_Case_Batch implements Schedulable, Database.Batchable<sObject> {
    private Id dataFeedId = null;

    global DataFeedToContact_Case_Batch(Id datafeedId) {
        this.datafeedId = datafeedId;
    }

    global DataFeedToContact_Case_Batch() {
    }

    global void execute(SchedulableContext sc) {
        id batchId = Database.executeBatch(new DataFeedToContact_Case_Batch());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (dataFeedId != null) {
            return Database.getQueryLocator([
                SELECT Id, ClientID__c, LastName__c, FirstName__c, Alias__c, SSN__c, CalWINCasePhone__c, IsCalWINOkToText__c,
                    CalWINIndividualPhone__c, CalWINEmail__c, IsCalWINOkToEmail__c, AlternatePhone__c,IsAlternateOkToText__c,
                    AlternateEmail__c, IsAlternateOkToEmail__c, MailingAddr1__c, MailingAddr2__c, MailingAddrCity__c,
                    MailingAddrStateId__c, MailingAddrZip__c, ResidentialAddr1__c, ResidentialAddr2__c, ResidentialAddrCity__c,
                    ResidentialAddrStateId__c, ResidentialAddrZip__c, CaseNumber__c, CurrentCaseStatus__c, CaseStatusDate__c,
                    CWIN__c, HouseholdTypeId__c, IsInHome__c, Month48TimeOnAidClock__c, WtW24MonthClock__c,
                    Month12VocationalTrainingClock__c, EthnicityId__c, DOB__c, GenderId__c, IsVeteran__c, PreferredLanguage__c,
                    IsHomeless__c, MiddleName__c, Email__c, IsCISClient__c, IsJAMSClient__c, IsActive__c, AddedAt__c,
                    ClientSource__c, AlternateZipCode__c, Mi__c, Sufx__c
                FROM Data_Feed__c
                WHERE Source_File__c = 'cisrawclient.csv'
                AND Id = :dataFeedId
            ]);
        } else {
            return Database.getQueryLocator([
                SELECT Id, ClientID__c, LastName__c, FirstName__c, Alias__c, SSN__c, CalWINCasePhone__c, IsCalWINOkToText__c,
                    CalWINIndividualPhone__c, CalWINEmail__c, IsCalWINOkToEmail__c, AlternatePhone__c,IsAlternateOkToText__c,
                    AlternateEmail__c, IsAlternateOkToEmail__c, MailingAddr1__c, MailingAddr2__c, MailingAddrCity__c,
                    MailingAddrStateId__c, MailingAddrZip__c, ResidentialAddr1__c, ResidentialAddr2__c, ResidentialAddrCity__c,
                    ResidentialAddrStateId__c, ResidentialAddrZip__c, CaseNumber__c, CurrentCaseStatus__c, CaseStatusDate__c,
                    CWIN__c, HouseholdTypeId__c, IsInHome__c, Month48TimeOnAidClock__c, WtW24MonthClock__c,
                    Month12VocationalTrainingClock__c, EthnicityId__c, DOB__c, GenderId__c, IsVeteran__c, PreferredLanguage__c,
                    IsHomeless__c, MiddleName__c, Email__c, IsCISClient__c, IsJAMSClient__c, IsActive__c, AddedAt__c,
                    ClientSource__c, AlternateZipCode__c, Mi__c, Sufx__c
                FROM Data_Feed__c
                WHERE Source_File__c = 'cisrawclient.csv'
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {
        List<String> contactKeys = new List<String>();
        List<String> calwinsCaseKeys = new List<String>();

        // Build list of compsite keys for finding existing Contacts and CalWIN_Case__c objects
        for (Data_Feed__c dataFeed : scope) {
            contactKeys.add(dataFeed.CWIN__c);
            calwinsCaseKeys.add(dataFeed.ClientID__c);
        }

        // Build maps for existing Contacts and CalWIN_Case__c objects
        Map<String, Contact> existingContacts = getExistingContacts(contactKeys);
        Map<String, CalWINs_Case__c> existingCalswinsCases = getExistingCalWinsCases(calwinsCaseKeys);

        // Loop through Data_Feed__c and Populate Contact or CalWINs_Case__c
        Set<Contact> contactsToUpsert = new Set<Contact>();
        Set<CalWINs_Case__c> calwinsCasesToUpsert = new Set<CalWINs_Case__c>();
        Map<String, CalWINs_Case__c> calwinsCasesToInsert = new Map<String, CalWINs_Case__c>();
        for (Data_Feed__c dataFeed : scope) {
            // Populate Contact
            contactsToUpsert.add(mapContactValues(dataFeed, existingContacts.get(dataFeed.CWIN__c)));

            // Populate CalWINs_Case__c
            CalWINs_Case__c calwinsCase = existingCalswinsCases.get(dataFeed.ClientID__c);
            if (calwinsCase != null) {
                calwinsCasesToUpsert.add(mapCaseValues(dataFeed, calwinsCase));
            } else {
                // Add new CalWIN_Case__c to map w/key so we can lookup related Contact later
                // Note: Using compound key since there could be multiple cases per contact
                //       The key is later split and only the CWIN value is used to find the related Contact
                calwinsCasesToInsert.put(dataFeed.ClientID__c + ':' + dataFeed.CWIN__c, mapCaseValues(dataFeed, calwinsCase));
            }

            // Update business status to Processed
            //dataFeed.Business_Status__c = 'Processed';
        }

        // Upsert contacts
        List<Contact> contactsToUpsertList = new List<Contact>();
        contactsToUpsertList.addAll(contactsToUpsert);
        processUpsertResultList(Database.upsert(contactsToUpsertList, Contact.Fields.Id, false), 'Contact');

        // Upsert existing CalWINs_Case__c objects
        List<CalWINs_Case__c> calwinsCasesToUpsertList = new List<CalWINs_Case__c>();
        set<id> calwinIDs = new set<id>();
        for(CalWINs_Case__c crec: calwinsCasesToUpsert){
            if(!calwinsCasesToUpsertList.contains(crec) && !calwinIDs.contains(crec.id))
            {
                calwinsCasesToUpsertList.add(crec); 
                calwinIDs.add(crec.id);
            }
        }
       processUpsertResultList(Database.upsert(calwinsCasesToUpsertList, CalWINs_Case__c.Fields.Id, false), 'CalWINs_Case__c');

        // loop through CalWINs_Case__c to find any that don't have related Contacts and assign the Contact
        Map<String, Contact> contactKeyMap = getKeyMapToContacts(contactsToUpsert);
        for (String key : calwinsCasesToInsert.keySet()) {
            String cwin = key.split(':').get(1);
            Contact oContact = contactKeyMap.get(cwin);
            if (oContact != null) {
                calwinsCasesToInsert.get(key).Contact__c = oContact.Id;
            }
        }
        // Upsert new CalWINs_Case__c objects
        processUpsertResultList(Database.upsert(calwinsCasesToInsert.values(), CalWINs_Case__c.Fields.Id, false), 'CalWINs_Case__c');

        //update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

    // Map values from Data_Feed__c to CalWINs_Case__c
    private CalWINs_Case__c mapCaseValues(Data_Feed__c dataFeed, CalWINs_Case__c calwinsCase) {
        if (calwinsCase == null) {
            calwinsCase = new CalWINs_Case__c();
        }
        calwinsCase.Name = dataFeed.CaseNumber__c;
        calwinsCase.Case_Status__c = dataFeed.CurrentCaseStatus__c;
        calwinsCase.Case_Status_Date__c = dataFeed.CaseStatusDate__c;
        calwinsCase.CalWIN_ClientID__c = dataFeed.ClientID__c;
        return calwinsCase;
    }

    // Map values from Data_Feed__c to Contact
    private Contact mapContactValues(Data_Feed__c dataFeed, Contact oContact) {
        if (oContact == null) {
            oContact = new Contact();
        }
        oContact.CalWIN_ClientID__c = dataFeed.ClientID__c;
        oContact.LastName = dataFeed.LastName__c;
        oContact.FirstName = dataFeed.FirstName__c;
        oContact.CalWin_Alias__c = dataFeed.Alias__c;
        oContact.CalWIN_Case_Phone__c = dataFeed.CalWINCasePhone__c;
        oContact.CalWIN_Is_CalWIN_Ok_To_Text__c = dataFeed.IsCalWINOkToText__c;
        oContact.HomePhone = dataFeed.CalWINIndividualPhone__c;
        oContact.Email = dataFeed.CalWINEmail__c;
        oContact.HasOptedOutOfEmail = dataFeed.IsCalWINOkToEmail__c;
        oContact.CalWIN_Alternate_Phone__c = dataFeed.AlternatePhone__c;
        oContact.Alternate_Phone_Text_OK__c = dataFeed.IsAlternateOkToText__c;
        oContact.CalWIN_Alternate_Email__c = dataFeed.AlternateEmail__c;
        oContact.Alternate_Email_OK__c = dataFeed.IsAlternateOkToEmail__c;
        oContact.MailingStreet = dataFeed.MailingAddr1__c;
        oContact.MailingCity = dataFeed.MailingAddrCity__c;
        oContact.MailingState = dataFeed.MailingAddrStateId__c;
        oContact.MailingPostalCode = dataFeed.MailingAddrZip__c;
        oContact.OtherStreet = dataFeed.ResidentialAddr1__c;
        oContact.OtherCity = dataFeed.ResidentialAddrCity__c;
        oContact.OtherState = dataFeed.ResidentialAddrStateId__c;
        oContact.OtherPostalCode = dataFeed.ResidentialAddrZip__c;
        oContact.Launchpad__Case_Number__c = dataFeed.CaseNumber__c;
        //oContact.Current_Case_Status__c = dataFeed.CurrentCaseStatus__c;
        oContact.CalWIN_CWIN__c = dataFeed.CWIN__c;
        oContact.CalWIN_Household_Type_ID__c = dataFeed.HouseholdTypeId__c;
        oContact.CalWIN_Is_in_Home__c = dataFeed.IsInHome__c;
        if (dataFeed.Month48TimeOnAidClock__c != null) {
            oContact.CalWIN_Month_48_Time_on_Aid_Clock__c = Decimal.valueOf(dataFeed.Month48TimeOnAidClock__c);
        }
        if (dataFeed.WtW24MonthClock__c != null) {
            oContact.CalWIN_WtW_24_Month_Clock__c = Decimal.valueOf(dataFeed.WtW24MonthClock__c);
        }
        if (dataFeed.Month12VocationalTrainingClock__c != null) {
            oContact.CalWINMonth_12_Vocational_Training_Clock__c = Decimal.valueOf(dataFeed.Month12VocationalTrainingClock__c);
        }
        oContact.CalWIN_EthnicityID__c = dataFeed.EthnicityId__c;
        oContact.Birthdate = dataFeed.DOB__c;
        String genderId = dataFeed.GenderId__c == 'F' ? 'Female' : dataFeed.GenderId__c == 'M' ? 'Male' : '';
        oContact.CalWIN_GenderID__c = genderId;
        oContact.CalWIN_Is_Veteran__c = dataFeed.IsVeteran__c;
        oContact.Launchpad__Languages1__c = dataFeed.PreferredLanguage__c;
        oContact.CalWIN_Is_Homeless__c = dataFeed.IsHomeless__c;
        oContact.CalWIN_Is_CIS_Client__c = dataFeed.IsCISClient__c;
        oContact.CalWIN_Is_JAMS_Client__c = dataFeed.IsJAMSClient__c;
        oContact.Active__c = dataFeed.IsActive__c;
        oContact.LeadSource = dataFeed.ClientSource__c;
        oContact.CalWIN_Alternate_Zipcode__c = dataFeed.AlternateZipCode__c;
        oContact.MiddleName = dataFeed.Mi__c;
        oContact.Suffix = dataFeed.Sufx__c;
        try {
            oContact.Launchpad__Unique_ID_SSN__c = dataFeed.SSN__c;
        } catch (Exception e) {
            System.debug('Exception setting Contact.Launchpad__Unique_ID_SSN__c: ' + e.getMessage());
        }
        return oContact;
    }

    // Build map of existing Contacts
    private Map<String, Contact> getExistingContacts(List<String> keys) {
        Map<String, Contact> results = new Map<String, Contact>();

        for (Contact c : [
            SELECT CalWIN_ClientID__c, LastName, FirstName, CalWin_Alias__c, Launchpad__Unique_ID_SSN__c,
                CalWIN_Case_Phone__c, CalWIN_Is_CalWIN_Ok_To_Text__c, HomePhone, Email, HasOptedOutOfEmail,
                CalWIN_Alternate_Phone__c, Alternate_Phone_Text_OK__c, CalWIN_Alternate_Email__c,
                Alternate_Email_OK__c, MailingStreet, MailingCity, MailingState, MailingPostalCode,
                OtherStreet, OtherCity, OtherState, OtherPostalCode, Launchpad__Case_Number__c,
                Current_Case_Status__c, CalWIN_CWIN__c, CalWIN_Household_Type_ID__c, CalWIN_Is_in_Home__c,
                CalWIN_Month_48_Time_on_Aid_Clock__c, CalWIN_WtW_24_Month_Clock__c,
                CalWINMonth_12_Vocational_Training_Clock__c, CalWIN_EthnicityID__c, Birthdate,
                CalWIN_GenderID__c, CalWIN_Is_Veteran__c, Launchpad__Languages1__c, CalWIN_Is_Homeless__c,
                MiddleName, CalWIN_Is_CIS_Client__c, CalWIN_Is_JAMS_Client__c, Active__c, LeadSource,
                CalWIN_Alternate_Zipcode__c, Suffix
            FROM Contact
            WHERE CalWIN_CWIN__c IN :keys
        ]) {
            results.put(c.CalWIN_CWIN__c, c);
        }

        return results;
    }

    // Build map of existing CalWINs_Case__c objects
    private Map<String, CalWINs_Case__c> getExistingCalWinsCases(List<String> keys) {
        Map<String, CalWINs_Case__c> results = new Map<String, CalWINs_Case__c>();

        for (CalWINs_Case__c calwinsCase : [
            SELECT Name, Case_Status__c, Case_Status_Date__c, Contact__c, CalWIN_ClientID__c
            FROM CalWINs_Case__c
            WHERE CalWIN_ClientID__c IN: keys
        ]) {
            results.put(calwinsCase.CalWIN_ClientID__c, calwinsCase);
        }

        return results;
    }

    // Build map of key field to Contacts
    private Map<String, Contact> getKeyMapToContacts(Set<Contact> contacts) {
        Map<String, Contact> results = new Map<String, Contact>();
        for (Contact c : contacts) {
            if (c.CalWIN_CWIN__c != null) {
                results.put(c.CalWIN_CWIN__c, c);
            }
        }
        return results;
    }

    // Process UpsertResult errors in one method to help increase code coverage
    private void processUpsertResultList(Database.UpsertResult[] upsertResultList, String sObjectName) {
        for (Database.UpsertResult r : upsertResultList) {
            if (!r.isSuccess()) {
                for (Database.Error e : r.getErrors()) {
                    System.debug('Error upserting ' + sObjectName + ' - status code: ' + e.getStatusCode() + ';  Message: ' + e.getMessage() + '; Fields that affected this error: ' + e.getFields());
                }
            }
        }
    }

}