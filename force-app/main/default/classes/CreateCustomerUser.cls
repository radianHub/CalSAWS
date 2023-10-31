public class CreateCustomerUser {
@InvocableMethod
    Public static void CreateCommunityUser(List<Id> conids){
        
        Organization Org = [Select Id, Name, IsSandbox From Organization];
        
        Profile portalProfile = [Select Id From Profile WHERE Name = 'MyLaunchpad Community Profile' Limit 1];
        Set<string> Accids = new set<string>();
        
        List<Contact> lstCon = [Select Id,Email,FirstName,Lastname,AccountId from Contact where id =: conids];
              
        
        List<User> lstUsr = [Select Id From User WHERE ContactID=: lstCon[0].Id AND Isactive =: True Limit 1];
        If(lstUsr.size()== 0)
        {
            string nick = lstCon[0].FirstName!=null?lstCon[0].FirstName:'';
            nick += Datetime.now().getTime();
            string als = lstCon[0].Firstname.substring(0, 1) + lstCon[0].Lastname.substring(0, 3);
            string usrnme = '';
            If(org.IsSandbox)
            {
                string orgid = Org.Id;
                usrnme = lstCon[0].Email + orgid.substring(0, 5);
            }
                
            else
                 usrnme = lstCon[0].Email + 'sfhsa';
            
            User usr = new User(
                UserName = usrnme,
                FirstName = lstCon[0].FirstName,
                LastName = lstCon[0].LastName,
                Alias =  als,
                email = lstCon[0].email,
                ContactId = lstCon[0].Id,
                ProfileId = portalProfile.Id,
                EmailEncodingKey = 'ISO-8859-1',
                CommunityNickname = nick ,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            
            string userId='';
       		try {
               insert usr;
                System.Debug(userId);
            } 
            catch(Exception ex) {
               System.Debug('Error '+ex.getMessage());
             }
        }
    
    }
}