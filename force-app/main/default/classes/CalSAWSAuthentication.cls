public with sharing class CalSAWSAuthentication {

    public class Token {
        public String type;
        public String token;
    
        public Token(String type, String token) {
            this.type = type;
            this.token = token;
        }
    }

    private static String payload(String id, String pw, String scope) {
        String payload = 'client_id=' + EncodingUtil.urlEncode(id,'UTF-8');
        payload += '&client_secret=' + EncodingUtil.urlEncode(pw,'UTF-8');
        payload += '&scope=' + EncodingUtil.urlEncode(scope,'UTF-8');

        return payload;
    }
    
    public static Token authorize(String endpoint) {
        CalSAWS_Credentials__c creds = CalSAWS_Credentials__c.getOrgDefaults();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(payload(creds.Client_Id__c, creds.Client_Secret__c, creds.Scope__c));

        Http http = new Http();
        HttpResponse res = http.send(req);

        String accessToken;
        String tokenType;
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = (String) result.get('access_token');
            tokenType = (String) result.get('token_type');

            return new Token(tokenType, accessToken);
        } else {
            CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
            throw new CalloutException(err.error + ' : ' + err.error_description);
        }
    }
}