public with sharing class CalSAWSProgram {
    
    public String caseNum;
    public String caseName;
    public String countyCode;
    public String pgmId;
    public String pgm;
    public String aidCode;
    public List<ProgramDetail> programDetail;
    public List<ProgramRedeterm> programRedeter;
    public List<ProgramPerson> programPerson;
    public List<ProgramAdmin> programAdmin;
    public List<StaffWorker> staffWorker;

    public class ProgramDetail {
        public String status;
        public Date begDate;
        public String statRsn;
        public String reportingType;
    }

    public class ProgramRedeterm {
        public Date reDueDate;
        public Date reBegDate;
        public String reStatRsn;
        public Date sarDueDate;
    }

    public class ProgramPerson {
        public String persId;
        public String persName;
        public String persStat;
        public String persStatRsn;
        public Date persBegDate;
        public List<PersonContact> persContact;
    }

    public class PersonContact {
        public String phType;
        public String phNum;
    }

    public class ProgramAdmin {
        public String secondPayeePrefix;
        public String adminCode;
        public String persId;
        public String persName;
        public String orgId;
        public String orgName;
        public String payeeSubTypeCode;
        public String authRepNumIdentif;
        public Date begDate;
        public String ltcMcRePacketRecipInd;
    }

    public class StaffWorker {
        public String worker;
        public String workerNum;
        public String unitName;
        public String unitNumIdentif;
        public String officeName;
        public String officeNumIdentif;
        public String secondPgmAssignInd;
        public Date begDate;
        public Date endDate;
    }

    public static void upsertPrograms(Map<String, String> cinContactMap, Map<String, List<CalSAWSProgram>> cinProgramMap) {

        if (cinProgramMap != null && cinProgramMap.size() > 0) {
            Set<CalSAWS_Program__c> progToUpsert = new Set<CalSAWS_Program__c>();

            List<CalSAWS_Program__c> existingProgs = [
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
                WHERE
                    Contact__r.CIN__c IN :cinContactMap.keySet()
            ];

            Set<String> progIds = new Set<String>();
            Set<String> progCins = new Set<String>();
            for (CalSAWS_Program__c prog : existingProgs) {
                progCins.add(prog.Contact__r.CIN__c);
                progIds.add(prog.Program_Id__c);
            }
            
            for (String cin : cinProgramMap.keySet()) {
                for (CalSAWS_Program__c existingProg : existingProgs) {
                    if (progCins.contains(cin) && existingProg.Contact__r.CIN__c == cin) {
                        if (cinProgramMap.get(cin) != null) {
                            for (CalSAWSProgram prog : cinProgramMap.get(cin)) {
                                if (progIds.contains(prog.pgmId) && existingProg.Program_Id__c == prog.pgmId) {
                                    for (CalSAWSProgram.ProgramDetail progDetail : prog.programDetail) {
                                        existingProg.Program_Status__c = progDetail.status;
                                        existingProg.Program_Status_Reason__c = progDetail.statRsn;
                                        existingProg.Program_Begin_Date__c = progDetail.begDate;
                                    }
                                    if (prog.programRedeter != null && prog.programRedeter.size() > 0) {
                                        List<Date> redetermDates = new List<Date>();
                                        for (CalSAWSProgram.ProgramRedeterm progRed : prog.programRedeter) {
                                            if (progRed != null) { 
                                                redetermDates.add(progRed.reDueDate);
                                            }
                                        }
                                        redetermDates.sort();
                                        existingProg.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
                                    }
                                    if (prog.staffWorker != null && prog.staffWorker.size() > 0) {
                                        for (CalSAWSProgram.StaffWorker sw : prog.staffWorker) {
                                            existingProg.Worker__c = sw.worker;
                                            existingProg.Worker_Number__c = sw.workerNum;
                                            existingProg.Worker_Begin_Date__c = sw.begDate;
                                            if (sw.endDate.year() != 9999) {
                                                existingProg.Worker_End_Date__c = sw.endDate;
                                            }
                                        }
                                    }
                                    progToUpsert.add(existingProg); 
                                } else if (!progIds.contains(prog.pgmId)) {
                                    CalSAWS_Program__c program = new CalSAWS_Program__c(
                                        Name = prog.pgm,
                                        Program_Id__c = prog.pgmId,
                                        Case_Number__c = prog.caseNum,
                                        Contact__c = cinContactMap.get(cin)
                                    );
                                    for (CalSAWSProgram.ProgramDetail progDetail : prog.programDetail) {
                                        program.Program_Status__c = progDetail.status;
                                        program.Program_Status_Reason__c = progDetail.statRsn;
                                        program.Program_Begin_Date__c = progDetail.begDate;
                                    }
                                    if (prog.programRedeter != null && prog.programRedeter.size() > 0) {
                                        List<Date> redetermDates = new List<Date>();
                                        for (CalSAWSProgram.ProgramRedeterm progRed : prog.programRedeter) {
                                            if (progRed != null) { 
                                                redetermDates.add(progRed.reDueDate);
                                            }
                                        }
                                        redetermDates.sort();
                                        program.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
                                    }
                                    if (prog.staffWorker != null && prog.staffWorker.size() > 0) {
                                        for (CalSAWSProgram.StaffWorker sw : prog.staffWorker) {
                                            program.Worker__c = sw.worker;
                                            program.Worker_Number__c = sw.workerNum;
                                            program.Worker_Begin_Date__c = sw.begDate;
                                            if (sw.endDate.year() != 9999) {
                                                program.Worker_End_Date__c = sw.endDate;
                                            }
                                        }
                                    }
                                    progToUpsert.add(program);
                                }
                            }
                        }
                    }
                }
                
                if (!progCins.contains(cin)) {
                    if (cinProgramMap.get(cin) != null) {
                        for (CalSAWSProgram program : cinProgramMap.get(cin)) {
                            CalSAWS_Program__c prog = new CalSAWS_Program__c(
                                Name = program.pgm,
                                Program_Id__c = program.pgmId,
                                Case_Number__c = program.caseNum,
                                Contact__c = cinContactMap.get(cin)
                            );
                            for (CalSAWSProgram.ProgramDetail progDetail : program.programDetail) {
                                prog.Program_Status__c = progDetail.status;
                                prog.Program_Status_Reason__c = progDetail.statRsn;
                                prog.Program_Begin_Date__c = progDetail.begDate;
                            }
                            if (program.programRedeter != null && program.programRedeter.size() > 0) {
                                List<Date> redetermDates = new List<Date>();
                                for (CalSAWSProgram.ProgramRedeterm progRed : program.programRedeter) {
                                    if (progRed != null) { 
                                        redetermDates.add(progRed.reDueDate);
                                    }
                                }
                                redetermDates.sort();
                                prog.Redetermination_Due_Date__c = redetermDates[redetermDates.size()-1];
                            }
                            if (program.staffWorker != null && program.staffWorker.size() > 0) {
                                for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
                                    prog.Worker__c = sw.worker;
                                    prog.Worker_Number__c = sw.workerNum;
                                    prog.Worker_Begin_Date__c = sw.begDate;
                                    if (sw.endDate.year() != 9999) {
                                        prog.Worker_End_Date__c = sw.endDate;
                                    }
                                }
                            }
                            progToUpsert.add(prog);
                        }
                    }
                }
            }

            List<CalSAWS_Program__c> progToUpsertList = new List<CalSAWS_Program__c>();
            progToUpsertList.addAll(progToUpsert);
            CalSAWSUtilities.processUpsertResultList(Database.upsert(progToUpsertList, false), 'CalSAWS_Program__c'); 

            List<Contact> conToUpdate = new List<Contact>();
            for (String cin : cinProgramMap.keySet()) {
                if (cinProgramMap.get(cin) != null && cinProgramMap.get(cin).size() > 0) {
                    String worker;
                    for (CalSAWSProgram program : cinProgramMap.get(cin)) {
                        if (program.pgm == 'Welfare to Work') {
                            if (program.staffWorker != null && program.staffWorker.size() > 0) {
                                for (CalSAWSProgram.StaffWorker sw : program.staffWorker) {
                                    worker = sw.worker; 
                                }
                            } else {
                                worker = 'No worker named';
                            }
                        }
                    }
                    if (cinContactMap.get(cin) != null) {
                        Contact con = new Contact(
                            Id = cinContactMap.get(cin),
                            CalWORKs_ES__c = worker
                        );
                        conToUpdate.add(con);
                    }
                }   
            }
            if (conToUpdate.size() > 0) {
                update conToUpdate;
            }
        }
    }
}