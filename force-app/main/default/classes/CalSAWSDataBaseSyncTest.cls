@isTest
private with sharing class CalSAWSDataBaseSyncTest {

    // * SETUP RESPONSES IN STORE
    static Map<String, HttpResponse> responseStore = new Map<String, HttpResponse>{
        'auth' => HttpResponseFactory.authentication200Response(),
        'authFailure' => HttpResponseFactory.authenticationFailureResponse(),
        'person' => HttpResponseFactory.getPersons200Response(),
        'personFailure' => HttpResponseFactory.getPersons400Response(),
        'case' => HttpResponseFactory.getCases200Response(),
        'caseFailure' => HttpResponseFactory.getCasesFailureResponse(),
        'program' => HttpResponseFactory.getPrograms200Response(),
        'programFailure' => HttpResponseFactory.getProgramsFailureResponse()
    };

    // * SETUP MATCHERS
    static List<HttpMatchingStrategy> matchers = new List<HttpMatchingStrategy>{
        new HttpResponseMatchers.AuthMatcher(),
        new HttpResponseMatchers.PersonMatcher(),
        new HttpResponseMatchers.CaseMatcher(),
        new HttpResponseMatchers.ProgramMatcher()
    };

    @IsTest
    private static void scheduleTest() {
        String cron = '0 0 2 ? * * *';
        Id job = System.schedule('CalSAWS Data Sync', cron, new CalSAWSProcess_Schedule());

        CalSAWSProcess_Schedule.scheduleJob(cron);
    }

    @IsTest
    private static void authenticationFail() {
       // * INITIALIZE MOCK GENERATOR
       MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, false, true);

       Test.setMock(HttpCalloutMock.class, mock); 
    
       CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;
        
        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };

        CalSAWSAuthentication.Token token = CalSAWSAuthentication.authorize(endpoints.get('Token'));
        Test.stopTest();
    }

    @IsTest
    private static void personSearchBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789'
        );
        insert con;

        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };

        CalSAWSPersonSearch_Batch b = new CalSAWSPersonSearch_Batch(endpoints);
        Database.executeBatch(b);
        Test.stopTest();
    }

    @IsTest
    private static void personSearchBatchFail() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, false, false);

        Test.setMock(HttpCalloutMock.class, mock);

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789'
        );
        insert con;

        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };

        CalSAWSPersonSearch_Batch b = new CalSAWSPersonSearch_Batch(endpoints);
        Database.executeBatch(b);
        Test.stopTest();
    }

    @IsTest
    private static void personBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);
        
        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
            
        );
        insert con;
            
        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;
                
        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };

        CalSAWSUtilities.processPersons(endpoints);
        Test.stopTest();
    }
    
    @IsTest
    private static void newPersonBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);
        
        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '987654321'

        );
        insert con;
        
        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;
                
        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };
        
        CalSAWSUtilities.processPersons(endpoints);
        Test.stopTest();
    }

    @IsTest
    private static void personBatchFail() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, false, false);

        Test.setMock(HttpCalloutMock.class, mock);

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789'
        );
        insert con;

        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };

        CalSAWSUtilities.processPersons(endpoints);
        Test.stopTest();
    }

    @isTest
    private static void caseBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);
        
        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
        );
        insert con;

        CalWINs_Case__c cs = new CalWINs_Case__c(
            Contact__c = con.Id,
            Case_Number__c = 'B123',
            Name = 'Test'
        );
        insert cs;

        Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };       

        CalSAWSUtilities.processCases(endpoints, cinConMap);
        Test.stopTest();
    }

    @isTest
    private static void newCaseBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);
        
        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
        );
        insert con;

        Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };       

        CalSAWSUtilities.processCases(endpoints, cinConMap);
        Test.stopTest();
    }

    @isTest
    private static void caseBatchFail() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, false, false);

        Test.setMock(HttpCalloutMock.class, mock);
        
        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
        );
        insert con;

        Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };       

        CalSAWSUtilities.processCases(endpoints, cinConMap);
        Test.stopTest();
    }

    @isTest
    private static void newProgramBatchSuccess() {
       // * INITIALIZE MOCK GENERATOR
       MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

       Test.setMock(HttpCalloutMock.class, mock);
       
       CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
           SetupOwnerId = UserInfo.getOrganizationId(),
           Client_Id__c = '123',
           Client_Secret__c = '123',
           Scope__c = 'scope'
       );
       insert creds;

       Contact con = new Contact(
           FirstName = 'FTest',
           LastName = 'LTest',
           Launchpad__Unique_ID_SSN__c = '123456789',
           CIN__c = '123456789'
       );
       insert con;

       Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

       Test.startTest();
       // * BUILD ENPOINTS
       Map<String, String> endpoints = new Map<String, String>{
           'Token' => 'authentication-server',
           'Persons' => 'person',
           'Cases' => 'case',
           'Programs' => 'program'
       };       

       CalSAWSUtilities.processPrograms(endpoints, cinConMap);
       Test.stopTest(); 
    }

    @isTest
    private static void programBatchSuccess() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, true, false);

        Test.setMock(HttpCalloutMock.class, mock);

        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
        );
        insert con;

        CalSAWS_Program__c p = new CalSAWS_Program__c(
            Contact__c = con.Id,
            Program_Id__c = '1234'
        );
        insert p;

        Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };       

        CalSAWSUtilities.processPrograms(endpoints, cinConMap);
        Test.stopTest(); 
    }

    @isTest
    private static void programBatchFail() {
        // * INITIALIZE MOCK GENERATOR
        MockMultiHttpResponseGenerator mock = new MockMultiHttpResponseGenerator(responseStore, matchers, false, false);

        Test.setMock(HttpCalloutMock.class, mock);

        CalSAWS_Credentials__c creds = new CalSAWS_Credentials__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Client_Id__c = '123',
            Client_Secret__c = '123',
            Scope__c = 'scope'
        );
        insert creds;

        Contact con = new Contact(
            FirstName = 'FTest',
            LastName = 'LTest',
            Launchpad__Unique_ID_SSN__c = '123456789',
            CIN__c = '123456789'
        );
        insert con;

        CalSAWS_Program__c p = new CalSAWS_Program__c(
            Contact__c = con.Id,
            Program_Id__c = '1234'
        );
        insert p;

        Map<String, Contact> cinConMap = new Map<String, Contact>{ con.CIN__c => con };

        Test.startTest();
        // * BUILD ENPOINTS
        Map<String, String> endpoints = new Map<String, String>{
            'Token' => 'authentication-server',
            'Persons' => 'person',
            'Cases' => 'case',
            'Programs' => 'program'
        };       

        CalSAWSUtilities.processPrograms(endpoints, cinConMap);
        Test.stopTest(); 
    }
}