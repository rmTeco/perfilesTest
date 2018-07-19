global with sharing class IFS_ApruebaLog implements vlocity_cmt.VlocityOpenInterface2
{
public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
         Boolean result = true; 

        if (outMap == null) {
            //-- Verifico si viene nulo para crearlo, aqui va la respuesta.
            outMap = new Map<String, Object>();
        }

        try {  
            if(methodName.equals('logReq')){
                logReq(input, outMap);
            }
            else {
                throw new CalloutException('El metodo ' + methodName + ' no existe.');
            }
        }
        catch(Exception e) {
            System.debug('TransformParam:invokeMethod -> exception: ' + e);
            result = false;
        }
        return result;
    }
    
 
     /**
     * Objetivo: Recibe el body del request en pInputMap y lo devuelve en pOutputMap, con 
     *           las transformaciones procesadas.
     */
    private void logReq (Map<String, Object> pInputMap, Map<String, Object> pOutputMap) {
        System.debug('----------------------- Metodo: logRec');

        try {
            if (pInputMap == null || pInputMap.isEmpty()) {
                throw new CalloutException('El inputMap vino nulo o vacio');
            }
            String ljson = JSON.serialize(pInputMap);
            System.debug('---------------------- Json recibido');
            System.debug(ljson);
            Map<String, Object> mapSetIDServicio = (Map<String, Object>)pInputMap.get('SetIDServicio');
            if (mapSetIDServicio == null || mapSetIDServicio.isEmpty()) {
                throw new CalloutException('------------------  No se encontro el TAG: SetIDServicio');
            }
 //           Map<String, Object> mapIdservicio = (Map<String, Object>) mapSetIDServicio.get('codServicio');
//            if (mapIdservicio == null || mapIdservicio.isEmpty()) {
//                throw new CalloutException('------------------  No se encontro el TAG: codServicio');
//            }
            String strIdServicio = (String)mapSetIDServicio.get('codServicio');
            System.debug('---------------------- codServicio recibido');
            System.debug(strIdServicio);

            Map<String, Object> mapOptions = (Map<String, Object>)pInputMap.get('options');
            String idUnico = null;

            Map<String, Object> mapParams = (Map<String, Object>)pInputMap.get('params');
            if(mapParams == null || mapParams.isEmpty()) {
                idUnico = GuidUtil.NewGuid();
            }
            else
            {
                idUnico =(String) mapParams.get('X-Consumer-Transaction-ID');
            }

            mapOptions.put('idUnico',idUnico);
            pInputMap.put('options',mapOptions);

//            mapParams.put('X-Consumer-Transaction-ID','ZZZZZZZZZZZZZZZ');
//            pInputMap.put('params',mapParams);
            Map<String, Object> body = (Map<String, Object>)pInputMap.get('body');
            // if (body == null || body.isEmpty()) {
            //     throw new CalloutException('------------------  No se encontro el TAG: body');
            // }
//            String valorConsulta = (String)body.get('valorConsulta');
//            if (valorConsulta == null || String.IsBlank(valorConsulta)) {
//                throw new CalloutException('No se encontro el Campo: valorConsulta');
//            }

//            body.put('valorConsulta', valorConsulta);
//            pInputMap.put('body',body);
//            String ijson = JSON.serialize(pInputMap);
//            System.debug('..... Json pInputMap');
//            System.debug(ijson);
            // String valorPepe = (String)body.get('pepe');
            // if (valorPepe == null || String.IsBlank(valorPepe)) {
            //     throw new CalloutException('No se encontro el Campo: pepe');
            // }
            // body.put('pepe','conejo');
            // pInputMap.put('body',body);
            
            // String ijson = JSON.serialize(pInputMap);
            // System.debug('..... Json input nuevo');
            // System.debug(ijson);
            
            // Map<String,Object> bodyMap = (Map<String,Object>) pInputMap.get('body');
            // String oB = JSON.serialize(bodyMap);
            // System.debug('..... obtenido como body');
            // System.debug(oB);
// -------------------------------------------------------------------------------------
            // Invoca a la clase que hace el log por ahora sale en el log de salesg=force
            String fechaTiempo = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
         //   System.debug(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
            //obtengo los parametros para mostrarlos
            String strParams = null;
            if (mapParams == null || mapParams.isEmpty())
            {
                strParams = '  ';
            }
            else
            {
                strParams = JSON.serialize(mapParams);
            }
            System.debug('------------------ Datos que se pasarán a la clase que registra el objeto LOG');
            System.debug('------------------ TimeStamp : ' + fechaTiempo);
            System.debug('------------------ Origen : ' + strIdServicio); 
            System.debug('------------------ X-Consumer-Transaction-ID : ' + idUnico);
            System.debug('------------------ Indicativo req o resp : REQ');
            System.debug('------------------ Parametros : ' + strParams);
            System.debug('------------------ Payload : ');

            pOutputMap = pInputMap; //-- lo copio al outMap
    
  

            String ojson = JSON.serialize(pOutputMap);
            System.debug('..... Json devuelto');
            System.debug(ojson);
        }
        catch (CalloutException ce) {
            throw ce;
        }
        catch (Exception e) {
            throw e;
        }
    
    
    }
}