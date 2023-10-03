public with sharing class CalSAWSCase_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    List<List<CalSAWSCase>> caseList;
    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;
    Set<String> caseNumbs;

    public CalSAWSCase_Batch(List<List<CalSAWSCase>> caseList, Map<String, String> endpoints, Map<String, Contact> cinContactMap) {
        this.caseList = caseList;
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;

        for (List<CalSAWSCase> personsCases : caseList) {
            for (CalSAWSCase cases : personsCases) {
                for (CalSAWSCase.Cases sawsCase : cases.cases) {
                    this.caseNumbs.add(sawsCase.caseNum);
                }
            }
        }
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
                Contact__c
            FROM
                CalWINs_Case__c
            WHERE
                Contact__r.CIN__c IN :cinNumbs
        ]);
    }

    public void execute(Database.BatchableContext BC, List<CalWINs_Case__c> scope) {
        Set<CalWINs_Case__c> caseToUpsert = new Set<CalWINs_Case__c>();

        for (CalWINs_Case__c existingCs : scope) {
            if (caseNumbs.contains(existingCs.Case_Number__c)) {
                for (List<CalSAWSCase> personsCases : caseList) {
                    for (CalSAWSCase cs : personsCases) {
                        for (CalSAWSCase.Cases sawsCase : cs.cases) {
                            if (existingCs.Case_Number__c == sawsCase.caseNum) {
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
                            }
                        }
                    }
                }
            } else {
                for (List<CalSAWSCase> personsCases : caseList) {
                    for (CalSAWSCase cs : personsCases) {
                        for (CalSAWSCase.Cases sawsCase : cs.cases) {
                            CalWINs_Case__c newCs = new CalWINs_Case__c();
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

        List<CalWINs_Case__c> caseToUpsertList = new List<CalWINs_Case__c>();
        caseToUpsertList.addAll(caseToUpsert);
        CalSAWSUtilities.processUpsertResultList(Database.upsert(caseToUpsertList, false), 'CalWINs_Case__c');
    }

    public void finish(Database.BatchableContext BC) {

    }
}