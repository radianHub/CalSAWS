public with sharing class CalSAWSCase_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;
    Map<String, List<CalSAWSCase>> cinCaseMap;
    Integer recordCount = 0;

    public CalSAWSCase_Batch(Map<String, String> endpoints, Map<String, Contact> cinContactMap, Map<String, List<CalSAWSCase>> cinCaseMap) {
        this.cinCaseMap = cinCaseMap;
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> cinNumbs = cinContactMap.keySet();

        return Database.getQueryLocator([
            SELECT
                CAlWIN_ClientID__c,
                Name,
                Case_Number__c,
                Case_Status__c,
                Case_Status_Date__c,
                Contact__c,
                Contact__r.CIN__c
            FROM
                CalWINs_Case__c
            WHERE
                Contact__r.CIN__c IN :cinNumbs
        ]);
    }

    public void execute(Database.BatchableContext BC, List<CalWINs_Case__c> scope) {
        Set<CalWINs_Case__c> caseToUpsert = new Set<CalWINs_Case__c>();

        for (CalWINs_Case__c existingCs : scope) {
            if (cinCaseMap != null  && cinCaseMap.size() > 0) {
                if (cinCaseMap.get(existingCs.Contact__r.CIN__c) != null) {
                    for (CalSAWSCase cs : cinCaseMap.get(existingCs.Contact__r.CIN__c)) {
                        for (CalSAWSCase.Cases sawsCase : cs.cases) {
                            if (existingCs.Case_Number__c == sawsCase.caseNum) {
                                recordCount++;
                                existingCs.CalWIN_ClientID__c = cinContactMap.get(cs.cin).CalWIN_ClientID__c;
                                existingCs.Contact__c = cinContactMap.get(cs.cin).Id;
                                Date caseDate;
                                for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                    if (caseDate == null) {
                                        caseDate = csFlag.begDate;
                                    } else if (csFlag.begDate > caseDate) {
                                        caseDate = csFlag.begDate;
                                    }
                                }
                                existingCs.Case_Status_Date__c = caseDate;
                                existingCS.Name = sawsCase.caseName;
    
                                caseToUpsert.add(existingCs);                        
                            } else {
                                recordCount++;
                                CalWINs_Case__c newCs = new CalWINs_Case__c();
                                newCs.Case_Number__c = sawsCase.caseNum;
                                newCs.Name = sawsCase.caseName;
                                newCs.CalWIN_ClientID__c = cinContactMap.get(cs.cin).CalWIN_ClientID__c;
                                newCs.Contact__c = cinContactMap.get(cs.cin).Id;
                                Date caseDate;
                                for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                    if (caseDate == null) {
                                        caseDate = csFlag.begDate;
                                    } else if (csFlag.begDate > caseDate) {
                                        caseDate = csFlag.begDate;
                                    }
                                }
                                newCs.Case_Status_Date__c = caseDate;
    
                                caseToUpsert.add(newCs);
                            }
                        }
                    }   
                }
            }
        }

        List<CalWINs_Case__c> caseToUpsertList = new List<CalWINs_Case__c>();
        caseToUpsertList.addAll(caseToUpsert);
        CalSAWSUtilities.processUpsertResultList(Database.upsert(caseToUpsertList, false), 'CalWINs_Case__c');
    }

    public void finish(Database.BatchableContext BC) {
        if (recordCount == 0 ) {
            List<CalWINs_Case__c> newCasesToInsert = new List<CalWINs_Case__c>();

            if (cinCaseMap != null && cinCaseMap.size() > 0) {
                for (String cin : cinCaseMap.keySet()) {
                    if (cinCaseMap.get(cin) != null) {
                        for (CalSAWSCase cs : cinCaseMap.get(cin)) {
                            for (CalSAWSCase.Cases sawsCase : cs.cases) {
                                CalWINs_Case__c newCs = new CalWINs_Case__c();
                                newCs.Case_Number__c = sawsCase.caseNum;
                                newCs.Name = sawsCase.caseName;
                                newCs.CalWIN_ClientID__c = cinContactMap.get(cs.cin).CalWIN_ClientID__c;
                                newCs.Contact__c = cinContactMap.get(cs.cin).Id;
                                Date caseDate;
                                for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                    if (caseDate == null) {
                                        caseDate = csFlag.begDate;
                                    } else if (csFlag.begDate > caseDate) {
                                        caseDate = csFlag.begDate;
                                    }
                                }
                                newCs.Case_Status_Date__c = caseDate;
        
                                newCasesToInsert.add(newCs);
                            }
                        }
                    }
                }
    
                insert newCasesToInsert;
            }
        } else {
            // * CHAIN THE NEXT BATCH PROCESS (PROGRAM)
            if (!Test.isRunningTest()) {
                CalSAWSUtilities.processPrograms(endpoints, cinContactMap);
            }
        }
    }
}