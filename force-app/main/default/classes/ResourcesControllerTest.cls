@isTest 
private class ResourcesControllerTest {
    static testMethod void validate() {
        Test.startTest();
        ResourcesController obj=new ResourcesController();
        Resource__c rr=new Resource__c(Resource_Category__c ='Child & Family',name='test');
        insert rr;
        ResourcesController.getPicklistvalues('Resource__c', 'Resource_Category__c', true);
        ResourcesController.fetchResourcesData('Resource__c');
        
        contact cc= new contact();
        cc.firstname ='test';
        cc.lastname = 'test';
        insert cc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Job Seeker Community Profile'];
        
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1234@testorg.com', ContactId  = cc.Id);
        Insert usr;
        
        Goal__c gol = new Goal__c();
        gol.Date__c = System.today();
        gol.Goal__c = 'test Goal descp';
        gol.Do_you_need_to_send_any_Forms_Documents__c = 'No';
        gol.Client__c = cc.id;
        Insert gol;
        
        step__c stp = new step__c();
        stp.Step__c = 'Step 1';
        stp.Status__c = 'In progress';
        stp.Goal__c = gol.id;
        Insert stp;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a document',
            PathOnClient   = 'Pic.docx',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = cc.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        ResourcesController.getFileData(cc.id);
        ResourcesController.DownloadAttachment(documents[0].id);
        ResourcesController.createintrst(rr.id);
        ResourcesController.fetchGoalData();
         ResourcesController.allGoals();
        ResourcesController.updateStep(gol.Id,'goal__c');
        CreateGoal.getContact();
        Test.stopTest();
    }
      static testMethod void listValidate() {
        Test.startTest();
          listViewController.listValues('goal__c');
        
          Test.stopTest();
      }
}