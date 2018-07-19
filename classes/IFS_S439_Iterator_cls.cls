global with sharing class IFS_S439_Iterator_cls implements vlocity_cmt.VlocityOpenInterface
{

    global IFS_S439_Iterator_cls () {}

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('getData')){
                outMap = getData(inputMap);
            }
            result = false;  
        } 
        catch(Exception e)
        {
            throw e;
        }
        return result;
    }


    private static Map<String,Object> getData(Map<String,Object> pInputMap){

        List<JsonRespuesta_2> lista2 = new list<JsonRespuesta_2>();
        List<String> lstLineas = new List<String>();

        for(Object nro: pInputMap.values()) {
            lstLineas.add((String)nro);
        }

        for(Integer i=0;i<lstLineas.size();i++){
            HttpResponse res = makePostCallout(lstLineas[i]);
            JsonRespuesta_2 listaNros = new JsonRespuesta_2();

            listaNros.detalleConsulta = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            listaNros.nroLinea = lstLineas[i];
            lista2.add(listaNros);
        }

        String lJson = JSON.serialize(lista2);
        return (Map<String, Object>)JSON.deserializeUntyped(lJson);
    }  

    public static HttpResponse makePostCallout(String pnroLinea) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        List<EndPointService__c> endPoints = [select Name, EndPoint__c from EndPointService__c where Name = 'IFS_S439' limit 1];
        EndPointService__c endpoint;
        if(endPoints.size()>0){
            endpoint = endPoints[0];
        }


        if(endpoint != null){
            request.setEndpoint(endpoint.EndPoint__c + pnroLinea);
        }



        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String authorizationHeader = IFS_AuthorizationHeader.giveHeader();
        request.setHeader('Authorization', authorizationHeader);
        //request.setBody(Blob.valueOf(JSON.serialize(tojson)));
        HttpResponse response = http.send(request);
        system.debug(response);
        system.debug(response.getBody());
        
        return response;
        
    }

    private class JsonRespuesta_2 {
        public String nroLinea;
        public Map <String, Object> detalleConsulta;
    }

}