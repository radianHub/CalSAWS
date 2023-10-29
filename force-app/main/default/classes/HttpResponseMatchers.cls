@isTest
public with sharing class HttpResponseMatchers {

    public class AuthMatcher implements HttpMatchingStrategy {
        public HttpResponse matchResponse(HttpRequest req, Map<String, HttpResponse> responseStore, Boolean pass, Boolean failOnAuth) {
            if(req.getEndpoint().contains('authentication-server')) {
                if (!failOnAuth) {
                    return responseStore.get('auth');
                } else {
                    return responseStore.get('authFailure');
                }
            } else {
                return null;
            }
        }
    } 
    
    public class PersonMatcher implements HttpMatchingStrategy {
        public HttpResponse matchResponse(HttpRequest req, Map<String, HttpResponse> responseStore, Boolean pass, Boolean failOnAuth) {
            if(req.getEndpoint().contains('person')) {
                if (pass) {
                    return responseStore.get('person');
                } else {
                    return responseStore.get('personFailure');
                }
            } else {
                return null;
            }
        }
    }

    public class CaseMatcher implements HttpMatchingStrategy {
        public HttpResponse matchResponse(HttpRequest req, Map<String, HttpResponse> responseStore, Boolean pass, Boolean failOnAuth) {
            if(req.getEndpoint().contains('case')) {
                if (pass) {
                    return responseStore.get('case');
                } else {
                    return responseStore.get('caseFailure');
                }
            } else {
                return null;
            }
        } 
    }

    public class ProgramMatcher implements HttpMatchingStrategy {
        public HttpResponse matchResponse(HttpRequest req, Map<String, HttpResponse> responseStore, Boolean pass, Boolean failOnAuth) {
            if(req.getEndpoint().contains('program')) {
                if (pass) {
                    return responseStore.get('program');
                } else {
                    return responseStore.get('programFailure');
                }
            } else {
                return null;
            }
        } 
    }
}