public with sharing class CalSAWSAuthentication {

    private static String payload(String id, String pw, String scope) {
        String payload = 'client_id=' + EncodingUtil.urlEncode(id,'UTF-8');
        payload += '&client_secret=' + EncodingUtil.urlEncode(pw,'UTF-8');
        payload += '&scope=' + EncodingUtil.urlEncode(scope,'UTF-8');

        return payload;
    }
    
    public static Map<String, String> authorize() {
        CalSAWS_Endpoint__mdt token = [
            SELECT URL__c
            FROM CalSAWS_Endpoint__mdt
            WHERE MasterLabel = 'Token'
        ];
        CalSAWS_Credentials__c creds = CalSAWS_Credentials__c.getOrgDefaults();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(token.URL__c);
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

            return new Map<String, String> { 'token' => accessToken, 'type' => tokenType };
        } else {
            CalSAWSUtilities.Error err = CalSAWSUtilities.parseError(res.getBody());
            throw new CalloutException(err.error + ' : ' + err.error_description);
        }
    }
}