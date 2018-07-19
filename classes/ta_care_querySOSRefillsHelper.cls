global with sharing class ta_care_querySOSRefillsHelper implements vlocity_cmt.VlocityOpenInterface {
    
    global ta_care_querySOSRefillsHelper(){}
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        
        try {
            if (methodName.Equals('GetRefillSOSHistory')) {
                GetRefillSOSHistory(inputMap, outMap, options);
            }
        }
        catch(Exception ex) { outMap.put('error', ex.getStackTraceString()); result = false; }
        return result;
    }
    
   
    global void GetRefillSOSHistory(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        map<string, string> estados = new map<string, string>();
        estados.put('O', 'Abierto');
        estados.put('C', 'Cerrado');
        
        // Vlocity Integration Procedure Obj
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        
        // Getting S_S440 data from IP
        if(!Test.isRunningTest()){
            integProcServ.invokeMethod('IFS_S440', inputMap, outMap, options);           
        }        
        System.debug('Answer S440: ' + outMap);
        Map<String, Object> result = (Map<String, Object>)outMap.get('IPResult');
        List<Object> refillsSOS = (List<Object>)result.get('listaDetallePrestamo');
        List<Object> Payments = (List<Object>)result.get('listaDetalleReembolso');
        List<Object> refillsSOS2 = new List<Object>();
        for (Object r : refillsSOS){
            Map<String, Object> rMap = (Map<String, Object>)r;
            rMap.put('estado', estados.get((string)rMap.get('estadoPrestamoAdq')));
            for (Object p : Payments){
                Map<String, Object> pMap = (Map<String, Object>)p;
                if (rMap.get('fechaAltaProductoAdq').equals(pMap.get('fechaAltaProductoAdq'))){
                    rMap.put('fechaPago', pMap.get('fechaPago'));
                    break;
                }
            }
            refillsSOS2.add(rMap);
        }
        result.put('listaDetallePrestamo', refillsSOS2);
        outMap.put('IPResult', result);
        System.debug(outMap);
        
    }
    
	
	//used for testing service in SIT. data not valid in Desa.
    /*global void queryRefillSOSHistoryCallTester(String event){
        
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        
        Object argsOK = (Object)'{ "codigoAcceso": { "identificadorRecurso": "13800001139", "codSuscripcion": "string" }, "listaDatosAdicionales": [ { "nombreParametro": "string", "valorParametro": "string" } ] }';
        Object argsERROR = (Object)'{ "codigoAcceso": { "identificadorRecurso": "138001139", "codSuscripcion": "string" }, "listaDatosAdicionales": [ { "nombreParametro": "string", "valorParametro": "string" } ] }';
        
        if(event=='OK'){
            inputMap.put('body',argsOK);
        } else if(event=='ERROR'){
            inputMap.put('body',argsERROR);
        }
        
        System.debug('Inputmap: ' + inputMap);
        
        GetRefillSOSHistory(inputMap, outMap, options);
    }*/
    
}