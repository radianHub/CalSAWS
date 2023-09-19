@isTest(SeeAllData=true)
public class RHX_TEST_Launchpad_Hire {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Launchpad__Hire__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Launchpad__Hire__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}