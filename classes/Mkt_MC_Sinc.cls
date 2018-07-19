public class Mkt_MC_Sinc {
  @InvocableMethod(label='Sinc campaing with MC' description='Sincronizes SF campaigns with marketing cloud')
  public static void sincronizeCampaignWithMC(List<Id> campaignsIds)
  {
      String token = '';
      getToken();
      system.debug('Sincronization, token: ' + token);
  }

    
  @future(callout=true) static void getToken() 
  {
      
      /*HttpRequest req = new HttpRequest();
      req.setHeader('Authorization', 'Bearer {!$mktCampaingsNameCredential.OAuthToken}');
      req.setEndpoint('https://auth.exacttargetapis.com/v1/requestToken');
      req.setMethod('POST');
      Http http = new Http();
      system.debug('request' + req);
      HTTPResponse res = http.send(req);
	  System.debug(res.getBody());*/
      Mkt_MC_AuthProvider authProvider = new Mkt_MC_AuthProvider();
      
      String metadata = authProvider.getCustomMetadataType();
      
      system.debug('metadata: ' + metadata);
      
      Map<String,String> authProviderConfiguration = new Map<String,String>(); 
      authProviderConfiguration.put('Key__c', 'n7rm00s37xzy2uht0u4uscub'); 
      authProviderConfiguration.put('Access_Token_Url__c', 'https://auth.exacttargetapis.com/v1/requestToken'); 
      authProviderConfiguration.put('Secret__c', 'zXHRndoZZYQVM0CcnJnSaYKm'); 
      
      String token = '';
      
      Auth.AuthProviderTokenResponse actualAuthProvResponse = authProvider.handleCallback(authProviderConfiguration, null);
      
      system.debug('callback, token: ' + actualAuthProvResponse.oauthToken);
      
      //token = authProvider.handleCallback(authProviderConfiguration, null);
      //return token;
  }
}