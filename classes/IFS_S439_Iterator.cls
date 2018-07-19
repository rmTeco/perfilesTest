@RestResource(urlMapping='/v1/integrationprocedure/IFS_S439_Iterator/*')
global with sharing class IFS_S439_Iterator {

    @HttpPost
    global static void getData() {
        FromJSON jsonBody;
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        res.addHeader('Content-Type', 'application/json');
        try {
            jsonBody = (FromJSON)JSON.deserialize(req.requestBody.toString(),FromJSON.class);
            res.statuscode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(getQueryLite(jsonBody.listaLineas)));
        }
        catch(Exception e){
            res.statuscode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(getRespuestaNoOk('418',e.getMessage())));
        }
       
    }

    private static JsonRespuesta getQueryLite (List<String> plistaLineas){
        JsonRespuesta_1 nivel2 = new JsonRespuesta_1();
        JsonRespuesta   nivel1 = new JsonRespuesta();
        list<JsonRespuesta_2> lista2 = new list<JsonRespuesta_2>();
        Map<String, Object> mapa = new Map<String, Object>();

        system.debug('Antes del for');
        for (Integer i=0; i< plistaLineas.size(); i++){
            String pLinea = plistaLineas.get(i);
            system.debug('Dentro del for, antes de makeCallout');

            HttpResponse res = makePostCallout(pLinea);
            JsonRespuesta_2 listaNros = new JsonRespuesta_2();

            listaNros.detalleConsulta = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            listaNros.nroLinea = pLinea;
            lista2.add(listaNros);
            //nivel2.ListaInfoLinea.add(listaNros);
        system.debug('Dentro del for, despues de makeCallout');
        }
        nivel2.ListaInfoLinea = lista2;
        nivel1.iteratorQueryLite = nivel2;
                system.debug('Antes del return');

        return nivel1;
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

    private class ToJson {
        public String listaLineas;
    }

    private class JsonRespuesta {
        public jsonRespuesta_1 iteratorQueryLite;
    }

    private class JsonRespuesta_1 {
        public List<jsonRespuesta_2> ListaInfoLinea;
    }

    private class JsonRespuesta_2 {
        public String nroLinea;
        public Map <String, Object> detalleConsulta;
    }

    private  static Map<String, String> getRespuestaNoOk(String pCodigo, String pDescripcion) {
        Map<String, String> mapa = new Map<String, String>();

        mapa.put('errorCode', pcodigo);
        mapa.put('message', pDescripcion);

        return mapa;   
    }

    private class FromJSON {
        public List<String> listaLineas;
    }
   
}