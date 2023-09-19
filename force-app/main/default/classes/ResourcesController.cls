public class ResourcesController {
    
    @AuraEnabled
    public static list<PkLstWrapper> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();   
         List<PkLstWrapper> PkLstWrapperObj = new List<PkLstWrapper>(); 
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
        if(nullRequired == true){
            optionlist.add('--None--');
        }       
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        AggregateResult[] groupedResults
                  = [SELECT count(id), Resource_Category__c
                      FROM Resource__c 
                      GROUP BY Resource_Category__c ];
                for (AggregateResult ar : groupedResults)  {
                    System.debug('Campaign ID' + ar.get('Resource_Category__c'));
                    System.debug('Average amount' + ar.get('expr0'));
                    PkLstWrapper obj=new PkLstWrapper();
                    obj.PkLstVal = (string)ar.get('Resource_Category__c');
                     obj.RecCount = (Integer) ar.get('expr0');
                    PkLstWrapperObj.add(obj);
                }
        
      system.debug('PkLstWrapperObj '+PkLstWrapperObj);
        return PkLstWrapperObj;
    }
    
    @AuraEnabled
    public static list<Resource__c> fetchResourcesData(String objectName)
    {
        User usr = [Select Id, contactid from User Where id =: UserInfo.getUserId()];
        
        return [select id,name,description__c,Resource_Category__c ,Who_is_Eligible__c , Status__c ,Website__c
                ,(SELECT Id, Status__c  FROM Interested__r Where Contact__r.id =: usr.ContactId and Status__c != 'Closed') from Resource__c order by name];
    }
    @AuraEnabled
    public static list<ContentDocument> getFileData(string recordId)
    {
              set<id> CdId = new set<id>();
        for(ContentDocumentLink cd: [SELECT ContentDocument.title,ContentDocument.CreatedDate, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId])
        {
            CdId.add(cd.ContentDocumentId);
        }
        
        return [select id, title ,CreatedDate from ContentDocument where id = :CdId ];
      // return  [SELECT ContentDocument.title,ContentDocument.CreatedDate, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];
    }
    @AuraEnabled
    public static string DownloadAttachment(string DownloadAttachmentID)
   {
        system.debug('URlDownload ');
    ContentVersion oldCV = [Select Id,Title from ContentVersion Where ContentDocumentId=:DownloadAttachmentID and IsLatest = true ];
    String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
    String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download/'+oldCV.Id;
       system.debug('URlDownload '+URlDownload);
    return URlDownload;
    } 
    public class PkLstWrapper{
         @AuraEnabled
      public string PkLstVal ;
         @AuraEnabled
       public Integer RecCount;
    }
    
    @AuraEnabled
    public static void createintrst(string programid){
        
        try{ User usr = [Select Id, contactid from User Where id =: UserInfo.getUserId()];
        Contact con;
        if(usr!=null && usr.contactid != null)
        con = [Select Id, OwnerId from Contact where id =:usr.contactid ];
        //List<Interested__c> intrLst=new List<Interested__c>();     
        Interested__c intr=new Interested__c(); 
            //intrLst = [Select Id, Status__c From Interested__c Where Contact__c =:usr.ContactId And Resource__c =:programid Order By createddate desc limit 1 ];
            //if (intrLst.size()==0){
            intr.Contact__c = usr.ContactId != null ? usr.ContactId:null;
            intr.Resource__c = programid;
        	intr.Case_Worker__c = con != null && con.OwnerId != null ? con.OwnerId : null;
            intr.Status__c = 'New';
          
        insert intr;
            }
            /*else {
               intrLst[0].Status__c = 'New';
              Update intrLst;
            } 
           }*/
        catch(exception ee)
        {}
        
    }    
       @AuraEnabled
    public static list<Goal__c> allGoals(){ 
        User usr = [Select Id,contactid from User Where id =: UserInfo.getUserId()];
        return [Select id,name,Status__c, Goal__c from Goal__C 
                	where Client__r.id =: usr.ContactId ];
    }
    
    
    
   @AuraEnabled
    public static list<Goal__c> fetchGoalData()
    {
        User usr = [Select Id, contactid from User Where id =: UserInfo.getUserId()];
        return [Select id,name, Goal__c , Type_of_Goal__c ,Completed_Count__c,Total_Count__C, Status__c ,Created_by_me__c,(select id, name , step__c, Status__c from steps__r  order by Status__c) from Goal__C 
                	where Client__r.id =: usr.ContactId and Status__c = 'In progress' order by Type_of_Goal__c ];
    }
     @AuraEnabled
    public static void updateStep(string goalOrstepId,string ObjectName)
    {
        if(!string.isEmpty(ObjectName) && ObjectName == 'goal__c'){
        Goal__c stp= new Goal__c ();
        stp.id= goalOrstepId;
        stp.Status__c ='Completed';
        update stp;
        }
        else{
        step__c stp= new step__c();
        stp.id= goalOrstepId;
        stp.Status__c ='Completed';
        update stp;
        }
    }
    
}