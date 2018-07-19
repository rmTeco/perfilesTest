global with sharing class ta_sales_portoutValidations implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
           Boolean result = true;
           try
           {
               if (methodName.equals('PortoutInProgressNomination')){
                   Boolean portoutFlag = PortoutInProgressNomination((Id) options.get('assetId'));
                   outMap.put('portoutFlag', portoutFlag);
            }
            
            if (methodName.equals('CEGMetodoPrueba')){
                CEGMetodoPrueba(inputMap, outMap, options);
            }
            
           }
    
            catch(Exception e)
           
           {
             System.debug('taSalesPortoutValidations:invokeMethod -> exception: '+e);
              throw e;
             //result = false;
           }
           return result;
    }


    public Boolean PortoutInProgressNomination(Id assetId) {
            Boolean res;
            Asset tamoactivo = [SELECT Id, vlocity_cmt__Action__c FROM Asset WHERE Id = :assetId];
            res = tamoactivo.vlocity_cmt__Action__c != 'Existing';
            return res;
    }
    
    public void CEGMetodoPrueba(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
            String tamoactivoId = (String) options.get('assetId');
            Asset tamoactivo = [SELECT Id, vlocity_cmt__Action__c, Status FROM Asset WHERE Id = :tamoactivoId];
            if(tamoactivo.Status == 'Active') tamoactivo.Status = 'Purchased';
            update tamoactivo;
    }

}