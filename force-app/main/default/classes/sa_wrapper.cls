//Wrapper class for Service Activity (Launchpad__Enrollment__c) 
public class sa_wrapper{
    public cls_records[] records;
    public class cls_records {
        public String name; 
        public String ChildcareReferralStatus;
        public string ChildCareID; 
        public Date FirstDayofChildCare;
        
    }
    public static sa_wrapper parse(String json){
        return (sa_wrapper) System.JSON.deserialize(json, sa_wrapper.class);
    }
}