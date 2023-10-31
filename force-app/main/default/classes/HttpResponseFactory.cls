@isTest
public with sharing class HttpResponseFactory {
    
    public static HttpResponse createHttpResponse(Integer code, String status, String body) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatus(status);
        res.setStatusCode(code);

        return res;
    }

    // # AUTHENTICATION

    public static HttpResponse authentication200Response() {
        String body = '{' +
            '"access_token": "123", ' +
            '"token_type": "Bearer"' +
        '}';
        return createHttpResponse(200, 'OK', body);
    }
        
    public static HttpResponse authenticationFailureResponse() {
        CalSAWSUtilities.Error err = new CalSAWSUtilities.Error();
        err.message = 'Unauthorized';
        String body = JSON.serialize(err);

        return createHttpResponse(401, 'Unauthorized', body);
    }

    // # PERSON

    public static HttpResponse getPersons200Response() {
        CalSAWSPerson.Phones ph = new CalSAWSPerson.Phones();
        ph.type = 'Cell';
        ph.phNum = '1234567891';

        CalSAWSPerson.Phones ph2 = new CalSAWSPerson.Phones();
        ph2.type = 'Home';
        ph2.phNum = '1234567891';

        CalSAWSPerson.Address addr = new CalSAWSPerson.Address();
        addr.type = 'Mailing';
        addr.line1Addr = '123 S St';
        addr.line2Addr = 'Unit 4';
        addr.cityName = 'Madera';
        addr.stateCode = 'CA';
        addr.zipCodeNum = '12345';
        
        CalSAWSPerson.Address addr2 = new CalSAWSPerson.Address();
        addr2.type = 'Physical';
        addr2.line1Addr = '123 S St';
        addr2.line2Addr = 'Unit 4';
        addr2.cityName = 'Madera';
        addr2.stateCode = 'CA';
        addr2.zipCodeNum = '12345';
        
        CalSAWSPerson.Ethnicity eth = new CalSAWSPerson.Ethnicity();
        eth.raceType = 'White';

        CalSAWSPerson.Cases cs = new CalSAWSPerson.Cases();
        cs.caseNum = '123456';

        CalSAWSPerson.Cases cs2 = new CalSAWSPerson.Cases();
        cs2.caseNum = '123456';

        CalSAWSPerson p = new CalSAWSPerson();
        p.persId = '123';
        p.countyCode = 'co';
        p.ssn = '123456789';
        p.cin = '123456789';
        p.lastName = 'LTest';
        p.firstName = 'FTest';
        p.midName = 'MTest';
        p.nameSuffix = 'Jr.';
        p.dob = Date.today();
        p.age = '1';
        p.gender = 'Male';
        p.emailAddr = 'A@b.c';
        p.spokenLang = 'English';
        p.writtenLang = 'English';
        p.driveLic = 'D123456';
        p.phNumbers = new List<CalSAWSPerson.Phones>{ ph, ph2 };
        p.addr = new List<CalSAWSPerson.Address>{ addr, addr2 };
        p.ethnicity = new List<CalSAWSPerson.Ethnicity>{ eth };
        p.cases = new List<CalSAWSPerson.Cases>{ cs, cs2 };

        CalSAWSPerson p2 = new CalSAWSPerson();
        p2.persId = '321';
        p2.countyCode = 'co';
        p2.ssn = '987654321';
        p2.cin = '987654321';
        p2.lastName = 'TestL';
        p2.firstName = 'TestF';
        p2.midName = 'TestM';
        p2.nameSuffix = 'Jr.';
        p2.dob = Date.today();
        p2.age = '10';
        p2.gender = 'Male';
        p2.emailAddr = 'A@b.c';
        p2.spokenLang = 'English';
        p2.writtenLang = 'English';
        p2.driveLic = 'D123456';
        p2.phNumbers = new List<CalSAWSPerson.Phones>{ ph, ph2 };
        p2.addr = new List<CalSAWSPerson.Address>{ addr, addr2 };
        p2.ethnicity = new List<CalSAWSPerson.Ethnicity>{ eth };
        p2.cases = new List<CalSAWSPerson.Cases>{ cs, cs2 };

        return createHttpResponse(200, 'OK', JSON.serialize(new List<CalSAWSPerson>{ p, p2 }));
    }

    public static HttpResponse cinPerson1() {
        CalSAWSPerson.Phones ph = new CalSAWSPerson.Phones();
        ph.type = 'Cell';
        ph.phNum = '1234567891';

        CalSAWSPerson.Phones ph2 = new CalSAWSPerson.Phones();
        ph2.type = 'Home';
        ph2.phNum = '1234567891';

        CalSAWSPerson.Address addr = new CalSAWSPerson.Address();
        addr.type = 'Mailing';
        addr.line1Addr = '123 S St';
        addr.line2Addr = 'Unit 4';
        addr.cityName = 'Madera';
        addr.stateCode = 'CA';
        addr.zipCodeNum = '12345';
        
        CalSAWSPerson.Address addr2 = new CalSAWSPerson.Address();
        addr2.type = 'Physical';
        addr2.line1Addr = '123 S St';
        addr2.line2Addr = 'Unit 4';
        addr2.cityName = 'Madera';
        addr2.stateCode = 'CA';
        addr2.zipCodeNum = '12345';
        
        CalSAWSPerson.Ethnicity eth = new CalSAWSPerson.Ethnicity();
        eth.raceType = 'White';

        CalSAWSPerson.Cases cs = new CalSAWSPerson.Cases();
        cs.caseNum = '123456';

        CalSAWSPerson.Cases cs2 = new CalSAWSPerson.Cases();
        cs2.caseNum = '123456';

        CalSAWSPerson p = new CalSAWSPerson();
        p.persId = '123';
        p.countyCode = 'co';
        p.ssn = '123456789';
        p.cin = '123456789';
        p.lastName = 'LTest';
        p.firstName = 'FTest';
        p.midName = 'MTest';
        p.nameSuffix = 'Jr.';
        p.dob = Date.today();
        p.age = '1';
        p.gender = 'Male';
        p.emailAddr = 'A@b.c';
        p.spokenLang = 'English';
        p.writtenLang = 'English';
        p.driveLic = 'D123456';
        p.phNumbers = new List<CalSAWSPerson.Phones>{ ph, ph2 };
        p.addr = new List<CalSAWSPerson.Address>{ addr, addr2 };
        p.ethnicity = new List<CalSAWSPerson.Ethnicity>{ eth };
        p.cases = new List<CalSAWSPerson.Cases>{ cs, cs2 };

        return createHttpResponse(200, 'OK', JSON.serialize(new List<CalSAWSPerson>{ p }));
    }

    public static HttpResponse cinPerson2() {
        CalSAWSPerson.Phones ph = new CalSAWSPerson.Phones();
        ph.type = 'Cell';
        ph.phNum = '1234567891';

        CalSAWSPerson.Phones ph2 = new CalSAWSPerson.Phones();
        ph2.type = 'Home';
        ph2.phNum = '1234567891';

        CalSAWSPerson.Address addr = new CalSAWSPerson.Address();
        addr.type = 'Mailing';
        addr.line1Addr = '123 S St';
        addr.line2Addr = 'Unit 4';
        addr.cityName = 'Madera';
        addr.stateCode = 'CA';
        addr.zipCodeNum = '12345';
        
        CalSAWSPerson.Address addr2 = new CalSAWSPerson.Address();
        addr2.type = 'Physical';
        addr2.line1Addr = '123 S St';
        addr2.line2Addr = 'Unit 4';
        addr2.cityName = 'Madera';
        addr2.stateCode = 'CA';
        addr2.zipCodeNum = '12345';
        
        CalSAWSPerson.Ethnicity eth = new CalSAWSPerson.Ethnicity();
        eth.raceType = 'White';

        CalSAWSPerson.Cases cs = new CalSAWSPerson.Cases();
        cs.caseNum = '123456';

        CalSAWSPerson.Cases cs2 = new CalSAWSPerson.Cases();
        cs2.caseNum = '123456';

        CalSAWSPerson p2 = new CalSAWSPerson();
        p2.persId = '321';
        p2.countyCode = 'co';
        p2.ssn = '987654321';
        p2.cin = '987654321';
        p2.lastName = 'TestL';
        p2.firstName = 'TestF';
        p2.midName = 'TestM';
        p2.nameSuffix = 'Jr.';
        p2.dob = Date.today();
        p2.age = '10';
        p2.gender = 'Male';
        p2.emailAddr = 'A@b.c';
        p2.spokenLang = 'English';
        p2.writtenLang = 'English';
        p2.driveLic = 'D123456';
        p2.phNumbers = new List<CalSAWSPerson.Phones>{ ph, ph2 };
        p2.addr = new List<CalSAWSPerson.Address>{ addr, addr2 };
        p2.ethnicity = new List<CalSAWSPerson.Ethnicity>{ eth };
        p2.cases = new List<CalSAWSPerson.Cases>{ cs, cs2 };

        return createHttpResponse(200, 'OK', JSON.serialize(new List<CalSAWSPerson>{ p2 }));
    }

    public static HttpResponse getPersons400Response() {
        CalSAWSUtilities.Error err = new CalSAWSUtilities.Error();
        err.message = 'Bad Request';
        String body = JSON.serialize(err);

        return createHttpResponse(400, 'Bad Request', body); 
    }

    public static HttpResponse getPersons404Response() {
        CalSAWSUtilities.Error err = new CalSAWSUtilities.Error();
        err.message = 'Not Found';
        String body = JSON.serialize(err);

        return createHttpResponse(404, 'Not Found', body); 
    }

    // # CASES

    public static HttpResponse getCases200Response() {
        CalSAWSCase.CaseFlag csFlag = new CalSAWSCase.CaseFlag();
        csFlag.begDate = Date.today();

        CalSAWSCase.CaseFlag csFlag2 = new CalSAWSCase.CaseFlag();
        csFlag2.begDate = Date.today().addDays(15);

        CalSAWSCase.Cases csDetails = new CalSAWSCase.Cases();
        csDetails.caseName = 'Test';
        csDetails.caseNum = 'B123';
        csDetails.caseFlags = new List<CalSAWSCase.CaseFlag>{ csFlag, csFlag2 };
        
        CalSAWSCase.Cases csDetails2 = new CalSAWSCase.Cases();
        csDetails2.caseName = 'Test';
        csDetails2.caseNum = 'C321';
        csDetails2.caseFlags = new List<CalSAWSCase.CaseFlag>{ csFlag, csFlag2 };

        CalSAWSCase cs = new CalSAWSCase();
        cs.persId = '123';
        cs.cin = '123456789';
        cs.cases = new List<CalSAWSCase.Cases>{ csDetails, csDetails2 };

        return createHttpResponse(200, 'OK', JSON.serialize(new List<CalSAWSCase>{ cs }));
    }

    public static HttpResponse getCasesFailureResponse() {
        CalSAWSUtilities.Error err = new CalSAWSUtilities.Error();
        err.message = 'Bad Request';
        String body = JSON.serialize(err);

        return createHttpResponse(400, 'Bad Request', body); 
    }

    // # PROGRAMS

    public static HttpResponse getPrograms200Response() {
        CalSAWSProgram.StaffWorker sw = new CalSAWSProgram.StaffWorker();
        sw.worker = 'Test Worker';
        sw.workerNum = '123456';
        sw.begDate = Date.today();
        sw.endDate = Date.today().addYears(15);

        CalSAWSProgram.ProgramRedeterm red = new CalSAWSProgram.ProgramRedeterm();
        red.reDueDate = Date.today().addYears(2);

        CalSAWSProgram.ProgramDetail pd = new CalSAWSProgram.ProgramDetail();
        pd.status = 'Denied';
        pd.statRsn = 'No funds';
        pd.begDate = Date.today();

        CalSAWSProgram p = new CalSAWSProgram();
        p.pgm = 'Welfare to Work';
        p.pgmId = '1234';
        p.caseNum = 'B123';
        p.staffWorker = new List<CalSAWSProgram.StaffWorker>{ sw };
        p.programRedeter = new List<CalSAWSProgram.ProgramRedeterm>{ red };
        p.programDetail = new List<CalSAWSProgram.ProgramDetail>{ pd };
        
        CalSAWSProgram p2 = new CalSAWSProgram();
        p2.pgm = 'Cal-Fresh';
        p2.pgmId = '4321';
        p2.caseNum = 'C123';
        p2.staffWorker = new List<CalSAWSProgram.StaffWorker>{ sw };
        p2.programRedeter = new List<CalSAWSProgram.ProgramRedeterm>{ red };
        p2.programDetail = new List<CalSAWSProgram.ProgramDetail>{ pd };


        return createHttpResponse(200, 'OK', JSON.serialize(new List<CalSAWSProgram>{ p, p2 }));

    }

    public static HttpResponse getProgramsFailureResponse() {
        CalSAWSUtilities.Error err = new CalSAWSUtilities.Error();
        err.message = 'Bad Request';
        String body = JSON.serialize(err);

        return createHttpResponse(400, 'Bad Request', body); 
    }


}