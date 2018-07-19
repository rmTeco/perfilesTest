@RestResource(urlMapping='/v1/integrationprocedure/CollectionAndBilling_Collection_reconnectService/*')
global with sharing class IFS_S185_reconnectService {

    @HttpPost
    global static void getData() {
        FromJSON jsonBody;
        ToJSON tojson;
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Object> result1 = new Map<String, Object>();

        res.addHeader('Content-Type', 'application/json');

        try {
            res.statuscode = 200;
            jsonBody = (FromJSON)JSON.deserialize(req.requestBody.toString(),FromJSON.class);


            // Validaciones del mensaje
            System.debug('Paso 1: Validaciones del mensaje');
            if (jsonBody.reconnectService.WorkOrderType != '4') {
                throw new CalloutException('Error: El campo WorkOrderType debe tener el valor 4 para rehabilitacion');
            }
            System.debug('Paso 2: Validaciones del mensaje');
            if (jsonBody.reconnectService.OrderObjType != 'S') {
                throw new CalloutException('Error: El campo OrderObjType debe tener el valor S para rehabilitacion');
            }
            System.debug('Paso 3: Validaciones del mensaje');
            if (string.isBlank(jsonBody.reconnectService.OrderObjKey)) {
                throw new CalloutException('Error: El campo OrderObjKey es requerido');
            }
            System.debug('Paso 4: Validaciones del mensaje');
            if (string.isBlank(jsonBody.reconnectService.OrderObjCode)) {
                throw new CalloutException('Error: El campo OrderObjCode es requerido');
            }
            System.debug('Paso 5: Validaciones del mensaje');
            if (!orderParamOk(jsonBody.reconnectService.OrderParam)) {
                throw new CalloutException('Error en la lista de parámetros');
            }
            System.debug('Paso 6: Pasé todas las validaciones');



            /* Armado de la respuesta

            result1.put('SalesOrderId',jsonBody.invoiceAndPaymentNotification.SalesOrderId);
            result1.put('Status',jsonBody.invoiceAndPaymentNotification.Status);

            if (!string.isBlank(jsonBody.invoiceAndPaymentNotification.StatusInvoice)) {
                result1.put('StatusInvoice',jsonBody.invoiceAndPaymentNotification.StatusInvoice);
            }
            if (!string.isBlank(jsonBody.invoiceAndPaymentNotification.ReasonCode)) {
                result1.put('ReasonCode',jsonBody.invoiceAndPaymentNotification.ReasonCode);
            }
            if (!string.isBlank(jsonBody.invoiceAndPaymentNotification.ReasonCodeName)) {
                result1.put('ReasonCodeName',jsonBody.invoiceAndPaymentNotification.ReasonCodeName);
            }
            if (!string.isBlank(jsonBody.invoiceAndPaymentNotification.Comments)) {
                result1.put('Comments',jsonBody.invoiceAndPaymentNotification.Comments);
            }
            if (jsonBody.invoiceAndPaymentNotification.TotalInvoiceAmount != null) {
                result1.put('TotalInvoiceAmount',jsonBody.invoiceAndPaymentNotification.TotalInvoiceAmount);
            }
            if (!string.isBlank(jsonBody.invoiceAndPaymentNotification.LegalInvoiceNumber)) {
                result1.put('LegalInvoiceNumber',jsonBody.invoiceAndPaymentNotification.LegalInvoiceNumber);
            }
                
            Boolean stat = BillingResponseHandler.callBackService224(null, null, result1);
            if (!stat){
                throw new CalloutException('Error en la llamada a la clase BillingResponseHandler');
            }

            */

            insertInBatchQueue(mapeoOM(jsonBody));

            result.put('ResultHeader', mapaRespuesta());
            res.responseBody = Blob.valueOf(JSON.serializePretty(result));
            System.debug('Paso ultimo: paso');

        }
        catch(Exception e){
            res.statuscode = 417 ;
            res.responseBody = Blob.valueOf(JSON.serialize(getRespuestaNoOk('417',e.getMessage())));
        }
    }

    private static Map<String, Object> mapeoOM (FromJSON pJson) {

        if (pJson == null){
            throw new CalloutException('Error JSON de entrada a OM es nulo');
        }

        FromJSON_to lJson = new FromJSON_to();
        lJson.typeOfJob = 'Rehabilitacion';
      
        lJson.lines.add(pJson.reconnectService);
        String strJson = JSON.serialize(lJson);
        Map<String, Object> result = (Map<String,Object>)JSON.deserializeUntyped(strJson);
        return result;
    }

    private static void insertInBatchQueue(Map<String, Object> pMapa){

        try {
            System.debug('..... instancio la clase xOMBatchLines ()');
            xOMBatchLines.ResultObj result = xOMBatchLines.generateBatchJobsFromJSONUntyped(pMapa);
            if (result.resultCode != 200) {
                throw new CalloutException(result.resultMessage);
            }
        }
        catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }


    private static Boolean orderParamOk(List<FromJSON_2> pOrderParam){
        Boolean opTypeOk;
        Boolean oldStatusOk;
        Boolean newStatusOk;
        Boolean statusTimeOk;

        opTypeOk     = false;
        oldStatusOk  = false;
        newStatusOk  = false;
        statusTimeOk = false;

        if (pOrderParam != null){
            System.debug('OrderParam es nulo');
        }

        Integer i=0;
        for (i=0; i<pOrderParam.size(); i++) {
            String c = pOrderParam[i].Code;
            String d = pOrderParam[i].Value;
            if (c=='OpType' && d=='30'){
                opTypeOk = true;
            }
            if (c=='OldStatus' && (d=='3' || d=='4' || d=='8')){
                oldStatusOk = true;
            }
            if (c=='NewStatus' && (d=='2')){
                newStatusOk = true;
            }
            if (!string.isBlank(c)){
                statusTimeOk = true;
            }

        }

        return opTypeOk && oldStatusOk && newStatusOk && statusTimeOk;
    }

    private static List<Map<String, String>> getRespuestaNoOk(String pCodigo, String pDescripcion) {
        System.debug('Entre a getRespuestaNoOk()');
        Map<String, String> mapa = new Map<String, String>();
        List<Map<String, String>> lstErrors = new List<Map<String, String>>();
        mapa.put('errorCode', pcodigo);
        mapa.put('message', pDescripcion);
        lstErrors.add(mapa);
        return lstErrors;   
    }

    private static Map<String, Object> mapaRespuesta() {
        Map<String, Object> mapa = new Map<String, Object>();

        mapa.put('ResultDesc','Operation Successfuly');
        mapa.put('ResultCode',0);
        mapa.put('Version','1');

        return mapa;   
    }

     public class FromJSON {
        public FromJSON_1 reconnectService; 
    }

    public class FromJSON_to {
        public FromJSON_to(){
            lines = new  List<FromJSON_1>();
        }
        public String typeOfJob;
        public List<FromJSON_1> lines; 
    }
    
    public class FromJSON_1 {
        public String WorkOrderType; 
        public String OrderObjType;
        public String OrderObjKey;
        public String OrderObjCode;
        public List<FromJSON_2> OrderParam;
    }

    public class FromJSON_2 {
        public String Code;
        public String Value;
        public List<FromJSON_2> Param;
        public List<FromJSON_4> ObjParam;
    }

    public class FromJSON_4 {
        public String Value;
        public List<FromJSON_2> Param;
        public List<FromJSON_4> ObjParam;
    }

    public class ToJSON {
        public ToJSON_1 ResultHeader;
    }
    public class ToJSON_1 {
        public String Version;
        public String ResultCode;
        public String ResultDesc;
    }
}