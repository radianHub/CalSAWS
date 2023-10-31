/***************************************************************************************************
Name        : DataFeedToESProgram_Batch
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Dec 2017
Description : This batch process will read unprocessed Data Feed records that are marked as being
	from the cisrawclientesprogram.csv source file. It will then update or add new CIS_ES_Program__c
	records based on the Data Feed records.
Changes:
***************************************************************************************************/
global class DataFeedToESProgram_Batch implements Schedulable, Database.Batchable<sObject> {

	String query;
	Map<String, Contact> contactMap;

	global DataFeedToESProgram_Batch() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT AddedAt__c, AssignedUnit__c, CaseNumber__c, CaseStatus__c, CaseStatusDate__c,
				CISRawClientESProgramId__c, ES__c, ESfirst__c, ESlast__c, ESphone__c,
				ESProgram__c, IndividualESStatus__c, IndividualESStatusDate__c, CWIN_ES__c
			FROM Data_Feed__c
			WHERE Source_File__c = 'cisrawclientesprogram.csv' and CISRawClientESProgramId__c != null
		]);
	}

	global void execute(SchedulableContext sc) {
		id batchId = Database.executeBatch(new DataFeedToESProgram_Batch());
	}

	global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {
		List<String> programIds = new List<String>();
		List<String> cwins = new List<String>();

		for (Data_Feed__c dataFeed : scope) {
            if(dataFeed.CISRawClientESProgramId__c != null && dataFeed.CISRawClientESProgramId__c != '')
			programIds.add(dataFeed.CISRawClientESProgramId__c);
            if(dataFeed.CWIN_ES__c != null && dataFeed.CWIN_ES__c != '')
			cwins.add(dataFeed.CWIN_ES__c); 
		}

       
		// Get Contacts associated w/this batch of ES records
		contactMap = new Map<String, Contact>();
		List<Contact> contacts = [SELECT Id, CalWIN_CWIN__c FROM Contact WHERE CalWIN_CWIN__c IN :cwins];
		System.debug(cwins);
		for (Contact c : contacts) {
			System.debug(c.CalWIN_CWIN__c);
            if(c.CalWIN_CWIN__c != null)
			contactMap.put(c.CalWIN_CWIN__c, c);
		}

		Map<String, CIS_ES_Program__c> programMap = new Map<String, CIS_ES_Program__c>();
		for (CIS_ES_Program__c program : [
				SELECT AddedAt__c, AssignedUnit__c, CaseNumber__c, CaseStatus__c, CaseStatusDate__c,
					CISRawClientESProgramId__c, ES__c, ESfirst__c, ESlast__c, ESphone__c,
					ESProgram__c, IndividualESStatus__c, IndividualESStatusDate__c, CWIN__c
				FROM CIS_ES_Program__c
				WHERE CISRawClientESProgramId__c IN :programIds
			]) {
                if(program.CISRawClientESProgramId__c != null)
			programMap.put(program.CISRawClientESProgramId__c, program);
		}

		List<CIS_ES_Program__c> programs = new List<CIS_ES_Program__c>();
		for (Data_Feed__c dataFeed : scope) {
            
			CIS_ES_Program__c program = programMap.get(dataFeed.CISRawClientESProgramId__c);
			if (program == null) {
				program = new CIS_ES_Program__c();
			}
			program = mapProgramValues(dataFeed, program);

			programs.add(program);
			//dataFeed.Business_Status__c = 'Processed';
		}
		if (programs.size() > 0) {
			upsert programs;
		}
		//update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

	private CIS_ES_Program__c mapProgramValues(Data_Feed__c dataFeed, CIS_ES_Program__c program) {
		program.AddedAt__c = dataFeed.AddedAt__c;
		program.AssignedUnit__c = dataFeed.AssignedUnit__c;
		program.CaseNumber__c = dataFeed.CaseNumber__c;
		program.CaseStatus__c = dataFeed.CaseStatus__c;
		program.CaseStatusDate__c = dataFeed.CaseStatusDate__c;
		program.CISRawClientESProgramId__c = dataFeed.CISRawClientESProgramId__c;
		program.CWIN__c = dataFeed.CWIN_ES__c;
		program.ES__c = dataFeed.ES__c;
		program.ESfirst__c = dataFeed.ESfirst__c;
		program.ESlast__c = dataFeed.ESlast__c;
		program.ESphone__c = dataFeed.ESphone__c;
		program.ESProgram__c = dataFeed.ESProgram__c;
		program.IndividualESStatus__c = dataFeed.IndividualESStatus__c;
		program.IndividualESStatusDate__c = dataFeed.IndividualESStatusDate__c;
		if (dataFeed.CWIN_ES__c != null) {
			Contact c = contactMap.get(dataFeed.CWIN_ES__c);
			if (c != null) {
				program.Contact__c = c.Id;
			}
		}
		return program;
	}

}