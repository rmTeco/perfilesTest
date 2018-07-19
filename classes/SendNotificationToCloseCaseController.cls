global with sharing class SendNotificationToCloseCaseController{

    @RemoteAction
    global static Boolean closeCase(String caseNumber, String contactSMS, String contactEmail){
        try
        {
            System.debug('El caseNumber es:' + caseNumber);
            System.debug('Linea: ' + contactSMS);
            System.debug('Email: ' + contactEmail);

            if(!String.isBlank(caseNumber))
            {
                sendComunication('SMS', contactSMS);
                sendComunication('Email', contactEmail);

                Case selectedCase = [SELECT Id, CaseNumber, Status FROM Case WHERE CaseNumber = :caseNumber];
                selectedCase.Status = 'Cancelado';
                selectedCase.Resolution_Comment__c = 'El proceso fue cancelado, se envió correctamente el SMS/Email.';
                update selectedCase;

                return true;
            }
            else 
            {
                return false;
            }
            
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            return false;       
        }
        
    }

    private static void sendComunication(String comunicationType, String contactInfo) {
        try {

            String integProcName;

            if(comunicationType == 'SMS')
                integProcName = 'IFS_S159'; //SMS
            else 
                integProcName = 'IFS_S075'; //EMAIL

            Map<String, Object> input = generateJSONContent(comunicationType, contactInfo);
            System.debug('input: ' + input);
            
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
            if(!Test.isRunningTest()) integProcServ.invokeMethod(integProcName, input, output, options);
            
            System.debug('output: ' + output);

            String response = (String)output.get('executionCode');

            System.debug('response: ' + response);
            //if(executionCode == 'OK')


        }
        catch(Exception ex) {
            throw ex;
        }
    }

    private static Map<String, Object> generateJSONContent(String comunicationType, String contactInfo) {

        try{
            //Cero un obejeto JSONGenerator
            //Se envia true para inprimir con formato
            JSONGenerator request = JSON.createGenerator(true);
             
            //Ecribo la data sobre el request,
            request.writeStartObject();
            //Genero el nodo params
            request.writeFieldName('params');
            request.writeStartObject();
            if(comunicationType == 'SMS')
                request.writeObjectField('nroLinea', contactInfo);
            else 
                request.writeObjectField('email', contactInfo);
            request.writeEndObject();
            //Genero el nodo body
            request.writeFieldName('body');
            request.writeStartObject();
            request.writeObjectField('bodyFullCodeName', '');
            request.writeObjectField('campaignName', '');
            request.writeObjectField('channelName', comunicationType);
            request.writeObjectField('communicationDate', '2017-05-04T02:29:43');//system.today()).format());
            request.writeObjectField('communicationText', 'Enviamos el texto del mensaje');
            request.writeObjectField('messageReference', '');
            //Genero el nodo target
            request.writeFieldName('target');
            request.writeStartObject();
            //Genero el nodo user
            request.writeFieldName('user');
            request.writeStartObject();
            request.writeObjectField('customerNumber', '');
            request.writeObjectField('lastName', '');
            request.writeObjectField('name', '');
            request.writeObjectField('mail', '');
            request.writeEndObject();
            //Finaliza nodo user
            //Genero el nodo rawdata
            request.writeFieldName('rawdata');
            request.writeStartArray();
            request.writeStartObject();
            request.writeObjectField('key', '');
            request.writeObjectField('value', '');
            request.writeEndObject();
            request.writeEndArray();
            //Finaliza nodo rawdata  
            //Finaliza el nodo target
            request.writeEndObject();
            //Finaliza el nodo body
            request.writeEndObject();
            request.writeEndObject();

            //String formato = request.getAsString();
            //System.debug('formato: ' + formato); 
             
             return (Map<String, Object>)JSON.deserializeUntyped(request.getAsString());
        }
        catch(Exception ex) {
            throw ex;
        }
    }
    
    global SendNotificationToCloseCaseController(){
    
    }
}