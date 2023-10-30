/***************************************************************************************************
Name        : DataFeedToCalWinProgram_Batch
Created By  : John Wrightsman, Revelant Technologies
Email       : john.wrightsman@revelanttech.com
Created Date: Dec 2017
Description : This batch process will read unprocessed Data Feed records that are marked as being
	from the cisrawclientcalwinprogram.csv source file. It will then update or add new CIS_CalWin_Program__c
	records based on the Data Feed records.
Changes:
***************************************************************************************************/
global class DataFeedToCalWinProgram_Batch implements Schedulable, Database.Batchable<sObject> {

	Map<String, Id> contactIdMap;
	String query;

	global DataFeedToCalWinProgram_Batch() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT AddedAt__c, CaseNumber__c, CaseProgramStatus__c, CaseStatusDate__c,
				CWIN_CalWinProgram__c, IndividualParticipationStatus__c, IndividualStatus__c,
				IndividualStatusDate__c, Program__c, CISRawClientCalWinProgramId__c
			FROM Data_Feed__c
			WHERE Source_File__c = 'cisrawclientcalwinprogram.csv' and CISRawClientCalWinProgramId__c != null
		]);
	}

	global void execute(SchedulableContext sc) {
		id batchId = Database.executeBatch(new DataFeedToCalWinProgram_Batch());
	}

   	global void execute(Database.BatchableContext BC, List<Data_Feed__c> scope) {
		List<String> programIds = new List<String>();
		List<String> calwins = new List<String>();

		// Gather lookup keys
		for (Data_Feed__c dataFeed : scope) {
            if(dataFeed.CISRawClientCalWinProgramId__c != null && dataFeed.CISRawClientCalWinProgramId__c != '')
			programIds.add(dataFeed.CISRawClientCalWinProgramId__c);
            if(dataFeed.CWIN_CalWinProgram__c != null && dataFeed.CWIN_CalWinProgram__c != '')
			calwins.add(dataFeed.CWIN_CalWinProgram__c);
		}

		// Populate lookup maps
		Map<String, CIS_CalWin_Program__c> programMap = getProgramMap(programIds);
		populateContactIdMap(calwins);

		// Loop through scope to create CIS_CalWin_Program__c for each record
		List<CIS_CalWin_Program__c> programs = new List<CIS_CalWin_Program__c>();
		for (Data_Feed__c dataFeed : scope) {
			CIS_CalWin_Program__c program = programMap.get(dataFeed.CISRawClientCalWinProgramId__c);
			if (program == null) {
				program = new CIS_CalWin_Program__c();
			}
			programs.add(mapProgramValues(dataFeed, program));
			//dataFeed.Business_Status__c = 'Processed';
		}
		if (programs.size() > 0) {
			upsert programs;
		}
		//update scope;
	}

	/**
     * @description: Populates the contactIdMap w/Contacts keyed on the program id
     * @param: cwin - List of CWIN keys
     **/
	private void populateContactIdMap(List<String> calwins) {
		contactIdMap = new Map<String, Id>();
		for (Contact oContact : [SELECT CalWIN_CWIN__c FROM Contact WHERE CalWIN_CWIN__c IN :calwins]) {
			contactIdMap.put(oContact.CalWIN_CWIN__c, oContact.Id);
		}
	}

	/**
     * @description: Populates a map w/CIS_CalWin_Program__c objects keyed on the program id
     * @param: programIds - List of program ids
     * @return:
     **/
	private Map<String, CIS_CalWin_Program__c> getProgramMap(List<String> programIds) {
		Map<String, CIS_CalWin_Program__c> programMap = new Map<String, CIS_CalWin_Program__c>();
		for (CIS_CalWin_Program__c program : [
				SELECT AddedAt__c, CaseNumber__c, CaseProgramStatus__c, CaseStatusDate__c, CWIN__c,
					IndividualParticipationStatus__c, IndividualStatus__c, IndividualStatusDate__c,
					Program__c, CISRawClientCalWinProgramId__c
				FROM CIS_CalWin_Program__c
				WHERE CISRawClientCalWinProgramId__c IN :programIds 
			]) {
			programMap.put(program.CISRawClientCalWinProgramId__c, program);
		}
		return programMap;
	}

	global void finish(Database.BatchableContext BC) {

	}

	/**
     * @description: Maps values from the Data_Feed__c to the CIS_CalWin_Program__c
     * @param: dataFeed - Data_Feed__c object
     * @param: program - CIS_CalWin_Program__c object
     * @return: CIS_CalWin_Program__c
     **/
	private CIS_CalWin_Program__c mapProgramValues(Data_Feed__c dataFeed, CIS_CalWin_Program__c program) {
		program.AddedAt__c = dataFeed.AddedAt__c;
		program.CaseNumber__c = dataFeed.CaseNumber__c;
		program.CaseProgramStatus__c = dataFeed.CaseProgramStatus__c;
		program.CaseStatusDate__c = dataFeed.CaseStatusDate__c;
		program.CWIN__c = dataFeed.CWIN_CalWinProgram__c ;
		program.IndividualParticipationStatus__c = dataFeed.IndividualParticipationStatus__c;
		program.IndividualStatus__c = dataFeed.IndividualStatus__c;
		program.IndividualStatusDate__c = dataFeed.IndividualStatusDate__c;
		program.Program__c = dataFeed.Program__c;
		program.CISRawClientCalWinProgramId__c = dataFeed.CISRawClientCalWinProgramId__c;
		if (dataFeed.CWIN_CalWinProgram__c  != null && dataFeed.CWIN_CalWinProgram__c  != '') {
			program.Contact__c = contactIdMap.get(dataFeed.CWIN_CalWinProgram__c);
		}
		return program;
	}

}