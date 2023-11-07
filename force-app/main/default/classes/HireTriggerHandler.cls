/*********************************************************************************************************
**  Class Name  : HireTriggerHandler
**  Created By  : Revelant Technologies
*                 John Wrightsman - john.wrightsman@revelanttech.com
**  Created Date: 07/25/2017
**  Description : Trigger handler for Launchpad__Hire__c
**  Change Log  :
**
********************************************************************************************************/
public class HireTriggerHandler {
	static List<Launchpad__Applicant_Tracking__c> jobApplications;
	static Map<ID, Schema.RecordTypeInfo> hireRecordTypes;

	static Map<String, Id> recordTypeMap {
		get {
			if (hireRecordTypes == null) {
				hireRecordTypes = Launchpad__Hire__c.sObjectType.getDescribe().getRecordTypeInfosById();
				recordTypeMap = new Map<String, Id>();
				for (Id rId : hireRecordTypes.keySet()) {
					recordTypeMap.put(hireRecordTypes.get(rId).getName(), rId);
				}
			}
			return recordTypeMap;
		}
	}

	/**
	 * Populates the Job_Application__c lookup field on the Launchpad__Hire__c object with the Job Application that created the Hire object
	 * Copies the record type (by name) from the Job Application to the Hire object
	 * @param - List<Launchpad__Hire__c> - Trigger.New map
	 **/
	public static void populateJobApplication(List<Launchpad__Hire__c> hires) {
		List<Id> contactIds = new List<Id>();
        //DateTime dateRangeStart = datetime.now().addMinutes(-10);
		for (Launchpad__Hire__c hire : hires) {
			contactIds.add(hire.Launchpad__Applicant_Tracking__c); // Note that the lookup to the contact is misnamed Applicant Tracking on the Hire object
		}

		jobApplications = [SELECT Id, Launchpad__Participant__c, RecordType.Name,
							Launchpad__Job_Order__c, Launchpad__Date_of_Hire__c,
							Launchpad__Hours_Per_Week__c, LastModifiedDate
							FROM Launchpad__Applicant_Tracking__c
							WHERE Launchpad__Participant__c IN :contactIds
							ORDER BY LastModifiedDate DESC];

        for (Launchpad__Hire__c hire : hires) {
			Launchpad__Applicant_Tracking__c jobApplication = findJobApplication(hire);
			if (jobApplication != null) {
				hire.Job_Application__c = jobApplication.Id;
				hire.Hours_per_Week__c = jobApplication.Launchpad__Hours_Per_Week__c;
				if (recordTypeMap.containsKey(jobApplication.RecordType.Name)) {
					hire.recordTypeId = recordTypeMap.get(jobApplication.RecordType.Name);
				}
			}
		}
	}

	/**
	 * Finds the Launchpad__Applicant_Tracking__c (Job Application) that matches the Launchpad__Hire__c (Hire) object
	 * @param - Launchpad__Hire__c
	 **/
	private static Launchpad__Applicant_Tracking__c findJobApplication(Launchpad__Hire__c hire) {
		for (Launchpad__Applicant_Tracking__c jobApplication : jobApplications) {
			if (hire.Launchpad__Applicant_Tracking__c == jobApplication.Launchpad__Participant__c &&
				hire.Launchpad__Job__c == jobApplication.Launchpad__Job_Order__c &&
				hire.Launchpad__Hire_Date__c == jobApplication.Launchpad__Date_of_Hire__c) {
					return jobApplication;
			 }
		}
		return null;
	}
}