public class CalSAWSPerson_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    List<CalSAWSPerson> personList;
    Set<String> personIds;

    public CalSAWSPerson_Batch(List<CalSAWSPerson> personList) {
        this.personList = personList;
        for (CalSAWSPerson person : personList) {
            this.personIds.add(String.valueOf(person.persId));
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([
            SELECT
                Id,
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
                MailingPostalCode
            FROM
                Contact
            WHERE
                CalWIN_CWIN__c IN :personIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<String> caseKeys = new Set<String>();
        Set<Contact> conToUpsert = new Set<Contact>();

        for (Contact existingCon : scope) {
            for (CalSAWSPerson person : personList) {
                System.debug('CalSAWS Person ' + person);
                System.debug('Contact ' + existingCon);
                if (personIds.contains(existingCon.CalWIN_CWIN__c)) {
                    if (existingCon.CalWIN_CWIN__c == String.valueOf(person.persId)) {
                        existingCon.Birthdate = person.dob;
                        existingCon.CalWIN_GenderId__c = person.gender;
                        existingCon.Email = person.emailAddr;
                        existingCon.CalWIN_EthnicityID__c = person.ethnicity[0].raceType;
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


                        conToUpsert.add(existingCon);
                    }  
                } else {
                    Contact con = new Contact(
                        CalWIN_CWIN__c = String.valueOf(person.persId),
                        FirstName = person.firstName,
                        LastName = person.lastName,
                        Suffix = person.nameSuffix,
                        MiddleName = person.midName,
                        Birthdate = person.dob,
                        Launchpad__Unique_ID_SSN__c = person.ssn,
                        CalWIN_GenderID__c = person.gender,
                        Email = person.emailAddr,
                        Launchpad__Languages1__c = person.spokenLang,
                        CalWIN_EthnicityID__c = person.ethnicity[0].raceType
                    );

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

                    conToUpsert.add(con);
                }
            }
        }

        List<Contact> conToUpsertList = new List<Contact>();
        conToUpsertList.addAll(conToUpsert);
        processUpsertResultList(Database.upsert(conToUpsertList, false), 'Contact');

    }

    public void finish(Database.BatchableContext BC) {
    }

    private void processUpsertResultList(Database.UpsertResult[] upsertResultList, String sObjName) {
        for (Database.UpsertResult r : upsertResultList) {
            if (!r.isSuccess()) {
                for (Database.Error e : r.getErrors()) {
                    System.debug(
                        'Error upserting ' + sObjName +
                        ' - status code: ' + e.getStatusCode() +
                        ';  Message: ' + e.getMessage() +
                        '; Fields that affected this error: ' + e.getFields()
                    );
                }
            }
        }
    }

}