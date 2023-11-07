@isTest
private class DataFeedToContact_Case_Batch_Test{

    @isTest
    static void test_method_DataFeedToContact_Case_Batch() {

    	Data_Feed__c df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawclient.csv',
    		FirstName__c = 'TestFirstName',
    		LastName__c = 'TestLastName',
    		AddedAt__c = Date.today(),
    		CWIN__c = '111',
    		ClientID__c = '222',
    		CaseNumber__c = '333',
			Month48TimeOnAidClock__c = '48',
			WtW24MonthClock__c = '24',
			Month12VocationalTrainingClock__c = '12'
    	);
    	insert df;

        Test.startTest();

		DataFeedToContact_Case_Batch batch = new DataFeedToContact_Case_Batch();
		SchedulableContext sc;
		batch.execute(sc);

		df = new Data_Feed__c(
    		Business_Status__c = 'New',
    		Source_File__c = 'cisrawclient.csv',
    		FirstName__c = 'TestFirstName',
    		LastName__c = 'TestLastName',
    		AddedAt__c = Date.today(),
    		CWIN__c = '222',
    		ClientID__c = '333',
    		CaseNumber__c = '444',
			Month48TimeOnAidClock__c = '48',
			WtW24MonthClock__c = '24',
			Month12VocationalTrainingClock__c = '12'
    	);
    	insert df;

		batch = new DataFeedToContact_Case_Batch(df.Id);
		batch.execute(sc);
        Test.stopTest();

    }

}