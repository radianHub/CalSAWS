public with sharing class CalSAWSProgram_Batch implements Database.Batchable<sObject> {

    // Map<String, String> endpoints;
    // Map<String, Contact> cinContactMap;
    // Map<String, List<CalSAWSProgram>> cinProgramMap;
    // Integer recordCount = 0;

    // public CalSAWSProgram_Batch(Map<String, String> endpoints, Map<String, Contact> cinContactMap, Map<String, List<CalSAWSProgram>> cinProgramMap) {
    //     this.cinProgramMap = cinProgramMap;
    //     this.endpoints = endpoints;
    //     this.cinContactMap = cinContactMap;
    // }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Set<String> cinNumbs = cinContactMap.keySet(); 

        return Database.getQueryLocator([
            SELECT
                Id,
                Name,
                Case_Number__c,
                Program_Id__c,
                Program_Begin_Date__c,
                Redetermination_Due_Date__c,
                Program_Status__c,
                Program_Status_Reason__c,
                Worker__c,
                Worker_Number__c,
                Worker_Begin_Date__c,
                Worker_End_Date__c,
                Contact__c,
                Contact__r.CIN__c
            FROM
                CalSAWS_Program__c
            LIMIT 1
        ]);
    }

    public void execute(Database.BatchableContext BC, List<CalSAWS_Program__c> scope) {
        // Set<CalSAWS_Program__c> progToUpsert = new Set<CalSAWS_Program__c>();
        // Set<String> progIds = new Set<String>();

        // for (CalSAWS_Program__c existingProg : scope) {
        //     progIds.add(existingProg.Program_Id__c);
        // }

        // for (CalSAWS_Program__c existingProg : scope) {
        //     if (cinProgramMap != null && cinProgramMap.size() > 0) {
        //         if (cinProgramMap.get(existingProg.Contact__r.CIN__c) != null) {
        //             for (CalSAWSProgram program : cinProgramMap.get(existingProg.Contact__r.CIN__c)) {
        //                 if (progIds.contains(program.pgmId) && existingProg.Program_Id__c == program.pgmId) {
        //                     recordCount++;
        //                     for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
        //                         existingProg.Program_Status__c = progDetail.status;
        //                         existingProg.Program_Status_Reason__c = progDetail.statRsn;
        //                         existingProg.Program_Begin_Date__c = progDetail.begDate;
        //                     }
        //                     if (program.programRedeter != null && program.programRedeter.size() > 0) {
        //                         List<Date> redetermDates = new List<Date>();
        //                         for (CalSAWSProgram.ProgramRedeterm progRed : program.programRedeter) {
        //                             if (progRed != null) { 
        //                                 redetermDates.add(progRed.reDueDate);
        //                             }
        //                         }
        //                         redetermDates.sort();
        //                         existingProg.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
        //                     }
        //                     if (program.staffWorker != null && program.staffWorker.size() > 0) {
        //                         for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
        //                             existingProg.Worker__c = sw.worker;
        //                             existingProg.Worker_Number__c = sw.workerNum;
        //                             existingProg.Worker_Begin_Date__c = sw.begDate;
        //                             if (sw.endDate.year() != 9999) {
        //                                 existingProg.Worker_End_Date__c = sw.endDate;
        //                             }
        //                         }
        //                     }
        //                     progToUpsert.add(existingProg); 
        //                 } else if (!progIds.contains(program.pgmId)) {
        //                     recordCount++;
        //                     CalSAWS_Program__c prog = new CalSAWS_Program__c(
        //                         Name = program.pgm,
        //                         Program_Id__c = program.pgmId,
        //                         Case_Number__c = program.caseNum,
        //                         Contact__c = existingProg.Contact__c
        //                     );
        //                     for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
        //                         prog.Program_Status__c = progDetail.status;
        //                         prog.Program_Status_Reason__c = progDetail.statRsn;
        //                         prog.Program_Begin_Date__c = progDetail.begDate;
        //                     }
        //                     if (program.programRedeter != null && program.programRedeter.size() > 0) {
        //                         List<Date> redetermDates = new List<Date>();
        //                         for (CalSAWSProgram.ProgramRedeterm progRed : program.programRedeter) {
        //                             if (progRed != null) { 
        //                                 redetermDates.add(progRed.reDueDate);
        //                             }
        //                         }
        //                         redetermDates.sort();
        //                         prog.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
        //                     }
        //                     if (program.staffWorker != null && program.staffWorker.size() > 0) {
        //                         for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
        //                             prog.Worker__c = sw.worker;
        //                             prog.Worker_Number__c = sw.workerNum;
        //                             prog.Worker_Begin_Date__c = sw.begDate;
        //                             if (sw.endDate.year() != 9999) {
        //                                 prog.Worker_End_Date__c = sw.endDate;
        //                             }
        //                         }
        //                     }
        //                     progToUpsert.add(prog);
        //                 }
        //             }
        //         }
        //     }
        // }

        // List<CalSAWS_Program__c> progToUpsertList = new List<CalSAWS_Program__c>();
        // progToUpsertList.addAll(progToUpsert);
        // CalSAWSUtilities.processUpsertResultList(Database.upsert(progToUpsertList, false), 'CalSAWS_Program__c');
    }

    public void finish(Database.BatchableContext BC) {
        // if (recordCount == 0) {
        //     List<CalSAWS_Program__c> progToInsert = new List<CalSAWS_Program__c>();
        //     for (String cin : cinProgramMap.keySet()) {
        //         if (cinProgramMap.get(cin) != null && cinProgramMap.get(cin).size() > 0) {
        //             for (CalSAWSProgram program : cinProgramMap.get(cin)) {
        //                 CalSAWS_Program__c prog = new CalSAWS_Program__c(
        //                     Name = program.pgm,
        //                     Program_Id__c = program.pgmId,
        //                     Case_Number__c = program.caseNum,
        //                     Contact__c = cinContactMap.get(cin).Id
        //                 );
        //                 for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
        //                     prog.Program_Status__c = progDetail.status;
        //                     prog.Program_Status_Reason__c = progDetail.statRsn;
        //                     prog.Program_Begin_Date__c = progDetail.begDate;
        //                 }
        //                 if (program.programRedeter != null && program.programRedeter.size() > 0) {
        //                     List<Date> redetermDates = new List<Date>();
        //                     for (CalSAWSProgram.ProgramRedeterm progRed : program.programRedeter) {
        //                         if (progRed != null) { 
        //                             redetermDates.add(progRed.reDueDate);
        //                         }
        //                     }
        //                     redetermDates.sort();
        //                     prog.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
        //                 }
        //                 if (program.staffWorker != null && program.staffWorker.size() > 0) {
        //                     for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
        //                         prog.Worker__c = sw.worker;
        //                         prog.Worker_Number__c = sw.workerNum;
        //                         prog.Worker_Begin_Date__c = sw.begDate;
        //                         if (sw.endDate.year() != 9999) {
        //                             prog.Worker_End_Date__c = sw.endDate;
        //                         }
        //                     }
        //                 }
        //                 progToInsert.add(prog);
        //             }
        //         }
        //     }

        //     insert progToInsert;
        // }  

        // List<Contact> conToUpdate = new List<Contact>();
        // for (String cin : cinProgramMap.keySet()) {
        //     if (cinProgramMap.get(cin) != null && cinProgramMap.get(cin).size() > 0) {
        //         String worker;
        //         for (CalSAWSProgram program : cinProgramMap.get(cin)) {
        //             if (program.pgm == 'Welfare to Work') {
        //                 if (program.staffWorker != null && program.staffWorker.size() > 0) {
        //                     for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
        //                         worker = sw.worker; 
        //                     }
        //                 } else {
        //                     worker = 'No worker named';
        //                 }
        //             }
        //         }
        //         if (cinContactMap.get(cin).Id != null) {
        //             Contact con = new Contact(
        //                 Id = cinContactMap.get(cin).Id,
        //                 CalWORKs_ES__c = worker
        //             );
        //             conToUpdate.add(con);
        //         }
        //     }   
        // }
        // if (conToUpdate.size() > 0) {
        //     update conToUpdate;
        // }
        
        // System.debug('Batch Chaining Complete');
    }
}