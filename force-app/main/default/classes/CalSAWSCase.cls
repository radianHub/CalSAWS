public with sharing class CalSAWSCase {

    public String persId;
    public String ssn;
    public String cin;
    public String lastName;
    public String firstName;
    public String midName;
    public String nameSuffix;
    public Date dob;
    public String age;
    public String gender;
    public String emailAddr;
    public String spokenLang;
    public String writtenLang;
    public List<CalSAWSPerson.Ethnicity> ethnicity;
    public List<CalSAWSPerson.Phones> phNumbers;
    public List<CalSAWSPerson.Address> addr;
    public List<Cases> cases;


    public class Cases {
        public String caseNum;
        public String caseName;
        public List<ConfidentialFlag> confidentialFlags;
        public List<CaseFlag> caseFlags;
        public List<EApp> eappList;
    }

    public class ConfidentialFlag {
        public String comnt;
        public Date rmvdDate;
        public List<ConfidentialFlagType> confidentialFlagTypes;
    }

    public class ConfidentialFlagType {
        public String confidFlagType;
    }

    public class CaseFlag {
        public String caseFlagType;
        public Date begDate;
        public Date endDate;
        public Date dueDate;
        public Date expireDate;
    }

    public class EApp {
        public String eappNum;
        public Date begDate;
        public Date endDate;
    }

    public static void upsertCases(Map<String, String> cinContactMap, Map<String, List<CalSAWSCase>> cinCaseMap) {

        if (cinCaseMap != null && cinCaseMap.size() > 0) {
            Set<CalWINs_Case__c> caseToUpsert = new Set<CalWINs_Case__c>();
    
            List<CalWINs_Case__c> existingCs = [
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
                    Contact__r.CIN__c IN :cinContactMap.keySet()
            ];

            Set<String> existingCins = new Set<String>();
            for (CalWINs_Case__c cs : existingCs) {
                existingCins.add(cs.Contact__r.CIN__c);
            }
    
            for (String cin : cinCaseMap.keySet()) {
                for (CalWINs_Case__c cs : existingCs) {
                    if (existingCins.contains(cin) && cs.Contact__r.CIN__c == cin) {
                        if (cinCaseMap.get(cin) != null) {
                            for (CalSAWSCase calCs : cinCaseMap.get(cin)) {
                                for (CalSAWSCase.Cases sawsCase : calCs.cases) {
                                    if (cs.Case_Number__c == sawsCase.caseNum) {
                                        cs.CalWIN_ClientID__c = calCs.persId;
                                        cs.Contact__c = cinContactMap.get(cin);
                                        Date caseDate;
                                        for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                            if (caseDate == null) {
                                                caseDate = csFlag.begDate;
                                            } else if (csFlag.begDate > caseDate) {
                                                caseDate = csFlag.begDate;
                                            }
                                        }
                                        cs.Case_Status_Date__c = caseDate;
                                        cs.Name = sawsCase.caseName;

                                        caseToUpsert.add(cs);
                                    } else {
                                        CalWINs_Case__c newCs = new CalWINs_Case__c();
                                        newCs.Case_Number__c = sawsCase.caseNum;
                                        newCs.Name = sawsCase.caseName;
                                        newCs.CalWIN_ClientID__c = calCs.persId;
                                        newCs.Contact__c = cinContactMap.get(cin);
                                        if (sawsCase.caseFlags != null && sawsCase.caseFlags.size() > 0) {
                                            Date caseDate;
                                            for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                                if (caseDate == null) {
                                                    caseDate = csFlag.begDate;
                                                } else if (csFlag.begDate > caseDate) {
                                                    caseDate = csFlag.begDate;
                                                }
                                            }
                                            newCs.Case_Status_Date__c = caseDate;
                                        }

                                        caseToUpsert.add(newCs);
                                    }
                                }
                            }
                        }
                    }
                }

                if (!existingCins.contains(cin)) {
                    if (cinCaseMap.get(cin) != null) {
                        for (CalSAWSCase calCs : cinCaseMap.get(cin)) {
                            for (CalSAWSCase.Cases sawsCase : calCs.cases) {
                                CalWINs_Case__c newCs = new CalWINs_Case__c();
                                newCs.Case_Number__c = sawsCase.caseNum;
                                newCs.Name = sawsCase.caseName;
                                newCs.CalWIN_ClientID__c = calCs.persId;
                                newCs.Contact__c = cinContactMap.get(cin);
                                if (sawsCase.caseFlags != null && sawsCase.caseFlags.size() > 0) {
                                    Date caseDate;
                                    for (CalSAWSCase.CaseFlag csFlag : sawsCase.caseFlags) {
                                        if (caseDate == null) {
                                            caseDate = csFlag.begDate;
                                        } else if (csFlag.begDate > caseDate) {
                                            caseDate = csFlag.begDate;
                                        }
                                    }
                                    newCs.Case_Status_Date__c = caseDate;
                                }
        
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
    }
}