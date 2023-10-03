public with sharing class CalSAWSProgram {
    
    public String caseNum;
    public String caseName;
    public String countyCode;
    public Integer pgmId;
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
        public Integer persId;
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
        public Integer persId;
        public String persName;
        public Integer orgId;
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
}