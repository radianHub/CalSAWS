public class CreateGoal {
@AuraEnabled
    public static string getContact() {
        List<user> Usr = 
                [SELECT Id, contactID FROM user where id =: userinfo.getUserId()];
	return Usr[0].ContactId != null ? Usr[0].ContactId:null;
        
    }
}