public class MarketingCloudAuthProvider extends Auth.AuthProviderPluginClass{

    public static final String RESOURCE_CALLBACK = '/services/authcallback/';
    public static final String DEFAULT_TOKEN_TYPE = 'BearerToken';
    public static final String ENCODING_XML = 'application/x-www-form-urlencoded;charset=UTF-8';
    public static final String ENCODING_JSON = 'application/json';
    public static final String DUMMY_CODE = '999';
    public static final String DOUBLEQUOTE = '"';

    // This class is dependant on this Custom Metadata Type created to hold custom parameters
    public static final String CUSTOM_MDT_NAME = 'APIIntegration_mdt__mdt'; 
    public static final String CMT_FIELD_CALLBACK_URL = 'Callback_URL_c__c';
    public static final String CMT_FIELD_PROVIDER_NAME = 'Auth_Provider_Name_c__c';
    public static final String CMT_FIELD_AUTHTOKEN_URL = 'Access_Token_URL_c__c';
    public static final String CMT_FIELD_CLIENT_ID = 'Client_Id_c__c';
    public static final String CMT_FIELD_CLIENT_SECRET = 'Client_Secret_c__c';


    /** Added Constructor purely for debugging purposes to have visibility as to when the class
     is being instantiated.
    **/
    public MarketingCloudAuthProvider() {
        super();
        System.debug('Constructor called');
    }
    
    
    /** Name of custom metadata type to store this auth provider configuration fields
        This method is required by its abstract parent class.

    **/
    public String getCustomMetadataType() {
        return CUSTOM_MDT_NAME;
    } 
    
    /** Initiate callback. No End User authorization required in this flow so skip straight to the Token request.
    The interface requires the callback url to be defined. 
    Eg: https://test.salesforce.com/services/authcallback/<authprovidername>
    **/
    public PageReference initiate(Map<string,string> config, String stateToPropagate) {
        System.debug('initiate');

        System.debug('Config: ' + config);
        final PageReference pageRef = new PageReference(getCallbackUrl(config)); //NOSONAR
        pageRef.getParameters().put('state',stateToPropagate);
        pageRef.getParameters().put('code',DUMMY_CODE); // Empirically found this is required, but unused
        System.debug(pageRef.getUrl());

        System.debug('DEBUG FC 1: ' + handleCallback(config, null));

        final TokenResponse response = retrieveToken(config);

        System.debug('DEBUG FC2: ' + response);
        
        return pageRef;
    } 

    /**This method composes the callback URL automatically UNLESS it has been overridden through Configuration.
      Normally one should not override the callback URL, but it's there in case the generated URL doesn't work.
    **/
    private String getCallbackUrl(Map<string,string> config) {
        // https://{salesforce-hostname}/services/authcallback/{urlsuffix}
        final String overrideUrl = config.get(CMT_FIELD_CALLBACK_URL);
        final String generatedUrl = URL.getSalesforceBaseUrl().toExternalForm() + RESOURCE_CALLBACK + 'APIEval';

        system.debug('CALLBACK URL: ' + overrideUrl);
        return String.isEmpty(overrideUrl) ? generatedUrl : overrideUrl;
    }
   
    public Auth.AuthProviderTokenResponse handleCallback(Map<string,string> config, Auth.AuthProviderCallbackState state ) {
        System.debug('handleCallback');
        final TokenResponse response = retrieveToken(config);

        if (response.isError()) {
            throw new TokenException(response.getErrorMessage());
        }
        return new Auth.AuthProviderTokenResponse(config.get(CMT_FIELD_PROVIDER_NAME)
                                                  , response.access_token
                                                  , config.get(CMT_FIELD_CLIENT_SECRET) // No Refresh Token
                                                  , state.queryParameters.get('state'));
    } 
    
