public class CalSAWSPerson_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    List<CalSAWSPerson> personList;
    Map<String, String> endpoints;
    Set<String> personIds;
    Map<String, Contact> cinContactMap;

    public CalSAWSPerson_Batch(List<CalSAWSPerson> personList, Map<String, String> endpoints) {
        this.personList = personList;
        this.endpoints = endpoints;
        this.personIds = new Set<String>();
        for (CalSAWSPerson person : personList) {
            personIds.add(person.cin);
        }
        this.cinContactMap = new Map<String, Contact>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        // * QUERY FOR EXISTING CONTACTS WITH GIVEN PERSON IDS
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
            WHERE 
                CIN__c IN :personIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<Contact> conToUpsert = new Set<Contact>();
        Set<String> cins = new Set<String>();

        for (Contact con : scope) {
            cins.add(con.CIN__c);
        }

        for (Contact existingCon : scope) {
            for (CalSAWSPerson person : personList) {
                // * UPDATE FIELDS OF EXISTING CONTACTS
                if (cins.contains(person.cin) && person.cin == existingCon.CIN__c) {
                    existingCon.CalWIN_ClientID__c = person.persId;
                    existingCon.Birthdate = person.dob;
                    existingCon.CalWIN_GenderId__c = person.gender;
                    existingCon.Email = person.emailAddr;
                    if (person.ethnicity != null && person.ethnicity.size() > 0) {
                        existingCon.CalWIN_EthnicityID__c = person.ethnicity[0].raceType;
                    }

                    if (person.phNumbers != null && person.phNumbers.size() > 0) {
                        for (CalSAWSPerson.Phones phone : person.phNumbers) {
                            switch on phone.type {
                                when 'Home' {
                                    existingCon.Phone = phone.phNum;
                                }
                                when 'Cell' {
                                    existingCon.MobilePhone = phone.phNum;
                                }
                            }
                        }
                    }

                    if (person.addr != null && person.addr.size() > 0) {
                        for (CalSAWSPerson.Address address : person.addr) {
                            switch on address.type {
                                when 'Mailing' {
                                    existingCon.MailingStreet = address.line1Addr + ' ' + address.line2Addr;
                                    existingCon.MailingCity = address.cityName;
                                    existingCon.MailingState = address.stateCode;
                                    existingCon.MailingPostalCode = address.zipCodeNum;
                                }
                                when 'Physical' {
                                    existingCon.OtherStreet = address.line1Addr + ' ' + address.line2Addr;
                                    existingCon.OtherCity = address.cityName;
                                    existingCon.OtherState = address.stateCode;
                                    existingCon.OtherPostalCode = address.zipCodeNum; 
                                }
                            }
                        }
                    }

                    if (person.cases.size() == 1) {
                        existingCon.Launchpad__Case_Number__c = person.cases[0].caseNum;
                    }
                    
                    if (person.cases.size() == 2) {
                        existingCon.Case_Number_2__c = person.cases[1].caseNum;
                    }
                    conToUpsert.add(existingCon);
                    cinContactMap.put(existingCon.CIN__c, existingCon);
                } else if (!cins.contains(person.cin)) {

                    // * CREATE NEW CONTACT IF ONE IS NOT FOUND
                    Contact con = new Contact(
                        CalWIN_ClientID__c = person.persId,
                        CIN__c = person.cin,
                        FirstName = person.firstName,
                        LastName = person.lastName,
                        Suffix = person.nameSuffix,
                        MiddleName = person.midName,
                        Birthdate = person.dob,
                        Launchpad__Unique_ID_SSN__c = person.ssn,
                        CalWIN_GenderID__c = person.gender,
                        Email = person.emailAddr,
                        Launchpad__Languages1__c = person.spokenLang
                    );
                        
                    if (person.ethnicity != null && person.ethnicity.size() > 0) {
                        con.CalWIN_EthnicityID__c = person.ethnicity[0].raceType;
                    }

                    if (person.phNumbers != null && person.phNumbers.size() > 0) {
                        for (CalSAWSPerson.Phones phone : person.phNumbers) {
                            switch on phone.type {
                                when 'Home' {
                                    con.Phone = phone.phNum;
                                }
                                when 'Cell' {
                                    con.MobilePhone = phone.phNum;
                                }
                            }
                        }
                    }

                    if (person.addr != null && person.addr.size() > 0) {
                        for (CalSAWSPerson.Address address : person.addr) {
                            switch on address.type {
                                when 'Mailing' {
                                    con.MailingStreet = address.line1Addr + ' ' + address.line2Addr;
                                    con.MailingCity = address.cityName;
                                    con.MailingState = address.stateCode;
                                    con.MailingPostalCode = address.zipCodeNum;
                                }
                                when 'Physical' {
                                    con.OtherStreet = address.line1Addr + ' ' + address.line2Addr;
                                    con.OtherCity = address.cityName;
                                    con.OtherState = address.stateCode;
                                    con.OtherPostalCode = address.zipCodeNum; 
                                }
                            }
                        }
                    }

                    if (person.cases.size() == 1) {
                        con.Launchpad__Case_Number__c = person.cases[0].caseNum;
                    }

                    if (person.cases.size() == 2) {
                        con.Case_Number_2__c = person.cases[1].caseNum;
                    }
                    conToUpsert.add(con);
                    cinContactMap.put(con.CIN__c, con);
                }
            }
        }

        // * UPSERT CONTACTS
        List<Contact> conToUpsertList = new List<Contact>();
        conToUpsertList.addAll(conToUpsert);
        CalSAWSUtilities.processUpsertResultList(Database.upsert(conToUpsertList, false), 'Contact');
    }

    public void finish(Database.BatchableContext BC) {

        // * CHAIN THE NEXT BATCH PROCESS (CASES)
        if (!Test.isRunningTest()) {
            CalSAWSUtilities.processCases(endpoints, cinContactMap);
        }
    }
}