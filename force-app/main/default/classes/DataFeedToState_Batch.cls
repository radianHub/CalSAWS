/***************************************************************************************************
Name        : DataFeedToState_Batch
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Dec 2017
Description : This batch process will read unprocessed Data Feed records that are marked as being
	from the cisrawstate.csv source file. It will then update or add new CIS_State__c
	records based on the Data Feed records.
Changes:
***************************************************************************************************/
global class DataFeedToState_Batch implements Schedulable, Database.Batchable<sObject> {

	String query;

	global DataFeedToState_Batch() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT CISRawStateName__c, CISRawStateId__c, CISRawCode__c
			FROM Data_Feed__c
			WHERE Source_File__c = 'cisrawstate.csv'
		]);
	}

	global void execute(SchedulableContext sc) {
		id batchId = Database.executeBatch(new DataFeedToState_Batch());
	}

   	global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {
		List<String> stateNames = new List<String>();

		for (Data_Feed__c dataFeed : scope) {
			stateNames.add(dataFeed.CISRawStateName__c);
		}

		Map<String, CIS_State__c> statesMap = new Map<String, CIS_State__c>();
		for (CIS_State__c state : [
				SELECT CISRawStateName__c, CISRawStateId__c, CISRawCode__c
				FROM CIS_State__c
				WHERE CISRawStateName__c IN :stateNames
			]) {
			statesMap.put(state.CISRawStateName__c, state);
		}

		List<CIS_State__c> states = new List<CIS_State__c>();
		for (Data_Feed__c dataFeed : scope) {
			CIS_State__c state = statesMap.get(dataFeed.CISRawStateName__c);
			if (state == null) {
				state = new CIS_State__c();
			}
			states.add(mapStateValues(dataFeed, state));
			//dataFeed.Business_Status__c = 'Processed';
		}
		if (states.size() > 0) {
			upsert states;
		}
		//update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

	private CIS_State__c mapStateValues(Data_Feed__c dataFeed, CIS_State__c state) {
		state.CISRawStateName__c = dataFeed.CISRawStateName__c;
		state.CISRawStateId__c = dataFeed.CISRawStateId__c;
		state.CISRawCode__c = dataFeed.CISRawCode__c;
		return state;
	}

}