global with sharing class TransformParam implements vlocity_cmt.VlocityOpenInterface2 {
    
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true; 

        if (outMap == null) {
            //-- Verifico si viene nulo para crearlo, aqui va la respuesta.
            outMap = new Map<String, Object>();
        }

        try {
            if(methodName.equals('getTransformParam1')){
                getTransformParam1(input, outMap);
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
    private void getTransformParam1 (Map<String, Object> pInputMap, Map<String, Object> pOutputMap) {
        System.debug('Metodo: getTransformParam1');

        try {
            if (pInputMap == null || pInputMap.isEmpty()) {
                throw new CalloutException('El inputMap vino nulo o vacio');
            }
            String ljson = JSON.serialize(pInputMap);
            System.debug('..... Json recibido');
            System.debug(ljson);

            Map<String, Object> body = (Map<String, Object>)pInputMap.get('body');
            if (body == null || body.isEmpty()) {
                throw new CalloutException('No se encontro el TAG: body');
            }

            Map<String, Object> cliente = (Map<String, Object>)body.get('cliente');
            if (cliente == null || cliente.isEmpty()) {
                throw new CalloutException('No se encontro el TAG: cliente');
            }

            Map<String, Object> infoIndividuo = (Map<String, Object>)cliente.get('infoIndividuo');
            if (infoIndividuo == null || infoIndividuo.isEmpty()) {
                throw new CalloutException('No se encontro el TAG: infoIndividuo');
            }

            String genero = (String) infoIndividuo.get('genero');
            System.debug('..... Se obtuvo el Genero: ' + genero);
            infoIndividuo.put('genero', getGenero(genero));
            
            String fechaNacimiento = (String) infoIndividuo.get('fechaNacimiento');
            System.debug('..... Se obtuvo la fechaNacimiento: ' + fechaNacimiento);
            infoIndividuo.put('fechaNacimiento', getFechaNacimiento(fechaNacimiento));

            pOutputMap = pInputMap; //-- Modifique el inputMap y lo copio al outMap

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

    /**
     * Objetivo: Recibo un valor que puede ser: Femenino, Masculino
     *           y lo transformo en F o M.
     */
    private String getGenero (String pGeneroToTransform) {
        System.debug('Metodo: getGenero');
        if (String.isBlank(pGeneroToTransform)) {
            throw new CalloutException('El genero vino vacio o nulo');
        }

        if (pGeneroToTransform.equalsIgnoreCase('Femenino')) {
            System.debug('............ Valor retornado: F');
            return 'F';
        }

        if (pGeneroToTransform.equalsIgnoreCase('Masculino')) {
            System.debug('............ Valor retornado: M');
            return 'M';
        }

        throw new CalloutException('El valor recibido: ' + pGeneroToTransform + ' no esta dentro de los valores esperados. [Masculino, Femenino]');
    }

    /**
     * Objetivo: Recibo un valor que es una fecha en formato YYYYMMDD
     *           y lo transformo en YYYY-MM-DD HH:MI:SS
     */
    private String getFechaNacimiento (String pFechaNacimientoToTransform) {
        System.debug('Metodo: getFechaNacimiento');
        if (String.isBlank(pFechaNacimientoToTransform)) {
            throw new CalloutException('La fecha de nacimiento vino vacia o nula');
        }

        if (!pFechaNacimientoToTransform.isNumeric()) {
            throw new CalloutException('El valor recibido: ' + pFechaNacimientoToTransform + ' contiene caracteres NO numericos.');
        }
        
        Integer largo = pFechaNacimientoToTransform.length();
        if (largo != 8) {
            throw new CalloutException('El tamaño de la fecha recibida es menor a 8 caracteres. Largo: ' + largo);
        }

        String anio = pFechaNacimientoToTransform.substring(0,4);
        String mes  = pFechaNacimientoToTransform.substring(4,6);
        String dia  = pFechaNacimientoToTransform.substring(6);

        String retVal = anio + '-' + mes + '-' + dia + ' 00:00:00';
        System.debug('............ Valor retornado: ' + retVal);
        return retVal;
    }
    
}