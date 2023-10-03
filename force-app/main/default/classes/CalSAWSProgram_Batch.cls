public with sharing class CalSAWSProgram_Batch implements Database.Batchable<sObject>, Database.Stateful {

    Map<String, String> endpoints;
    Map<String, Contact> cinContactMap;
    Map<String, List<CalSAWSProgram>> cinProgramMap;
    Set<String> progIds;

    public CalSAWSProgram_Batch(Map<String, String> endpoints, Map<String, Contact> cinContactMap, Map<String, List<CalSAWSProgram>> cinProgramMap) {
        this.cinProgramMap = cinProgramMap;
        this.endpoints = endpoints;
        this.cinContactMap = cinContactMap;

        for (String cin : cinProgramMap.keyset()) {
            for (CalSAWSProgram program : cinProgramMap.get(cin)) {
                this.progIds.add(String.valueOf(program.pgmId));
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT
                Id,
                Name,
                CaseNumber__c,
                CaseProgramStatus__c,
                CaseStatusDate__c,
                Contact__c,
                IndividualParticipationStatus__c,
                IndividualStatus__c,
                IndividualStatusDate__c,
                Program__c
            FROM
                CIS_CalWin_Program__c
            WHERE
                Program__c IN :progIds
        ]);
    }

    public void execute(Database.BatchableContext BC, List<CIS_CalWin_Program__c> scope) {
        Set<CIS_CalWin_Program__c> progToUpsert = new Set<CIS_CalWin_Program__c>();

        for (CIS_CalWin_Program__c existingProg : scope) {
            if (progIds.contains(existingProg.Program__c) && cinProgramMap.keySet().contains(existingProg.Contact__r.CIN__c)) {
                for (CalSAWSProgram program : cinProgramMap.get(existingProg.Contact__r.CIN__c)) {
                    if (existingProg.Program__c == String.valueOf(program.pgmId)) {
                        for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
                            existingProg.CaseProgramStatus__c = progDetail.status;
                            existingProg.IndividualParticipationStatus__c = progDetail.statRsn;
                            existingProg.CaseStatusDate__c = progDetail.begDate;
                        }
                        for (CalSAWSProgram.ProgramPerson persDetail : program.programPerson) {
                            existingProg.IndividualStatus__c = persDetail.persStat;
                            existingProg.IndividualStatusDate__c = persDetail.persBegDate;
                        }
                        progToUpsert.add(existingProg);
                    }
                }
            } else {
                for (String cin : cinProgramMap.keySet()) {
                    for (CalSAWSProgram program : cinProgramMap.get(cin)) {
                        CIS_CalWin_Program__c prog = new CIS_CalWin_Program__c(
                            Name = program.pgm,
                            Program__c = String.valueOf(program.pgmId),
                            CaseNumber__c = program.caseNum,
                            Contact__c = cinContactMap.get(cin).Id
                        );
                        for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
                            prog.CaseProgramStatus__c = progDetail.status;
                            prog.IndividualParticipationStatus__c = progDetail.statRsn;
                            prog.CaseStatusDate__c = progDetail.begDate;
                        }
                        for (CalSAWSProgram.ProgramPerson persDetail : program.programPerson) {
                            prog.IndividualStatus__c = persDetail.persStat;
                            prog.IndividualStatusDate__c = persDetail.persBegDate;
                        }

                        progToUpsert.add(prog);
                    }
                }
            }
        }

        List<CIS_CalWin_Program__c> progToUpsertList = new List<CIS_CalWin_Program__c>();
        progToUpsertList.addAll(progToUpsert);
        CalSAWSUtilities.processUpsertResultList(Database.upsert(progToUpsertList, false), 'CIS_CalWin_Program__c');
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch Chaining Complete');
    }
}