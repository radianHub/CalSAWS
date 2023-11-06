/***************************************************************************************************
Name        : DataFeedToEthnicity_Batch_Test
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Jan 2018
Description : Unit Test class for DataFeedToEthnicity_Batch
Changes:
***************************************************************************************************/
@isTest
private class DataFeedToEthnicity_Batch_Test{

    @isTest
    static void testBatch() {
    	Data_Feed__c df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawethnicity.csv',
    		AddedAt__c = Date.today(),
    		CWIN__c = '1'
    	);
    	insert df;

        Test.startTest();
        DataFeedToEthnicity_Batch batch = new DataFeedToEthnicity_Batch();
        SchedulableContext sc;
        batch.execute(sc);
        Test.stopTest();
    }

}