public with sharing class CalSAWSPerson {

    public Integer persId;
    public String countyCode;
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
    public String driveLic;
    public String maidenName;
    public String deceasDate;
    public List<Phones> phNumbers;
    public List<Address> addr;
    public List<ProgDetail> programDetail;
    public List<OtherName> otherNameDetail;
    public List<Cases> cases;
    public List<Ethnicity> ethnicity;
    public List<Income> incomes;

    public class Phones {
        public String type;
        public String phNum;
    }

    public class Address {
        public String type;
        public String cityName;
        public String line1Addr;
        public String line2Addr;
        public String stateCode;
        public String county;
        public String regn;
        public String zipCodeSuffix;
        public String zipCodeNum;
        public String country;
        public Boolean useDistrOfficeAddrInd;
    }

    public class ProgDetail {
        public Integer pgmId;
        public String pgm;
        public String pgmStatus;
    }

    public class OtherName {
        public Integer otherNameId;
        public String otherLastName;
        public String otherFirstName;
        public String otherMidName;
    }

    public class Cases {
        public String caseNum;
        public String caseName;
        public String countyCode;
    }

    public class Ethnicity {
        public String raceType;
        public String otherRaceDescr;
    }

    public class Income {
        public String category;
        public String type;
        public String employment;
        public String freq;
        public String incDescr;
        public List<IncAmount> incomeAmounts;
        public List<IncDetail> fcIncomeDetls;
    }

    public class IncAmount {
        public String program;
        public Integer amount;
        public String endRsnDescr;
        public Date begDate;
        public Date endDate;
    }

    public class IncDetail {
        public String exemptInd;
        public String exemptRsn;
        public Date begDate;
        public Date endDate;
    }

    public class PersonMethods implements Schedulable {
        public Map<String, String> endpoints;

        public PersonMethods() {
            List<CalSAWS_Endpoint__mdt> endpointList = [
                SELECT URL__c, MasterLabel
                FROM CalSAWS_Endpoint__mdt
            ];
            for (CalSAWS_Endpoint__mdt url : endpointList) {
                this.endpoints.put(url.MasterLabel, url.URL__c);
            }
        }

        public void execute(SchedulableContext sc) {
            List<CalSAWSPerson> personList = new List<CalSAWSPerson>();

            CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));

            // * FETCH NEW AND UPDATED PERSONS FOR THE PAST 48 HOURS
            List<CalSAWSPerson> getPersonList = CalSAWSCallouts.getPersons(token, endpoints.get('Persons'));

            // * FETCH GREATER DETAIL FOR EACH PERSON GATHERED PREVIOUSLY
            for (CalSAWSPerson person : getPersonList) {
                CalSAWSPerson personV2 = CalSAWSCallouts.getPersonById(
                    token,
                    endpoints.get('Persons'),
                    person.persId
                );
                personList.add(personV2);
            }

            // * START THE BATCH CHAINING PROCESS
            System.debug(':::STARTING PERSON BATCH:::');
            CalSAWSPerson_Batch b = new CalSAWSPerson_Batch(personList);
            Database.executeBatch(b);
        }
    }
}