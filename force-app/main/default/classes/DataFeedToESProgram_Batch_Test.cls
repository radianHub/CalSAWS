/***************************************************************************************************
Name        : DataFeedToESProgram_Batch_Test
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Jan 2018
Description : Unit Test class for DataFeedToESProgram_Batch
Changes:
***************************************************************************************************/
@isTest
private class DataFeedToESProgram_Batch_Test{

    @isTest
    static void testBatch() {
    	Data_Feed__c df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawclientesprogram.csv',
            CISRawClientESProgramId__c ='1232',
    		AddedAt__c = Date.today(),
    		CWIN__c = '1'
    	);
    	insert df;

        Test.startTest();
        DataFeedToESProgram_Batch batch = new DataFeedToESProgram_Batch();
        SchedulableContext sc;
        batch.execute(sc);
        Test.stopTest();
    }

}