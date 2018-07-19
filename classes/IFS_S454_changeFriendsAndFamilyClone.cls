public with sharing class IFS_S454_changeFriendsAndFamilyClone {

    public static final boolean K_DEBUG_ON = true;

    public ResultObj changeFriendsAndFamily(String jsonInput) {
        printDebug('Entre a changeFriendsAndFamily()' );
		ResultObj resultObject;
        FromJSON jsonBody;

        try {
            try {
                jsonBody = (FromJSON)JSON.deserialize(jsonInput, FromJSON.class);
            }
            catch (Exception e) {
                throw new CalloutException('Error al deserializar los parametros. Error: ' + e.getMessage());
            } 
        
            Integer action = checkContrato (jsonBody); 

            resultObject = new ResultObj(200, Blob.valueOf(JSON.serialize(procesar(jsonBody, action))));
            return resultObject;

        }
        catch (FunctionalException fe) {
        	resultObject = new ResultObj(417, Blob.valueOf(JSON.serialize(getRespuestaNoOk('417',fe.getMessage()))));
        	return resultObject;
        }
        catch (CalloutException ce) {
            resultObject = new ResultObj(400, Blob.valueOf(JSON.serialize(getRespuestaNoOk('400',ce.getMessage()))));
            return resultObject;
        }
        catch(Exception e){
        	resultObject = new ResultObj(500, Blob.valueOf(JSON.serialize(getRespuestaNoOk('500',e.getMessage()))));
            return resultObject;
        }
    }

    /**
     * @Objetivo: Verificar que se cumpla el contrato.
     * Si lo cumple termina y sino dispara la excepción: CalloutException.
     * Retorna: 1: Solo Alta - 2: Solo Baja - 3: Alta y Baja.
     */
    private Integer checkContrato (FromJSON pJson) {
        printDebug('Entre a checkContrato()');

        if (pJson == null) {
            printDebug('El json vino vacio o nulo'); 
            throw new CalloutException('Error en la validacion de los atributos del request. Vino vacio.');
        }


        if (String.isBlank(pJson.choiceId.subscriberId) && String.isBlank(pJson.choiceId.nroLinea)) {
            printDebug('El subscriber y el nroLinea no vinieron o estan vacios, como es un choice alguno tiene que venir con valor'); 
            throw new CalloutException('Error en la validacion de los atributos del request. El choice vino vacio y debe contener al menos uno de los dos datos [subscriberId o nroLinea]');
        }

        if (pJson.lstOfertas == null || pJson.lstOfertas.size()==0) {
            printDebug('Error en la validacion de los atributos del request. Lista de ofertas vacia o nula.'); 
            throw new CalloutException('Error en la validacion de los atributos del request.  Lista de ofertas vacia o nula.');
        }

        Integer lalta = 0; 
        Integer lbaja = 0;

        try {
            for (Integer i=0; i<pJson.lstOfertas.size(); i++) {
                OfertaClass o = pJson.lstOfertas.get(i);
                if (o == null) {
                    throw new CalloutException('Lista de Ofertas con componentes nulos.');
                }
                if (String.isBlank(o.codOperacion)) {
                    throw new CalloutException('Lista de Ofertas, hay componentes con codOperacion nulo o vacio');
                }
                if (!o.codOperacion.equals('A') && !o.codOperacion.equals('B')) {
                    throw new CalloutException('Lista de Ofertas, hay componentes con valor de codOperacion distinto de A=Alta o B=Baja');
                }
                else {
                    lalta = (o.codOperacion.equals('A') || lalta == 1 ? 1 : 0);
                    lbaja = (o.codOperacion.equals('B') || lbaja == 1 ? 1 : 0);
                }

                if (String.isBlank(o.ofertaId)) {
                    throw new CalloutException('Lista de Ofertas, hay componentes con ofertaId nulo o vacio.');
                }
                if (o.lstLineas == null || o.lstLineas.size()==0) {
                    throw new CalloutException('Lista de Numeros en objeto Oferta vino nulo o vacio.');
                }
                //-- Valido lista de lineas.
                for (Integer j=0; j<o.lstLineas.size(); j++) {
                    LineaClass linea = o.lstLineas.get(j);
                    if (linea == null) {
                        throw new CalloutException('La lista de numeros contiene valores nulos.');                            
                    }
                    if (o.codOperacion.equals('B') && String.isBlank(linea.assetId)) {
                        throw new CalloutException('El assetId vino vacio o nulo y su valor se necesita porque la operacion es Baja.');                            
                    }
                    if (String.isBlank(linea.nroLinea)) {
                        throw new CalloutException('Vino un valor de numero de linea nulo o vacio.');                            
                    }
                    if (o.codOperacion.equals('A') && String.isBlank(linea.tipo)) {
                        throw new CalloutException('Vino un valor de tipo de linea nulo o vacio y es necesario porque la operacion es Alta.');                            
                    }
                }
            }
            if (lalta == 0 && lbaja == 0) {
                printDebug('--- No se encontro operaciones de Alta o Baja en el Request.'); 
                throw new CalloutException('No se encontro operaciones de Alta o Baja en el Request.');
            }
            if (lalta == 1 && lbaja == 0) {
                return (Integer)1;
            }
            else if (lalta == 0 && lbaja == 1) {
                return (Integer)2;
            }
            else {
                return (Integer)3;
            }
        }
        catch (Exception e) {
            printDebug('Error en la validacion de los atributos del request. ' + e.getMessage()); 
            throw new CalloutException('Error en la validacion de los atributos del request. ' + e.getMessage());
        }
    }

    /*
     * Esta funcion procesa el requerimiento una vez validados sus atributos.
     */
    private ToJson procesar (FromJSON pJsonBody, Integer pAction) {  
        printDebug('metodo procesar() - pAction --> ' + pAction);
        printLimitAndUsedSize();
        String orderId = null;
        ToJson toJson = new ToJson();

        printLimitAndUsedSize();


        if (pAction == 2 || pAction == 3) {
            Boolean chargeOk = true;
            if (!chargeOk) {
                throw new FunctionalException('Fallo al procesar el cargo por baja numero amigo.');
            }
            //-- Si hay baja deberia procesar el cargo a cobrar
            //-- si no puedo deberia abortar en este punto aqui.
        }

        Map<String, Object> orderMap = createOrderProcess (pJsonBody);
        toJson.orderNumber=(String)orderMap.get('orderNumber');
        toJson.codResultado='0';
        toJson.descResultado='OK';

        orderId = (String)orderMap.get('orderId');
        String json = JSON.serialize(pJsonBody);
        IFS_S454_orderProcess op = new IFS_S454_orderProcess(orderId, json, pAction);
        ID jobID = System.enqueueJob(op);
        printDebug('Process End - Enqueued order process id ' + jobID);
        
        return toJson;
    }

/*
    private ToJson processOrder(FromJSON pJsonBody, Integer pAction) {
            printDebug('metodo processOrder()');
            printLimitAndUsedSize();
            ToJson toJson = new ToJson();

            if (String.isBlank(pJsonBody.orderId)) {
                printDebug(' --- Error al crear la orden.');
                throw new FunctionalException('No vino el Id de la orden a procesar');
            }

            List<OrderItem> lstOrderItems = getOrderItems (pJsonBody.orderId);
            if (lstOrderItems == null || lstOrderItems.isEmpty()) {
                printDebug(' --- No se pudo obtener los items de la orden para procesarlos - OrderId --> ' + pJsonBody.orderId);
                throw new FunctionalException('No se pudo obtener los items de la orden para procesarlos - OrderId --> ' + pJsonBody.orderId);
            }
            List<Map<String, Object>> lstInputParamsAlta = new List<Map<String, Object>>();

            if (pAction == 1) {   //-- Viene solo Alta.
                procesarAltas (pJsonBody.orderId, pJsonBody, lstOrderItems, false);
            }
            else if (pAction == 2) {   //-- Viene solo baja.
                procesarBajas (pJsonBody.orderId, pJsonBody, lstOrderItems);
            }
            else {  //-- Viene Altas y Bajas.
                procesarBajas (pJsonBody.orderId, pJsonBody, lstOrderItems);
                procesarAltas (pJsonBody.orderId, pJsonBody, lstOrderItems, true);
            } 

            toJson.orderId = pJsonBody.orderId;
            toJson.codResultado = '0';
            toJson.descResultado = 'OK';

            return toJson;
    }
*/
    private Map<String, Object> createOrderProcess (FromJSON pJsonBody) {
            printDebug('metodo createOrderProcess()');
            printLimitAndUsedSize();

            //-- Creo la orden draft para la cuenta obtenida.
            String accountId = null;
            String planId = null;
            String orderId = null;
            ToJson toJson = new ToJson();

            Map<String, Object> datosMap = null;
            //-- Obtengo el accountId por subscriber o por msisdn
            if (!String.isBlank(pJsonBody.choiceId.subscriberId)) {
                datosMap = getAccountIdBySubscriptorId(pJsonBody.choiceId.subscriberId);
            }
            else {
                datosMap = getAccountIdByMSISDN(pJsonBody.choiceId.nroLinea);
            }
            if (datosMap == null || datosMap.isEmpty()) {
                throw new FunctionalException('No se pudo obtener el Account Id y el Id del Plan');
            } 

            accountId = (String)datosMap.get('accountId');
            planId = (String)datosMap.get('rootItemId');

            Map<String, Object> orderResponse = new Map<String, Object>();   
            orderResponse = createOrder(accountId, planId); 
            return orderResponse;
    }

    private OrderItem getParentOrderItem (List<OrderItem> pLstOrderItems, Id pAssetId) {
        printDebug('----- getParentOrderItem() - pAssetId --> ' + pAssetId);
        try {
            Boolean found = false;
            Integer ixd=0; 
            for (Integer i=0; i<pLstOrderItems.size() && !found; i++) {
                OrderItem oi = pLstOrderItems[i];
                found = oi.Vlocity_cmt__AssetId__c == pAssetId;
                if (found) {
                    ixd = i;
                }
            }
            if (found) {
                return pLstOrderItems[ixd];
            }
            else {
                return null;
            }
        }
        catch (Exception e) {
            throw e;
        }
        
    }

    private void procesarAltas (Id pOrderId, FromJson pJsonBody, List<OrderItem> pLstOrderItems, Boolean pHayBajas) {
        printDebug('----- procesarAltas() - pOrderId --> ' + pOrderId);
        List<Map<String, Object>> lstInputParamsAlta = new List<Map<String, Object>>();
        Id rootNumerosAmigosId = null;
        for (Integer i=0; pJsonBody != null && i<pJsonBody.lstOfertas.size(); i++) {   //-- Recorro las ofertas.
            printDebug('-------- Obtengo lista de ofertas del request.');
            OfertaClass oferta = pJsonBody.lstOfertas.get(i);
            OrderItem oi = getParentOrderItem (pLstOrderItems, Id.valueOf(oferta.ofertaId));
            if (oi == null) {
                throw new FunctionalException('Fallo al procesar la Oferta --> ' + oferta.ofertaId);
            }
            if (oferta.codOperacion != 'A') {
                continue; //-- Solo proceso Altas.
            }
            String itemId = getProiceBookEntryId(oi.ProductCode__c);
            printDebug('--------- Obtengo lista de lineas a dar de alta del request.');
            List<LineaClass> lstLineas = oferta.lstLineas;
            for (Integer a=0; lstLineas != null && a < lstLineas.size(); a++) {  //-- Recorro las lineas de la oferta.
                Map<String, Object> parentRecordFields = new Map<String, Object>();
                Map<String, Object> parentRecord = new Map<String, Object>();
                Map<String, Object> mappa = new Map<String, Object>();
                Map<String, Object> item = new Map<String, Object>();

                mappa.put('itemId', itemId);
                mappa.put('parentId', oi.id);
                parentRecordFields.put('productHierarchyPath', oi.Vlocity_cmt__ProductHierarchyPath__c);
                parentRecordFields.put('isVirtualItem', false);
                parentRecord.put('records', new List<Object>());
                ((List<Object>)parentRecord.get('records')).add(parentRecordFields);
                mappa.put('parentRecord', parentRecord);
                lstInputParamsAlta.add(mappa);
            }    
        }
        if (lstInputParamsAlta != null && !lstInputParamsAlta.isEmpty()) {
            addOrderItem(pOrderId, lstInputParamsAlta);
        }
        else {
            throw new FunctionalException('No se genero la lista de parametros para dar del alta el item.');
        }
    }

    private void procesarBajas (Id pOrderId, FromJson pJsonBody, List<OrderItem> pLstOrderItems) {
        printDebug('--- procesarBajas()');
        for (Integer i=0; i<pJsonBody.lstOfertas.size(); i++) {
            OfertaClass oferta = pJsonBody.lstOfertas.get(i);
            if (oferta.codOperacion != 'B') {
                continue; //-- Solo proceso Altas.
            }
            List<LineaClass> lstLineas = oferta.lstLineas;
            for (Integer a=0; lstLineas != null && a < lstLineas.size(); a++) {
                Map<String, Object> item = new Map<String, Object>();
                Id assetId = Id.valueOf(lstLineas[a].assetId);
                OrderItem oi = getOrderItem(pLstOrderItems, assetId);
                if (oi == null) {
                    throw new FunctionalException('No posee Numeros Amigos para dar de Baja.');
                }
                else {
                    Asset asset = getAssetById (lstLineas[a].assetId);
                    if (asset == null) {
                        printDebug('No se pudo recuperar los datos del Asset para procesar el item - AssetId --> ' + lstLineas[a].assetId);
                        throw new FunctionalException('No se pudo recuperar los datos del Asset para procesar el item - AssetId --> ' + lstLineas[a].assetId);
                    }
                    delOrderItem(pOrderId, oi.Id);
                }
            }    
        }    
    }

    private Id getProiceBookEntryId (String pProductCode) {
        if (String.isBlank(pProductCode)) {
            return '01u6C000000xXNJQA2';
        }
        else {
            Boolean isVoz = pProductCode.indexOfIgnoreCase('FAN_PA_FNF_00001')>-1;
            return (isVoz) ? Id.valueOf('01u6C000000xXNJQA2') : Id.valueOf('01u6C000000xZIyQAM');
        }
    }

    private void updateItem (Id pOrderId, Id pItemId) {
        OrderItem orderItem = [SELECT Id, vlocity_cmt__Action__c, vlocity_cmt__ProvisioningStatus__c FROM OrderItem WHERE Id = :pItemId AND orderId = :pOrderId];
        if (orderItem != null) {
            orderItem.vlocity_cmt__Action__c = 'Add';
            orderItem.vlocity_cmt__ProvisioningStatus__c = 'New';
            update orderItem;
        }
        else {
            throw new FunctionalException('Fallo al obtener el itemId --> ' + pItemId + ' de la orden draft --> ' + pOrderId + ' para setear los codigos de baja.');
        }
        printLimitAndUsedSize();
    }

    private void delOrderItem(Id pOrderId, Id pItemId) {
        printDebug('Entre a delOrderItem() - pOrderId --> ' + pOrderId + ' - pItemId --> ' + pItemId);
        printLimitAndUsedSize();

        Map<String, Object> inMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        inMap.put('id', pItemId);
        inMap.put('cartId', pOrderId);
        inMap.put('methodName', 'deleteCartsItems');

        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if (appHandler==null) {
            throw new FunctionalException('Fallo al instanciar el servicio: vlocity_cmt.CpqAppHandler');
        }
        appHandler.invokeMethod('deleteCartsItems', inMap, outMap, null);

        if (outMap == null || outMap.isEmpty()) {
            throw new FunctionalException('El servicio devolvio el mapa vacio');
        } 

/*
        OrderItem orderItem = [SELECT Id, vlocity_cmt__Action__c, vlocity_cmt__ProvisioningStatus__c FROM OrderItem WHERE Id = :pItemId AND orderId = :pOrderId];
        if (orderItem != null) {
            orderItem.vlocity_cmt__Action__c = 'Disconnect';
            orderItem.vlocity_cmt__ProvisioningStatus__c = 'Deleted';
            update orderItem;
        }
        else {
            throw new FunctionalException('Fallo al obtener el itemId --> ' + pItemId + ' de la orden draft --> ' + pOrderId + ' para setear los codigos de baja.');
        }
*/          
        printLimitAndUsedSize();
    }


    /**
     * @Objectivo: Obtener los Items de una orden.
     */
    private List<OrderItem> getOrderItems (String pOrderId) {
        try {
            printDebug('Entre en getOrdersItems() - pOrderId --> ' + pOrderId);
            List<OrderItem> lstOrderItems = [SELECT Id, Vlocity_cmt__ParentItemId__c, Vlocity_cmt__AssetId__c, Vlocity_cmt__ProductHierarchyPath__c, Vlocity_cmt__RootItemId__c, ProductCode__c
             FROM OrderItem WHERE orderId = :pOrderId] ;

            System.debug('lstOrderItems --> ' + lstOrderItems);

            return lstOrderItems;
        }
        catch (Exception e) {
            throw new FunctionalException(e.getMessage());
        }
    }


    private void addOrderItem(Id pOrderId, List<Map<String, Object>> pLstItems) {
        printDebug('Entre a addOrderItem() - pOrderId --> ' + pOrderId);

        try {
            Map<String, Object> inMap = new Map<String, Object>();
            Map<String, Object> outMap = new Map<String, Object>();

            inMap.put('price', true);
            inMap.put('validate', true);
            inMap.put('includeAttachment', false);
            inMap.put('pagesize', 20);
            inMap.put('hierarchy', -1);
            inMap.put('items', pLstItems);
            inMap.put('cartId', pOrderId);
            inMap.put('methodName', 'postCartsItems');

            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            if (appHandler==null) {
                throw new FunctionalException('Fallo al instanciar el servicio: vlocity_cmt.CpqAppHandler');
            }
            appHandler.invokeMethod('postCartsItems', inMap, outMap, null);
            if (outMap == null || outMap.isEmpty()) {
                throw new FunctionalException('El servicio devolvio el mapa vacio');
            } 
        }
        catch (Exception e) {
            String stackTrace = e.getStackTraceString();
            printDebug('===========================================================================');
            printDebug(stackTrace);
            printDebug('===========================================================================');
            throw new FunctionalException('Error agregar items a la orden. Error: ' + e.getMessage());
        }

    }

    /**
     * @Objetivo: Actualiza los items insertados en la orden con los atributos recibidos
     *            en el request.
     */
    private Map<String, Object>  updateItemsAttributes (String pOrderId, List<OfertaClass> pLstOfertas) {
        printDebug('Entre a updateItemsAttributes(String, List<OfertaClass>)');
        Map<String, Object> outMap = null;
        String mensaje = '';

        try {
            if (String.isBlank(pOrderId)) {
                throw new FunctionalException('El numero de orden vino nulo o vacio');
            }

            List<OrderItem> lstItems = [SELECT Id, PriceBookEntryId, vlocity_cmt__Action__c, vlocity_cmt__SubAction__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__JSONAttribute__c FROM OrderItem WHERE OrderId = :pOrderId];
            for (OrderItem item : lstItems) {
                Map<String, Object> jsonAttributes = (Map<String, Object>)JSON.deserializeUntyped(item.vlocity_cmt__JSONAttribute__c);
                String priceBookEntryId = item.PriceBookEntryId;
                mensaje = 'Antes de llamar getDatosNroAmigos';
                Map<String, Object> mapaItem = getDatosNroAmigos(priceBookEntryId, pLstOfertas);
                if (jsonAttributes != null && !jsonAttributes.isEmpty()) {
                    mensaje = 'Antes de jsonAttributes.keySet()';
                    Set<String> attributesKeys = jsonAttributes.keySet();
                    for(String attributeKey : attributesKeys){
                        mensaje = 'paso 1';
                        List<Object> attributes = (List<Object>)jsonAttributes.get(attributeKey);
                        for(Object attribute : attributes){
                            mensaje = 'paso 2';
                            Map<String, Object> mapAttribute = (Map<String, Object>) attribute;
                            mensaje = 'paso 3';
                            String categoria = (String)mapAttribute.get('categorycode__c');
                            if (!String.isBlank(categoria) && categoria == 'FAN_ATTCAT_000047') {
                                mensaje = 'paso 4';
                                printDebug('---- Encontre FAN_ATTCAT_000047');
                                mensaje = 'paso 5';
                                String unicode = (String)mapAttribute.get('attributeuniquecode__c');
                                if (!String.isBlank(unicode) && unicode == 'FAN_ATT_000057') {
                                    mensaje = 'paso 6';
                                    printDebug('---- ----- Encontre FAN_ATT_000057');
                                    Map<String, Object> mapAttributeRunTimeInfo = (Map<String, Object>)mapAttribute.get('attributeRunTimeInfo');
                                    if (mapAttributeRunTimeInfo != null) {
                                        mensaje = 'paso 7';
                                        mapAttributeRunTimeInfo.put('value', (String)mapaItem.get('nroLinea'));
                                        if (mapaItem != null && !mapaItem.isEmpty()) {
                                            if (mapaItem.get('operacion') == 'A') {
                                                item.vlocity_cmt__Action__c = 'Add';
                                                item.vlocity_cmt__ProvisioningStatus__c = 'New';
                                            }
                                            else {
                                                item.vlocity_cmt__Action__c = 'Disconnect';
                                                item.vlocity_cmt__ProvisioningStatus__c = 'Deleted';
                                            }
                                        }        
                                    }
                                }
                                else if (!String.isBlank(unicode) && unicode == 'FAN_ATT_000129') {
                                    mensaje = 'paso 8';
                                    printDebug('---- ----- Encontre FAN_ATT_000129');
                                    Map<String, Object> mapAttributeRunTimeInfo = (Map<String, Object>)mapAttribute.get('attributeRunTimeInfo');
                                    List<Object> lstTiposValues = (List<Object>)mapAttributeRunTimeInfo.get('values');
                                    mensaje = 'paso 9';
                                    String tipo = (String)mapaItem.get('tipo');
                                    printDebug('----- Voy a buscar el tipo: ' + tipo);
                                    Boolean encontre = false;
                                    Map<String, Object> desconocidoValue = null;
                                    for (Object tipoValue : lstTiposValues) {
                                        mensaje = 'paso 9.1';
                                        Map<String, Object> mapValue = (Map<String, Object>)tipoValue;
                                        mensaje = 'paso 9.2';
                                        String ltipo = (String)mapValue.get('value');
                                        mensaje = 'paso 9.3';
                                        if (!String.isBlank(ltipo) && ltipo.equalsIgnoreCase(tipo)) {
                                            mensaje = 'paso 9.4';
                                            mapAttributeRunTimeInfo.put('selectedItem', tipoValue);
                                            encontre = true;
                                            break;
                                        }
                                        else if (!String.isBlank(ltipo) && ltipo.equalsIgnoreCase('Desconocido')) {
                                            mensaje = 'paso 9.5';
                                            desconocidoValue = mapValue;
                                        }    
                                    }
                                    if (!encontre) {
                                        mensaje = 'paso 9.6';
                                        mapAttributeRunTimeInfo.put('selectedItem', desconocidoValue);     
                                    }
                                }
                            }        
                        }
                    }    
                }
                printDebug(' --- Voy a actualizar el item ');
                mensaje = 'paso 10';

                item.vlocity_cmt__JSONAttribute__c = JSON.serialize(jsonAttributes);
            }    
            update lstItems;

            return outMap;
        }
        catch (Exception e) {
            throw new FunctionalException('Error al actualizar los items de la orden. Error: ' + e.getMessage() + ' - ' + mensaje);
        }

    }


                   
    /**
     * @Objetivo: Actualiza los items insertados en la orden con los atributos recibidos
     *            en el request.
     */
    private Map<String, Object>  updateItemsAttributes (String pOrderId, List<Map<String, Object>> pLstItemsId, List<OfertaClass> pLstOfertas) {
        printDebug('Entre a updateItemsAttributes()');
        Map<String, Object> outMap = null;

        try {
            if (String.isBlank(pOrderId)) {
                printDebug(' --- El numero de orden vino nulo o vacio');
                throw new FunctionalException('El numero de orden vino nulo o vacio');
            }

            if (pLstItemsId == null || pLstItemsId.isEmpty()) {
                printDebug(' --- El parametro pLstItemIds donde viene el Item Id vino nulo');
                throw new FunctionalException('El parametro pLstItemIds donde viene el Item Id vino nulo');
            }

            String[] listaIds = getStrValues(pLstItemsId);

            List<OrderItem> lstItems = [SELECT Id, PriceBookEntryId, vlocity_cmt__JSONAttribute__c FROM OrderItem WHERE OrderId = :pOrderId AND Id IN :listaIds];
            for (OrderItem item : lstItems) {
                Map<String, Object> jsonAttributes = (Map<String, Object>)JSON.deserializeUntyped(item.vlocity_cmt__JSONAttribute__c);
                String priceBookEntryId = item.PriceBookEntryId;
                Map<String, Object> mapaItem = getDatosNroAmigos(priceBookEntryId, pLstOfertas);
                if (jsonAttributes != null && !jsonAttributes.isEmpty()) {
                    Set<String> attributesKeys = jsonAttributes.keySet();
                    for(String attributeKey : attributesKeys){
                        List<Object> attributes = (List<Object>)jsonAttributes.get(attributeKey);
                        for(Object attribute : attributes){
                            Map<String, Object> mapAttribute = (Map<String, Object>) attribute;
                            String categoria = (String)mapAttribute.get('categorycode__c');
                            if (!String.isBlank(categoria) && categoria == 'FAN_ATTCAT_000047') {
                                printDebug('---- Encontre FAN_ATTCAT_000047');
                                String unicode = (String)mapAttribute.get('attributeuniquecode__c');
                                if (!String.isBlank(unicode) && unicode == 'FAN_ATT_000057') {
                                    printDebug('---- ----- Encontre FAN_ATT_000057');
                                    Map<String, Object> mapAttributeRunTimeInfo = (Map<String, Object>)mapAttribute.get('attributeRunTimeInfo');
                                    if (mapAttributeRunTimeInfo != null) {
                                        mapAttributeRunTimeInfo.put('value', (String)mapaItem.get('nroLinea'));
                                    }
                                }
                                else if (!String.isBlank(unicode) && unicode == 'FAN_ATT_000129') {
                                    printDebug('---- ----- Encontre FAN_ATT_000129');
                                    Map<String, Object> mapAttributeRunTimeInfo = (Map<String, Object>)mapAttribute.get('attributeRunTimeInfo');
                                    List<Object> lstTiposValues = (List<Object>)mapAttributeRunTimeInfo.get('values');
                                    String tipo = (String)mapaItem.get('tipo');
                                    printDebug('----- Voy a buscar el tipo: ' + tipo);
                                    Boolean encontre = false;
                                    Map<String, Object> desconocidoValue = null;
                                    for (Object tipoValue : lstTiposValues) {
                                        printDebug((String)tipoValue);
                                        Map<String, Object> mapValue = (Map<String, Object>)tipoValue;
                                        String ltipo = (String)mapValue.get('value');
                                        if (!String.isBlank(ltipo) && ltipo.equalsIgnoreCase(tipo)) {
                                            mapAttributeRunTimeInfo.put('selectedItem', tipoValue);
                                            encontre = true;
                                            break;
                                        }
                                        else if (!String.isBlank(ltipo) && ltipo.equalsIgnoreCase('Desconocido')) {
                                            desconocidoValue = mapValue;
                                        }    
                                    }
                                    if (!encontre) {
                                        printDebug('No encontre valor asigno desconocido');
                                        mapAttributeRunTimeInfo.put('selectedItem', desconocidoValue);     
                                    }
                                }
                            }        
                        }
                    }    
                }
                printDebug(' --- Voy a actualizar el item ');
                item.vlocity_cmt__JSONAttribute__c = JSON.serialize(jsonAttributes);
            }    
            update lstItems;

            return outMap;
        }
        catch (Exception e) {
            String stackTrace = e.getStackTraceString();
            printDebug('===========================================================================');
            printDebug(stackTrace);
            printDebug('===========================================================================');
            throw new FunctionalException('Error al actualizar los items de la orden. Error: ' + e.getMessage());
        }

    }


    /**
     * @Objetivo: Dado un priceBookEntryId devuelve los datos para cargar en los atributos.
     */
    private Map<String, Object> getDatosNroAmigos (String pPriceBookEntryId, List<OfertaClass> pLstOfertas) {
        printDebug('Entre en getDatosNroAmigos');

        if (pLstOfertas == null || pLstOfertas.isEmpty()) {
            throw new FunctionalException('La lista de ofertas vino vacia o nula');
        }

        Map<String, Object> resultado = new Map<String, Object>();
        for (Integer i=0; i < pLstOfertas.size(); i++) {
            OfertaClass oferta = (OfertaClass) pLstOfertas.get(i);
            if (oferta != null) {
                List<LineaClass> lstLineas = oferta.lstLineas;
                for (Integer j=0; j < lstLineas.size(); j++) {
                    String assetId = lstLineas.get(j).priceBookEntryId;
                    if (pPriceBookEntryId.equals(assetId)) {
                        printDebug('........ Encontre el PriceBookEntryId: ' + assetId);
                        resultado.put('nroLinea', lstLineas.get(j).nroLinea);
                        resultado.put('tipo', lstLineas.get(j).tipo);
                        resultado.put('operacion', oferta.codOperacion);
                        //lstLineas.remove(j);
                        return resultado;
                    }
                }    
            }
        }
        return resultado;
    }

    /**
     * @Objetivo: Recibe una lista de ofertas y arma un String con el 
     *            formato valor,valor para poder usar en el query de DB(Select IN).
     */
    private String[] getStrValues (List<Map<String, Object>> pLstItemIds) {
        printDebug('Entre en getStringValues');
        if (pLstItemIds == null || pLstItemIds.isEmpty()) {
            throw new FunctionalException('La lista de ofertas vino vacia o nula');
        }
        String strRespuesta = null;
        for (Integer i=0; i<pLstItemIds.size();i++) {
            Map<String, Object> item = pLstItemIds.get(i);
            if (i==0) {
                strRespuesta=(String)item.get('id');
            }
            else {
                strRespuesta+=','+(String)item.get('id');
            }
        }

        return strRespuesta.split(',');
    }

    /**
     * @Objetivo: Esta funcion obtiene el rootItemId del Asset buscandolo por subscritorId.
     */
     
    private Map<String, Object> getAccountIdBySubscriptorId (String pSubscritorId) {
        printDebug('Entre a getAccountIdBySubscriptorId()');
        String accountId = null;
        
        if (String.isBlank(pSubscritorId)) {
            printDebug(' ---- El pSubscritorId vino vacio');
            throw new CalloutException('El pSubscritorId vino vacio');
        }

        try {
            Asset asset = [SELECT AccountId, vlocity_cmt__RootItemId__c FROM Asset WHERE Subscription_Id__c = :pSubscritorId];
            if (asset != null) {
                Map<String, Object> respuesta = new Map<String, Object>();
                respuesta.put('accountId', asset.AccountId);
                respuesta.put('rootItemId', asset.vlocity_cmt__RootItemId__c);
                return respuesta;
            }
            else {
                throw new FunctionalException('Error al obtener el AccountId del SubscriptionId: ' + pSubscritorId);
            }
        }
        catch (Exception e) {
            printDebug(' ---- Error al obtener el AccountId del subscriptionId: ' + pSubscritorId + '. Error: ' + e.getMessage());
            throw new FunctionalException('Error al obtener el AccountId del subscriptionId: ' + pSubscritorId + '. Error: ' + e.getMessage());
        }    
    }

    /**
     * @Objetivo: Esta funcion obtiene el rootItemId del Asset buscandolo por MSISDN.
     */
     
    private Map<String, Object> getAccountIdByMSISDN (String pNroLinea) {
        printDebug('Entre a getAccountIdByMSISDN()');

        if (String.isBlank(pNroLinea)) {
            printDebug(' ---- El pNroLinea vino vacio');
            throw new CalloutException('El pNroLinea vino vacio');
        }
        
        try {
            Asset asset = [SELECT AccountId, vlocity_cmt__RootItemId__c FROM Asset WHERE MSISDN__c = :pNroLinea];
            if (asset != null) {
                Map<String, Object> respuesta = new Map<String, Object>();
                respuesta.put('accountId', asset.AccountId);
                respuesta.put('rootItemId', asset.vlocity_cmt__RootItemId__c);
                return respuesta;
            }
            else {
                throw new FunctionalException('Error al obtener el AccountId del MSISDN: ' + pNroLinea);
            }
        }
        catch (Exception e) {
            printDebug(' --- Error al obtener el AccountId del MSISDN: ' + pNroLinea + '. Error: ' + e.getMessage());
            throw new FunctionalException('Error al obtener el AccountId del MSISDN: ' + pNroLinea + '. Error: ' + e.getMessage());
        }    
    }



    /**
     * @Objetivo: Esta funcion obtiene un Asset by AssetId.
     */
     
    private Asset getAssetById (String pAssetId) {
        printDebug('Entre a getAssetById() - pAssetId --> ' + pAssetId);
        String accountId = null;

        if (String.isBlank(pAssetId)) {
            return null;
        }
        
        try {
            Asset asset = [select vlocity_cmt__PricebookEntryId__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__RootItemId__c from Asset where Id = :pAssetId];
            return asset;
        }
        catch (Exception e) {
            printDebug(' --- Error al obtener el Asset del AssetId: ' + pAssetId + '. Error: ' + e.getMessage());
            throw new FunctionalException('Error al obtener el Asset del AssetId: ' + pAssetId + '. Error: ' + e.getMessage());
        }    
    }


    /**
     * @Objetivo: Esta funcion obtiene un Asset by AssetId.
     */
     
    private Asset getAssetSonById (String pAssetId) {
        printDebug('Entre a getAssetSonById() - pAssetId --> ' + pAssetId);
        String accountId = null;

        if (String.isBlank(pAssetId)) {
            return null;
        }
        
        try {
            Asset asset = [select vlocity_cmt__PricebookEntryId__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__RootItemId__c from Asset where vlocity_cmt__ParentItemId__c = :pAssetId];
            return asset;
        }
        catch (Exception e) {
            printDebug(' --- Error al obtener el Asset Hijo del AssetId: ' + pAssetId + '. Error: ' + e.getMessage());
            throw new FunctionalException('Error al obtener el Asset Hijo del AssetId: ' + pAssetId + '. Error: ' + e.getMessage());
        }    
    }


    private Map<String, Object> createOrder (String pAccountId, String pPlanId) {
        printDebug('Entre a createOrder(assetToOrder)');
        try {
            String orderId = null;
            String orderNumber = null;
            Map<String, Object> mapa = new Map<String, Object>();
            mapa.put('methodName', 'assetToOrder');
            mapa.put('subaction', 'assetToOrder');
            mapa.put('accountId', pAccountId);
            DateTime fo = DateTime.now();
            mapa.put('requestDate', fo.format('yyyy-MM-dd'));  
            mapa.put('id',pPlanId);

            printDebug('..... Crear orden - Inicio  ');
            Map<String, Object> outMap = new Map<String, Object>();
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            appHandler.invokeMethod((String)mapa.get('methodName'), mapa, outMap, null);
                
            printDebug('..... Crear orden - Despues de invocar el servicio ');    
            if (outMap == null || outMap.isEmpty()) {
                throw new FunctionalException('Error al crear la orden, el servicio devolvio el mapa vacio');
            }

            printDebug('..... Crear orden - Antes de empezar a recorrer el pbe list ');    
            vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult)outMap.get(vlocity_cmt.JSONResult.JSON_KEY_RESULT);  
            List<vlocity_cmt.JSONRecord> pbeList  =  (List<vlocity_cmt.JSONRecord>)result.records;
            printDebug(String.valueOf(pbeList));    
            for(vlocity_cmt.JSONRecord record: pbeList){
                orderId = (String)record.fields.get('cartId');
            }

            if (!String.isBlank(orderId)) {
                Order order = [SELECT Id, Gestion__c, OrderNumber FROM Order WHERE Id = :orderId];
                if (order != null) {
                    orderNumber = String.valueOf(order.OrderNumber);
                    order.Gestion__c = 'Numero Gratis';
                    order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MobilePhoneOrder').getRecordTypeId();
                    update order;
                }
            }
            else {
                throw new FunctionalException('Fallo al crear la orden');
            }
            Map<String, Object> orderMap = new Map<String, Object>();
            orderMap.put('orderId', orderId);
            orderMap.put('orderNumber', orderNumber);
            return orderMap;
        } 
        catch (Exception e) {
            printDebug('............ createOrder - \n' + e.getStackTraceString());
            throw new FunctionalException(e.getMessage());
        }
    }

    /**
     * @Objectivo: Obtener todos los items de una orden creada.
     */
    private List<OrderItem> getOrdenItems (Id pOrderId) {
        printDebug('---- getOrdenItems() - pOrderId --> ' + pOrderId);
        printDebug(' getOrdenItems() orderId --> ' + pOrderId);
        try {
            List<OrderItem> lstOrderItem = [SELECT Id, vlocity_cmt__ParentItemId__c, PricebookEntryId, vlocity_cmt__AssetId__c, vlocity_cmt__Action__c, vlocity_cmt__SubAction__c, vlocity_cmt__JSONAttribute__c,  vlocity_cmt__ProvisioningStatus__c FROM OrderItem WHERE orderId = :pOrderId ];
            return lstOrderItem;
        }
        catch (Exception e) {
            throw new FunctionalException(e.getMessage());
        }
    }

    /**
     * @Objetivo: Recibe una lista de OrderItems y devuelve el que contiene el pAssetId
     */
    private OrderItem getOrderItem (List<OrderItem> pLstOrderItems, Id pAssetId) {
        printDebug('---- getOrderItem() - pLstOrderItems --> ' + pLstOrderItems + ' - pAssetId --> ' + pAssetId);
        if (pAssetId == null) {
            return null; //-- Puede venir en nulo.
        }
        for (Integer i=0; i < pLstOrderItems.size(); i++) {
            if (pLstOrderItems[i].vlocity_cmt__AssetId__c == pAssetId) {
                return pLstOrderItems[i];
            }
        }
        return null;
    }


    /*
     * @Objetivo: Esta funcion recibe un Map<String, Object> que contiene los datos que permiten
     *            crear una order.
     */
