/***************************************************************************************************
Name        : DataFeedPurge_Batch
Created By  : Padma Ramkumar, Revelant Technologies
Email       : padma.ramkumar@revelanttech.com
Created Date: OCt 2017
Description : This batch will  delete the Datafeed object that are processed and week old.
Changes: John Wrightsman - 2/22/2018 - Removed Business_Status__c = 'New' from query
***************************************************************************************************/

global class DataFeedPurge_Batch implements Schedulable,Database.Batchable<sObject> {


	global DataFeedPurge_Batch() {

	}

	global void execute(SchedulableContext sc) {
		id batchId = Database.executeBatch(new DataFeedPurge_Batch());
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id, Business_Status__c
			FROM Data_Feed__c
			WHERE Record_Age_In_Days__c >= 7
		]);
	}

	global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {

		System.debug('scope' + scope);
		delete scope;

	}

	global void finish(Database.BatchableContext BC) {

	}

}