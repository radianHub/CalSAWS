@isTest
public with sharing class MockMultiHttpResponseGenerator implements HttpCalloutMock {
    private Map<String, HttpResponse> responseStore;
    private List<HttpMatchingStrategy> responseMatchers;
    private Boolean pass;
    private Boolean failOnAuth;

    public MockMultiHttpResponseGenerator(Map<String, HttpResponse> responseStore, List<HttpMatchingStrategy> responseMatchers, Boolean pass, Boolean failOnAuth) {
        this.responseStore = responseStore;
        this.responseMatchers = responseMatchers;
        this.pass = pass;
        this.failOnAuth = failOnAuth;
    }

    private HttpResponse matchResponse(HttpRequest req) {
        HttpResponse res;
        for (HttpMatchingStrategy matcher : responseMatchers) {
            res = matcher.matchResponse(req, responseStore, pass, failOnAuth);
            if (res != null) {
                break;
            }
        }
        return res;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = matchResponse(req);
        if (res == null) {
            System.assert(false, 'No response found for request.');
        }
        return res;
    }
}