/*     
    private List<Map<String, Object>> addDelItemsToOrder (Map<String, Object> pInputMap) {
        printDebug('Entre a addDelItemsToOrder()');
        Map<String, Object> outMap = new Map<String, Object>();
        vlocity_cmt.JSONField itemId = null;
        List<Map<String, Object>> respuesta = new List<Map<String, Object>>();

        try {
            if (pInputMap == null || pInputMap.isEmpty()) {
                throw new FunctionalException('El inputMap vino nulo o vacio');
            }
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            if (appHandler==null) {
                throw new FunctionalException('Fallo al instanciar el servicio: vlocity_cmt.CpqAppHandler');
            }
            String methodName = (String)pInputMap.get('methodName');
            if (String.isBlank(methodName)) {
                throw new FunctionalException('El methodName vino nulo o vacio en el InputMap');
            }


            if (!Test.isRunningTest()) {
                appHandler.invokeMethod(methodName, pInputMap, outMap, null);

                if (outMap == null || outMap.isEmpty()) {
                    throw new FunctionalException('El servicio devolvio el mapa vacio');
                } 

                vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult)outMap.get(vlocity_cmt.JSONResult.JSON_KEY_RESULT);    
                List<vlocity_cmt.JSONRecord> pbeList  =  (List<vlocity_cmt.JSONRecord>)result.records;
                for(vlocity_cmt.JSONRecord record: pbeList){
                    Map<String, Object> mid = new Map<String, Object>();
                    vlocity_cmt.JSONField fieldId = (vlocity_cmt.JSONField)record.fields.get('Id');
                    Product2 fieldProduct2 = (Product2)record.fields.get('Product2');
                    vlocity_cmt.JSONField fieldPriceBookEntryId = (vlocity_cmt.JSONField)record.fields.get('PricebookEntryId');
                    mid.put('id',(String)fieldId.value);
                    mid.put('tipo',(String)fieldProduct2.vlocity_cmt__SubType__c);
                    mid.put('priceBookEntryId',(String)fieldId.value);
                    respuesta.add(mid);
                }
            }
            else {
                try {
                    vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult)outMap.get(vlocity_cmt.JSONResult.JSON_KEY_RESULT);    
                    List<vlocity_cmt.JSONRecord> pbeList  =  (List<vlocity_cmt.JSONRecord>)result.records;
                    for(vlocity_cmt.JSONRecord record: pbeList){
                        Map<String, Object> mid = new Map<String, Object>();
                        vlocity_cmt.JSONField fieldId = (vlocity_cmt.JSONField)record.fields.get('Id');
                        Product2 fieldProduct2 = (Product2)record.fields.get('Product2');
                        vlocity_cmt.JSONField fieldPriceBookEntryId = (vlocity_cmt.JSONField)record.fields.get('PricebookEntryId');
                        mid.put('id',(String)fieldId.value);
                        mid.put('tipo',(String)fieldProduct2.vlocity_cmt__SubType__c);
                        mid.put('priceBookEntryId',(String)fieldId.value);
                        respuesta.add(mid);
                    }
                }
                catch (Exception e) {
                    //-- Me falta alguna relacion que todavia no pude determinar.
                }
            }

            return respuesta;
        }
        catch (Exception e) {
            throw new FunctionalException('Error al agregar items a la orden. Error: ' + e.getMessage());
        }

    }
*/
    /**
     * @Objetivo: Realiza el checkout de la orden.
     */
