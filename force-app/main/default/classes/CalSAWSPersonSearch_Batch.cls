public with sharing class CalSAWSPersonSearch_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;

    public CalSAWSPersonSearch_Batch(Map<String, String> endpoints) {
        this.endpoints = endpoints;
        this.cinContactMap = new Map<String, Contact>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT
                Id,
                CIN__c,
                Launchpad__Unique_ID_SSN__c,
                CalWIN_CWIN__c,
                CalWIN_ClientID__c,
                FirstName,
                LastName,
                MiddleName,
                Suffix,
                Birthdate,
                CalWIN_GenderID__c,
                Email,
                CalWIN_EthnicityID__c,
                Phone,
                MobilePhone,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                OtherStreet,
                OtherCity,
                OtherState,
                OtherPostalCode,
                Launchpad__Case_Number__c,
                Case_Number_2__c
            FROM
                Contact

        ]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<Contact> conToUpsert = new Set<Contact>();

        for (Contact con : scope) {
            if (con.Launchpad__Unique_ID_SSN__c != null) {
                CalSAWSPerson per = CalSAWSUtilities.processPerson(endpoints, con.Launchpad__Unique_ID_SSN__c);

                con.CalWIN_ClientID__c = String.valueOf(per.persId);
                con.CIN__c = per.cin;
                con.Birthdate = per.dob;
                con.CalWIN_GenderID__c = per.gender;
                con.Email = per.emailAddr;
                for (CalSAWSPerson.Phones phone : per.phNumbers) {
                    switch on phone.type {
                        when 'Home' {
                            con.Phone = phone.phNum;
                        }
                        when 'Cell' {
                            con.MobilePhone = phone.phNum;
                        }
                    } 
                }
                for (CalSAWSPerson.Address addr : per.addr) {
                    switch on addr.type {
                        when 'Mailing' {
                            con.MailingStreet = addr.line1Addr + ' ' + addr.line2Addr;
                            con.MailingCity = addr.cityName;
                            con.MailingState = addr.stateCode;
                            con.MailingPostalCode = addr.zipCodeNum;
                        }
                        when 'Physical' {
                            con.OtherStreet = addr.line1Addr + ' ' + addr.line2Addr;
                            con.OtherCity = addr.cityName;
                            con.OtherState = addr.stateCode;
                            con.OtherPostalCode = addr.zipCodeNum; 
                        }
                    }
                }
                if (per.cases.size() == 1) {
                    con.Launchpad__Case_Number__c = per.cases[0].caseNum;
                }
                if (per.cases.size() == 2) {
                    con.Case_Number_2__c = per.cases[1].caseNum;
                }

                conToUpsert.add(con);
                cinContactMap.put(per.cin, con);
            }
        }

         // * UPSERT CONTACTS
         List<Contact> conToUpsertList = new List<Contact>();
         conToUpsertList.addAll(conToUpsert);
         CalSAWSUtilities.processUpsertResultList(Database.upsert(conToUpsertList, false), 'Contact');
    }

    public void finish(Database.BatchableContext BC) {
        // * CHAIN THE NEXT BATCH PROCESS (CASES)
        CalSAWSUtilities.processCases(endpoints, cinContactMap);
    }
}