/***************************************************************************************************
Name        : DataFeedToCalWinProgram_Batch_Test
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Jan 2018
Description : Unit Test class for DataFeedToCalWinProgram_Batch
Changes:
***************************************************************************************************/
@isTest
private class DataFeedToCalWinProgram_Batch_Test{

    @isTest
    static void testBatch() {

    	Data_Feed__c df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawclientcalwinprogram.csv',
    		AddedAt__c = Date.today(),
    		CISRawClientCalWinProgramId__c = '1',
    		CWIN__c = '1'
    	);
    	insert df;

        Test.startTest();
        DataFeedToCalWinProgram_Batch batch = new DataFeedToCalWinProgram_Batch();
        SchedulableContext sc;
        batch.execute(sc);
        Test.stopTest();
    }

}