@istest(seeAlldata=true)
public class San_rt_senddata_Test {

    //Service Activity Update
  static testMethod void testSAupd() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
    //  Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
        String Json = '{"records" : [ {      "name" : "55474",      "ChildCareID" : "12345600",      "ChildcareReferralStatus":"Enrolled"  } ,{     "name" : "6381255",      "ChildCareID" : "12345699", "ChildcareReferralStatus":"Denied",      "FirstDayofChildCare": "2014-12-12"  } ,  {     "name" : "63851",      "ChildCareID" : "12345611",      "ChildcareReferralStatus":"Change submitted"  } ]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'launchpad_enrollment');
        request.addHeader('operation', 'update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    //Notes update
    static testMethod void testNotUpd() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
		String json=		'{'+
		'    "records": ['+
		'        {'+
		'            "ServiceActivityName": "55474",'+
		'            "CC3DateTime": "2018-01-04T18:50:10.000Z",'+
		'            "CC3UserName": "Test Reffer 1",'+
		'            "Name": "CC3 name 1",'+
		'            "Body": "Body vb"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "6385112",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Testing",'+
		'            "Name": "13255467",'+
		'            "Body": "Body 2"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63861",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Referred3",'+
		'            "Name": "12345621",'+
		'            "Body": "Referred2"'+
		'        }'+
		'    ]'+
		'}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'notes');
        request.addHeader('operation', 'Update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    
     //Notes insert
    static testMethod void testNotIns() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
		String json=		'{'+
		'    "records": ['+
		'        {'+
		'            "ServiceActivityName": "55474",'+
		'            "CC3DateTime": "2018-01-04T18:50:10.000Z",'+
		'            "CC3UserName": "Test Reffer 1",'+
		'            "Name": "CC3 name 1",'+
		'            "Body": "Body vb"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63851",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Testing",'+
		'            "Name": "13255467",'+
		'            "Body": "Body 2"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63861",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Referred3",'+
		'            "Name": "12345621",'+
		'            "Body": "Referred2"'+
		'        }'+
		'    ]'+
		'}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'notes');
        request.addHeader('operation', 'insert');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    
    // Negative tests 1

    static testMethod void testNeg1() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
		String json=		'{'+
		'    "records": ['+
		'        {'+
		'            "ServiceActivityName": "55474",'+
		'            "CC3DateTime": "2018-01-04T18:50:10.000Z",'+
		'            "CC3UserName": "Test Reffer 1",'+
		'            "Name": "CC3 name 1",'+
		'            "Body": "Body vb"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63851",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Testing",'+
		'            "Name": "13255467",'+
		'            "Body": "Body 2"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63861",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Referred3",'+
		'            "Name": "12345621",'+
		'            "Body": "Referred2"'+
		'        }'+
		'    ]'+
		'}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json1');
        request.addHeader('object', 'notes');
        request.addHeader('operation', 'Update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    
    // Negative tests 2

    static testMethod void testNeg2() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
		String json=		'{'+
		'    "records": ['+
		'        {'+
		'            "ServiceActivityName": "55474",'+
		'            "CC3DateTime": "2018-01-04T18:50:10.000Z",'+
		'            "CC3UserName": "Test Reffer 1",'+
		'            "Name": "CC3 name 1",'+
		'            "Body": "Body vb"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63851",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Testing",'+
		'            "Name": "13255467",'+
		'            "Body": "Body 2"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63861",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Referred3",'+
		'            "Name": "12345621",'+
		'            "Body": "Referred2"'+
		'        }'+
		'    ]'+
		'}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'notes1');
        request.addHeader('operation', 'Update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
        // Negative tests 3

    static testMethod void testNeg3() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
		String json=		'{'+
		'    "records": ['+
		'        {'+
		'            "ServiceActivityName": "55474",'+
		'            "CC3DateTime": "2018-01-04T18:50:10.000Z",'+
		'            "CC3UserName": "Test Reffer 1",'+
		'            "Name": "CC3 name 1",'+
		'            "Body": "Body vb"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63851",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Testing",'+
		'            "Name": "13255467",'+
		'            "Body": "Body 2"'+
		'        },'+
		'        {'+
		'            "ServiceActivityName": "63861",'+
		'            "CC3DateTime": "2018-01-04T18:50:11.000Z",'+
		'            "CC3UserName": "Referred3",'+
		'            "Name": "12345621",'+
		'            "Body": "Referred2"'+
		'        }'+
		'    ]'+
		'}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'notes');
        request.addHeader('operation', 'Update2');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    //Service Activity Neg 4
  static testMethod void testSANeg() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
        String Json = '{"records" : [ {      "name" : "63856",      "ChildCareID" : "12345600",      "ChildcareReferralStatus":"Enrolled"  } ,{     "name" : "6381255",      "ChildCareID" : "12345699", "ChildcareReferralStatus":"Denied",      "FirstDayofChildCare": "2014-12-12"  } ,  {     "name" : "63851",      "ChildCareID" : "12345611",      "ChildcareReferralStatus":"Change submitted"  } ]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'launchpad_enrollment');
        request.addHeader('operation', 'update1');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
      //Service Activity Update No Match
  static testMethod void testSAupdNoMat() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
        String Json = '{"records" : [ {      "name" : "63f526",      "ChildCareID" : "12345600",      "ChildcareReferralStatus":"Enrolled"  } ,{     "name" : "638122f55",      "ChildCareID" : "12345699", "ChildcareReferralStatus":"Denied",      "FirstDayofChildCare": "2014-12-12"  } ,  {     "name" : "63285f1",      "ChildCareID" : "12345611",      "ChildcareReferralStatus":"Change submitted"  } ]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'launchpad_enrollment');
        request.addHeader('operation', 'update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
    static testMethod void testNoCon() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
        String Json = '{"records" : [ {      "name" : "63f526",      "ChildCareID" : "12345600",      "ChildcareReferralStatus":"Enrolled"  } ,{     "name" : "638122f55",      "ChildCareID" : "12345699", "ChildcareReferralStatus":"Denied",      "FirstDayofChildCare": "2014-12-12"  } ,  {     "name" : "63285f1",      "ChildCareID" : "12345611",      "ChildcareReferralStatus":"Change submitted"  } ]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type1', 'application/json');
        request.addHeader('object', 'launchpad_enrollment');
        request.addHeader('operation', 'update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
   
    static testMethod void testParse() {
		String json='{'+
		'        "success": false,'+
		'        "recordId": null,'+
		'        "errors": ['+
		'            {'+
		'                "statusCode": "EXCEPTION_HAS_OCCURRED.",'+
		'                "message": "Invalid format: ",'+
		'                "fields": null'+
		'            }'+
		'        ]'+
		'    }';
		AC_Response obj = AC_Response.parse(json);
		System.assert(obj != null);
	}
     static testMethod void testNoConExp() {
      /* Launchpad__Enrollment__c  le= new Launchpad__Enrollment__c();
    	// le.name = '63856';
     	 le.Child_Care_ID__c = '12345600';
      le.Childcare_Referral_Status__c= 'Enrolled';
      insert le;*/
      //Launchpad__Enrollment__c le = [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c limit 1 ];
        String Json = ',{     "name" : "638122f55",      "ChildCareID" : "12345699", "ChildcareReferralStatus":"Denied",      "FirstDayofChildCare": "20134-12-12"  } ,  {     "name" : "63285f1",      "ChildCareID" : "12345611",      "ChildcareReferralStatus":"Change submitted"  } ]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('object', 'launchpad_enrollment');
        request.addHeader('operation', 'update');
        request.requestUri ='/services/apexrest/san/postdata';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Json);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
       san_rt_senddata.SendEvents();
        test.stopTest();
    }
}