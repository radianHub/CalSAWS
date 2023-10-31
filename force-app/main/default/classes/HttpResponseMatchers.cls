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
            if(req.getEndpoint().contains('person') && req.getEndpoint().contains('?')) {
                if (pass) {
                    List<String> param = req.getEndpoint().split('\\?');
                    if (param[param.size() - 1] == 'cin=987654321') {
                        return responseStore.get('person2');
                    } else if (param[param.size() - 1] == 'cin=123456789') {
                        return responseStore.get('person1');
                    } else {
                        return responseStore.get('person');
                    }
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