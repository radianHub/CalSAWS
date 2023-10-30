/***************************************************************************************************
Name        : DataFeedToEthnicity_Batch
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Dec 2017
Description : This batch process will read unprocessed Data Feed records that are marked as being
	from the cisrawethnicity.csv source file. It will then update or add new CIS_Ethnicity__c
	records based on the Data Feed records.
Changes:
***************************************************************************************************/
global class DataFeedToEthnicity_Batch implements Schedulable, Database.Batchable<sObject> {

	String query;

	global DataFeedToEthnicity_Batch() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT CISRawEthnicityId__c, ETHIC_CD__c, ETHIC_DESC__c
			FROM Data_Feed__c
			WHERE Source_File__c = 'cisrawethnicity.csv'
		]);
	}

	global void execute(SchedulableContext sc) {
		id batchId = Database.executeBatch(new DataFeedToEthnicity_Batch());
	}

	global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {
		List<String> ethnicityIds = new List<String>();

		for (Data_Feed__c dataFeed : scope) {
			ethnicityIds.add(dataFeed.CISRawEthnicityId__c);
		}

		Map<String, CIS_Ethnicity__c> ethnicityMap = new Map<String, CIS_Ethnicity__c>();
		for (CIS_Ethnicity__c ethnicity : [
				SELECT CISRawEthnicityId__c, ETHIC_CD__c, ETHIC_DESC__c
				FROM CIS_Ethnicity__c
				WHERE CISRawEthnicityId__c IN :ethnicityIds
			]) {
			ethnicityMap.put(ethnicity.CISRawEthnicityId__c, ethnicity);
		}

		List<CIS_Ethnicity__c> ethnicities = new List<CIS_Ethnicity__c>();
		for (Data_Feed__c dataFeed : scope) {
			CIS_Ethnicity__c ethnicity = ethnicityMap.get(dataFeed.CISRawEthnicityId__c);
			if (ethnicity == null) {
				ethnicity = new CIS_Ethnicity__c();
			}
			ethnicities.add(mapEthnicityValues(dataFeed, ethnicity));
			//dataFeed.Business_Status__c = 'Processed';
		}
		if (ethnicities.size() > 0) {
			upsert ethnicities;
		}
		//update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

	private CIS_Ethnicity__c mapEthnicityValues(Data_Feed__c dataFeed, CIS_Ethnicity__c ethnicity) {
		ethnicity.CISRawEthnicityId__c = dataFeed.CISRawEthnicityId__c;
		ethnicity.ETHIC_CD__c = dataFeed.ETHIC_CD__c;
		ethnicity.ETHIC_DESC__c = dataFeed.ETHIC_DESC__c;
		return ethnicity;
	}
}