/*     
    private ToJson submitOrder (FromJson pJsonBody) {
        printDebug('Entre a submitOrder() -- OrdenId --> ' + pJsonBody.orderId);
        ToJson toJson = new ToJson();
        try {
            printLimitAndUsedSize();
            String result = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(Id.valueOf(pJsonBody.orderId), false);
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result);
            if (resultMap != null) {
                Boolean stat = (Boolean) resultMap.get('isOk');
                if (!stat) {
                    printLimitAndUsedSize();
                    throw new FunctionalException((String)resultMap.get('errorMsg'));
                }
            }
            printLimitAndUsedSize();
            toJson.codResultado = '0';
            toJson.descResultado = 'OK';
            return toJson;
        }
        catch (Exception e) {
            throw new FunctionalException('Error al submitir la orden: ' + pJsonBody.orderId + ' - Error: ' + e.getMessage());
        }
    }
*/
    /**
     * @Objetivo: Arma la estructura de respuesta No Ok.
     */
    private List<Map<String, String>> getRespuestaNoOk(String pCodigo, String pDescripcion) {
        printDebug('Entre a getRespuestaNoOk()');
        Map<String, String> mapa = new Map<String, String>();
        List<Map<String, String>> lstErrors = new List<Map<String, String>>();
        mapa.put('errorCode', pcodigo);
        mapa.put('message', pDescripcion);
        lstErrors.add(mapa);
        return lstErrors;   
    }

    private void invokeIFS_S298 () {
        try {
            Product2 prod = [SELECT Id, Name, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE ProductCode = 'FAN_PSERV_00007'];
            PriceBookEntry priceBook = [SELECT UnitPrice, vlocity_cmt__RecurringPrice__c FROM PricebookEntry WHERE ProductCode = 'FAN_PSERV_00007'];
        }
        catch (Exception e) {

        }
    }

    private void printLimitAndUsedSize() {
        printDebug('Heap Size --> ' + Limits.getHeapSize());
        printDebug('Queries --> ' + Limits.getQueries() + ' - Limit -->  ' + Limits.getLimitQueries());
    }

    private void printDebug(String pMensaje) {
        if (K_DEBUG_ON) {
            System.debug(pMensaje);
        }
    }

    //-- Clases para soportar el request --//
    private class FromJson {
        public ChoiceClass choiceId;
        List<OfertaClass> lstOfertas;
    }

    private class ChoiceClass {
        public String subscriberId;
        public String nroLinea;
    }

    private class OfertaClass {
        public String codOperacion;
        public String ofertaId;
        List<LineaClass> lstLineas;
    }

    private class LineaClass {
        public String assetId;
        public String priceBookEntryId;
        public String nroLinea;
        public String tipo;
    }

    //-- Clase para soportar el response --//

    private class ToJson {
        public String orderNumber;
        public String codResultado;
        public String descResultado;
    }

    public class ResultObj {
		public Integer resultCode;
		public Blob resultMessage;

		public ResultObj(Integer code, Blob msg) {
			this.resultCode = code;
			this.resultMessage = msg;
		}
	}

    /**
     * @Objetivo: Para saber que codigo mandar debo poder
     *            diferenciar una excepcion funcional de
     *            otro tipo de excepciones.
     */
    private class FunctionalException extends Exception {
        public String codDP {set;get;} {codDP = '417';}
    }
}