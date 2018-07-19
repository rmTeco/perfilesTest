@RestResource(urlMapping='/v1/integrationprocedure/getAvailableOffers/*')
global with sharing class IFS_S445_getAvailableOffers {

    @HttpPost
    global static void getPost() {
        Http http = new Http();
        Map<String, Object> resultado = null;
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        res.addHeader('Content-Type', 'application/json');
        IFS_S445_getAvailableOffers_cls.ResultObj result = IFS_S445_getAvailableOffers_cls.getAvailableOffers(req.requestBody.toString());
        res.statuscode = result.resultCode;
        res.responseBody = result.resultMessage;
    }
}