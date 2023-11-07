/***************************************************************************************************
Name        : DataFeedToState_Batch_Test
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Jan 2018
Description : Unit Test class for DataFeedToState_Batch
Changes:
***************************************************************************************************/
@isTest
private class DataFeedToState_Batch_Test{

    @isTest
    static void testBatch() {
    	Data_Feed__c df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawstate.csv',
    		AddedAt__c = Date.today(),
    		CWIN__c = '1'
    	);
    	insert df;

        Test.startTest();
        DataFeedToState_Batch batch = new DataFeedToState_Batch();
        SchedulableContext sc;
        batch.execute(sc);
        Test.stopTest();
    }

}