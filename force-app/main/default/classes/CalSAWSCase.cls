public with sharing class CalSAWSCase {

    public Integer persId;
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
}