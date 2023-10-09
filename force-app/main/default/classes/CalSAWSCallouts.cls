public with sharing class CalSAWSCallouts {
    
    // * RETURNS NEW/UPDATED PERSONS FOR THE PAST 72 HOURS
    public static List<CalSAWSPerson> getPersons(CalSAWSAuthentication.Token token, String endpoint) {
        Date today = Date.today().addDays(-2);
        String y = String.valueOf(today.year());
        String m = String.valueOf(today.month());
        if (today.month() < 10) {
            m  = '0' + m;
        }
        String d = String.valueOf(today.day());
        if (today.day() < 10) {
            d = '0' + d;
        }
        String searchDate = y + '-' + m + '-' + d + 'T' + '00';

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token.type + ' ' + token.token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
        req.setEndpoint(endpoint + 'mdm?fromDate=' + searchDate);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode() + ': ' + res.getStatus());

        if (res.getStatusCode() == 200) {
            return CalSAWSUtilities.parsePersons(res.getBody());
        } else {
            if (res.getStatusCode() != 204) {
                CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
                System.debug(err.error);
                throw new CalloutException(err.error);
            }
        }
        return null;
    }

    // * RETURNS A PERSON USING A PERSON'S CIN #
    public static List<CalSAWSPerson> getPersonByCin(CalSAWSAuthentication.Token token, String endpoint, String cin) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token.type + ' ' + token.token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
        req.setEndpoint(endpoint + 'bySsnCin?cin=' + cin);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode() + ': ' + res.getStatus());
        
        if (res.getStatusCode() == 200) {
            return CalSAWSUtilities.parsePersons(res.getBody());
        } else {
            if (res.getStatusCode() != 204) {
                CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
                System.debug(err.error);
                throw new CalloutException(err.error);
            }
        }
        return null;
    }

    // * RETURNS A PERSON USING A PERSON'S SSN #
    public static List<CalSAWSPerson> getPersonBySsn(CalSAWSAuthentication.Token token, String endpoint, String ssn) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token.type + ' ' + token.token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
        req.setEndpoint(endpoint + 'bySsnCin?ssn=' + ssn);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode() + ': ' + res.getStatus());
        
        if (res.getStatusCode() == 200) {
            return CalSAWSUtilities.parsePersons(res.getBody());
        } else {
            if (res.getStatusCode() != 204) {
                CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
                System.debug(err.error);
                throw new CalloutException(err.error);
            }
        }
        return null;
    }

    // * RETURNS A LIST OF CASES ASSOCIATED WITH A PERSON'S CIN #
    public static List<CalSAWSCase> getCaseByCin(CalSAWSAuthentication.Token token, String endpoint, String cin) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token.type + ' ' + token.token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
        req.setEndpoint(endpoint + 'bySsnCin?cin=' + cin);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode() + ': ' + res.getStatus());

        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
            return CalSAWSUtilities.parseCase(res.getBody());
        } else {
            CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
            System.debug(err.error);
            throw new CalloutException(err.error);
        }
    }

    // * RETURNS A LIST OF PROGRAMS ASSOCIATED WITH A PERSON'S CIN #
    public static List<CalSAWSProgram> getProgramsByCin(CalSAWSAuthentication.Token token, String endpoint, String cin, Date viewDate) {
        String d = String.valueOf(viewDate.day());
        if (viewDate.day() < 10) {
            d = '0' + d;
        }
        String m = String.valueOf(viewDate.month());
        if (viewDate.month() < 10) {
            m = '0' + m;
        }
        String y = String.valueOf(viewDate.year());

        String searchDate = y + '-' + m + '-' + d;

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token.type + ' ' + token.token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setMethod('GET');
        req.setEndpoint(endpoint + '/byCIN?cin=' + cin + '&viewDate=' + searchDate);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode() + ': ' + res.getStatus());

        if (res.getStatusCode() == 200) {
            return CalSAWSUtilities.parsePrograms(res.getBody());
        } else {
            if (res.getStatusCode() != 204) {
                CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
                System.debug(err.error);
                throw new CalloutException(err.error);
            }
        }
        return null;
    }
}