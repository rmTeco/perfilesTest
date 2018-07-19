/**
* Created by Kleytman Aular 22/11/2017
*
* Implements VlocityOpenInterface
* Provides the needed logic to support OS JSON VOI translation
*
* Objects: None - JSON translation for OS
*
* Important: The method uses a VlocityOpenInterface integration structure
*
* Version: 1.1
*/

global with sharing class ta_care_queryRefillsHelper implements vlocity_cmt.VlocityOpenInterface {
    
    global ta_care_queryRefillsHelper(){}
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        
        try {
            if (methodName.Equals('GetRefillHistory')) {
                GetRefillHistory(inputMap, outMap, options);
            }
        }
        catch(Exception ex) { outMap.put('error', ex.getStackTraceString()); result = false; }
        return result;
    }
    
    global void GetRefillHistory(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        // Vlocity Integration Procedure Obj
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        
        // Getting S141 data from IP
        if(!Test.isRunningTest()){
            integProcServ.invokeMethod('IFS_S141', inputMap, outMap, options);
        }
        Map<String, Object> result = (Map<String, Object>)outMap.get('IPResult');
        List<Object> refills = (List<Object>)result.get('ListInfoRecarga');
        List<Object> refills2 = new List<Object>();
        for (Object r : refills){
            Map<String, Object> rmap = (Map<String, Object>)r;
            Map<String, Object> periodo = new Map<String, Object>();
            Map<String, Object> bonusHdr = new Map<String, Object>();
            List<Object> bonus = new List<Object>();
            if (rmap.containsKey('PeriodoRecarga')) {
                periodo = (Map<String, Object>)rmap.get('PeriodoRecarga');
                System.debug(periodo);
                bonusHdr = (Map<String, Object>)periodo.get('ListaBonusBalance');
                System.debug(bonusHdr);
                bonus = (List<Object>)bonusHdr.get('BonusBalance');
                
            } else {
                bonusHdr.put('ListaBonusBalance',bonus);
                periodo.put('PeriodoRecarga', bonusHdr);
            }

            if (bonus.size() > 0){
                rmap.put('Bonus', 'Con Beneficios');
            }else{
                rmap.put('Bonus', 'Sin Beneficios');
            }
                

            refills2.add(rmap);
            
        }
        system.debug(json.serialize(refills2));
        result.put('ListInfoRecarga', refills2);
        outMap.put('IPResult', result);
        System.debug(outMap);
        
    }
/*
    
    global void queryRefillHistoryCallTester(String event){
        
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        
        Object argsOK = (Object)'{ "resultado": { "codigoDeAcceso": { "identificadorRecurso": "3435161523" } }, "cantidadItemsConsulta": 5, "referenciaItemPaginado": 0, "cantidadMaxConsulta": 5 }';
        Object argsERROR = (Object)'{ "resultado": { "codigoDeAcceso": { "identificadorRecurso": "34351523" } }, "cantidadItemsConsulta": 5, "referenciaItemPaginado": 0, "cantidadMaxConsulta": 5 }';
        
        if(event=='OK'){
            inputMap.put('body',argsOK);
        } else if(event=='ERROR'){
            inputMap.put('body',argsERROR);
        }
        
        System.debug('Inputmap: ' + inputMap);
        
        GetRefillHistory(inputMap, outMap, options);
    }
*/
    
}