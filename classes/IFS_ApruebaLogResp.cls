global with sharing class IFS_ApruebaLogResp implements vlocity_cmt.VlocityOpenInterface2
{
public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
         Boolean result = true; 

        if (outMap == null) {
            //-- Verifico si viene nulo para crearlo, aqui va la respuesta.
            outMap = new Map<String, Object>();
        }

        try {
            if(methodName.equals('logResp')){
                logResp(input, outMap);
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
    private void logResp (Map<String, Object> pInputMap, Map<String, Object> pOutputMap) {
        System.debug('----------------------- Metodo: logResp');

        try {
            System.debug('---------------------- ESTA LUEGO RESPONSE    ');
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
            if(mapOptions == null || mapOptions.isEmpty()) {
                throw new CalloutException('------------------  params vacio o nulo');
            }

            Map<String, Object> mapParams = (Map<String, Object>)pInputMap.get('params');
            String strParams = null;
            if (mapParams == null || mapParams.isEmpty())
            {
                strParams = '  ';
            }
            else
            {
                strParams = JSON.serialize(mapParams);
            }

            Map<String,Object> mapRequestInfo = (Map<String, Object>)pInputMap.get('RequestInfo');
            String strStatusCode = (String) mapRequestInfo.get('statusCode');


            Map<String, Object> body = (Map<String, Object>)pInputMap.get('body');
            if (body == null || body.isEmpty()) {
                throw new CalloutException('------------------  No se encontro el TAG: body');
            }
//            String valorConsulta = (String)body.get('valorConsulta');
//            if (valorConsulta == null || String.IsBlank(valorConsulta)) {
//                throw new CalloutException('No se encontro el Campo: valorConsulta');
//            }

//            body.put('valorConsulta', valorConsulta);
//            pInputMap.put('body',body);
//            String ijson = JSON.serialize(pInputMap);
//            System.debug('..... Json pInputMap');
//            System.debug(ijson);


            
            String ijson = JSON.serialize(pInputMap);
            System.debug('..... Json input nuevo');
            System.debug(ijson);
            
            Map<String,Object> bodyMap = (Map<String,Object>) pInputMap.get('body');
            String oB = JSON.serialize(bodyMap);
            System.debug('..... obtenido como body');
            System.debug(oB);

            pOutputMap = pInputMap;
    
  

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