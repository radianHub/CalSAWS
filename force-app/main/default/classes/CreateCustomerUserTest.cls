@isTest
public class CreateCustomerUserTest {
   
      static testMethod void CreateRec(){
        
    Recordtype rta =  [Select Id, Name from Recordtype WHERE Name =: 'Individual' AND SObjectType =: 'Account'];
    Recordtype rtc =  [Select Id, Name from Recordtype WHERE Name =: 'Job Seeker' AND SObjectType =: 'Contact'];
    
    Account a =  new Account (Name = 'Test Account', BillingStreet = 'Test St', BillingCity = 'City', 
                              BillingState = 'CA', BillingPostalCode = '22352' , BillingCountry = 'USA', RecordTypeid = rta.Id);
        Insert a;
    
    Contact c = new Contact (Firstname = 'Test FN', Lastname = 'Test LN', Email = 'Test@mail.com', AccountId = a.Id, RecordTypeid = rtc.id );
        Insert c;
          
    List<id> lstcon = new List<id>();
          lstcon.add(c.Id);
          CreateCustomerUser.CreateCommunityUser(lstcon);
    }
}