    /** Refresh is required by the parent class and it's used if the original Access Token has expired.
        In the Client Credentials flow, there is no Refresh token, so its implementation is exactly the
        same as the Initiate() step.
    **/
    public override Auth.OAuthRefreshResult refresh(Map<String,String> config, String refreshToken) {
        System.debug('refresh');
        final TokenResponse response = retrieveToken(config);
        return new Auth.OAuthRefreshResult(response.access_token, response.token_type);
    }

       
    /** getUserInfo is required by the Parent class, but not fully supported by this provider.
        Effectively the Client Credentials flow is only useful for Server-to-Server API integrations
        and cannot be used for other contexts such as a Registration Handler for Communities.
     **/
    public Auth.UserData getUserInfo(Map<string,string> config, Auth.AuthProviderTokenResponse response) {
        System.debug('getUserInfo-was-called');
        final TokenResponse token = retrieveToken(config);

        final Auth.UserData userData = new Auth.UserData(
              token.application_name // identifier
            , null // firstName
            , null // lastName
            , null // fullName
            , token.developer_email // email
            , null // link
            , token.developer_email // userName
            , null  //locale
            , config.get(CMT_FIELD_PROVIDER_NAME) //provider
            , null // siteLoginUrl
            , new Map<String,String>());


        return userData;
    }
    
    
    /** Private method that gets the Auth Token using the Client Credentials Flow.
   
     private TokenResponse retrieveToken(Map<String,String> config) {
         TokenResponse tokentt = new TokenResponse();
        System.debug('retrieveToken');
        final HttpRequest req = new HttpRequest();

        final PageReference endpoint = new PageReference(config.get(CMT_FIELD_AUTHTOKEN_URL)); //NOSONAR -- Protected by RemoteSite Setting      
         System.debug('Endpoint: ' + endpoint.getUrl());
        //System.debug('Body:' + encodedParams);
        String reqbody = 'grant_type=password&client_id='+config.get(CMT_FIELD_CLIENT_ID)+'&client_secret='+config.get(CMT_FIELD_CLIENT_SECRET)+'&username=xyz@gamil.com&password=textpass';
        req.setEndpoint(endpoint.getUrl()); 
         req.setBody(reqbody);
        req.setMethod('POST'); 
         try{
             final HTTPResponse res = new Http().send(req); 
              System.debug('Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        final Integer statusCode = res.getStatusCode();

        if ( statusCode == 200) {
            TokenResponse token =  deserializeToken(res.getBody());
            // Ensure values for key fields
            token.token_type = (token.token_type == null) ? DEFAULT_TOKEN_TYPE : token.token_type;
            return token;

        } else  {
            return deserializeToken(res.getBody());
        }
         }catch(Exception e){
             System.debug('eeeee'+e);
         }
        

       return tokentt;

    }
     **/


    private TokenResponse retrieveToken(Map<String,String> config) {

        Map<String, String> params = new Map<String, String>();
        params.put('clientId', config.get(CMT_FIELD_CLIENT_ID));
        params.put('clientSecret', config.get(CMT_FIELD_CLIENT_SECRET) );
        final PageReference endpoint = new PageReference(config.get(CMT_FIELD_AUTHTOKEN_URL));
            
        String jsonParams = JSON.serialize(params);

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint.getUrl()); 
        req.setHeader('Content-Type','application/json'); 
        req.setBody(jsonParams);
        req.setMethod('POST'); 
        TokenResponse tokentt = new TokenResponse();
        
         try{
             final HTTPResponse res = new Http().send(req); 
              System.debug('Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());
        final Integer statusCode = res.getStatusCode();

        String tokenOld = ((Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class)).get('accessToken');

        System.debug('TOKEN: ' + tokenOld );

        if ( statusCode == 200) {
            TokenResponse token =  deserializeToken(res.getBody());
            // Ensure values for key fields
            token.token_type = (token.token_type == null) ? DEFAULT_TOKEN_TYPE : token.token_type;
            return token;

        } else  {
            return deserializeToken(res.getBody());
        }
         }catch(Exception e){
             System.debug('eeeee'+e);
         }
        

       return tokentt;

    }
    
    //deserialise response and return token
    @testVisible
    private TokenResponse deserializeToken(String responseBody) {
        
        System.debug('token response:' +responseBody);
        
        // use default parsing for everything we can.
        TokenResponse parsedResponse = (TokenResponse) System.JSON.deserialize(responseBody, TokenResponse.class);
        // explicitly parse out the developer.email property because it's an illegal identifier
        Map<String,Object> props = (Map<String,Object>) System.JSON.deserializeUntyped(responseBody);
        parsedResponse.developer_email = (String) props.get('developer.email');
       
        return parsedResponse;
    }

   

    public class TokenResponse {
        public String refresh_token_expires_in {get;set;}
        public String api_product_list {get;set;}
        public List<String> api_product_list_json {get;set;}
        public String organization_name {get;set;}
        public String developer_email {get;set;}
        public String token_type {get;set;}
        public String issued_at {get;set;}
        public String client_id {get;set;}
        public String access_token {get;set;}
        public String application_name {get;set;}
        public String scope {get;set;}
        public String expires_in {get;set;}
        public String refresh_count {get;set;}
        public String status {get;set;}

        // Apigee Edge -- hosted version uses these fields for error handling
        public String ErrorCode {get; set;}
        public String Error {get; set;}

        // Apigee on premise version uses this Field for error handling
        public Fault fault {get; set;}

        public Boolean isError() {
            return Error != null || fault != null;
        }

        public String getErrorMessage() {
            if (Error != null) {
                return ErrorCode;
            }

            if (fault != null) {
                // Substitute the error code to compose
                return fault.faultString.replace('{0}',fault.detail.errorcode);
            }
            return null;
        }
    }

    public class Fault {
        public String faultstring {get;set;}
        public Detail detail {get;set;}
    }

    public class Detail {
        public String errorcode {get;set;}
    }

    /**  Custom exception type so we can wrap and rethrow
    **/
    public class TokenException extends Exception {

    }
    
    
}