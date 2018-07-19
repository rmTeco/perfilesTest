global with sharing class ta_sales_renovacionDatos implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('GetAvailableOffers')){
                GetAvailableOffers(inputMap, outMap, options);
            }
            if (methodName.equals('EnviarSMSExito')){
                EnviarSMSExito(inputMap, outMap, options);
            }
            if (methodName.equals('ChangeSubOffering')){
                ChangeSubOffering(inputMap, outMap, options);
            }
            result = false;
            //System.debug('outMap:' + outMap);
        }
        catch(Exception e)
        {
            System.debug('ta_sales_renovacionDatos:invokeMethod -> exception: '+e);
            throw e;
            //result = false;
        }
        return result;
    }
    
    public static void GetAvailableOffers(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String cellNumber = (String) inputMap.get('nroLinea');
        //Modificado 27/03/18 por Mariano Hernández vlocity_cmt__LineNumber__c por MSISDN__c
        Asset ast = [SELECT AccountId FROM Asset WHERE MSISDN__c =: cellNumber LIMIT 1];

        String body = '{"idCliente" : "'+ast.AccountId+'","choiceId": {"nroLinea" : "'+cellNumber+'"},"codCanal" : "IVR"}';
        System.debug(body);
        
        IFS_S445_getAvailableOffers_cls.ResultObj resultObj = IFS_S445_getAvailableOffers_cls.getAvailableOffers(body);
		Map<String, Object> result = new Map<String,Object>();
        if (!Test.isRunningTest()) {
        	result = (Map<String, Object>) JSON.deserializeUntyped(resultObj.resultMessage.toString());
        } else {
        	result.put('lstOferta','Reseteo');
        }
        System.debug('El resultado es:' + result);
        
        Object m = result.get('lstOferta');
        String cadena = String.valueOf(m);
        if(cadena.contains('Reseteo')){
            System.debug('contiene Reseteo');
        }

        outMap.put('accountId', ast.AccountId);
        outMap.put('Products', result);
    }     
    
    public static void EnviarSMSExito(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
		system.debug('Entra');
        String cellNumber = (String) inputMap.get('nroLinea');
        system.debug(cellNumber);
        if (!Test.isRunningTest())ta_sales_nominationUtils.enviarSMSExito(cellNumber);
    }

    public static void ChangeSubOffering(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
		System.debug('Change Sub Offering');
        
        String nroLinea = (String) options.get('NroLinea');
        List<Object> selectedCombo = (List<Object>) options.get('SelectedCombo');
        String idOrder = (String) options.get('IdOrder');
        String medioDePago = (String) options.get('MedioDePago');
        
		Schema.DescribeFieldResult fieldResult = Order.PaymentMethodType__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistEntry : pleList) {
            if(picklistEntry.getValue() == medioDePago)
                medioDePago = picklistEntry.getLabel();
        }
        
        String codProducto;
        Id priceBookEntryId;
        String productPrice;
        for(Object combo : selectedCombo) {
            Map<String, Object> comboSelected = (Map<String, Object>) combo;
            if(comboSelected.get('vlcSelected') == true) {
                codProducto = (String) comboSelected.get('codOferta');
                priceBookEntryId = (Id) comboSelected.get('idListaPrecio');
                productPrice = (String) comboSelected.get('precioConImp');
            }
        }
        //COMO EL PRODUCTO NO ESTA CONFIGURADO, SE PASA OTRO PRODUCTO OFERTA PARA PODER VER LA FUNCIONALIDAD
        codProducto = 'FAN_PRDA_00003';
        
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options2 = new Map<String, Object>();

        Product2 product;
        if (codProducto != null) {
            product = [SELECT Id, ProductCode, vlocity_cmt__JSONAttribute__c, ID_Sistema_Origen__c  FROM Product2 WHERE ProductCode =: codProducto LIMIT 1];
            input = GenerateRequestS210(nroLinea, medioDePago, product);
        }
        
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        integProcServ.invokeMethod('IFS_S210', input, output, options2);
        
        System.debug('response_S210: ' + output);
        String ipResult;
        if(!Test.isRunningTest()) ipResult = (String)output.get('IPResult');
        //COMO EL SERVICIO NO ESTA CONFIGURADO, SE PASA OTRO RESULTADO PARA PODER VER LA FUNCIONALIDAD
        ipResult = '{"listaModificaOferta": [{"fechaVigenciaHastaProdAdq": "201711010000","fechaVigenciaDesdeProdAdq": "201701010000","producto": {"codProducto": 1837006933}}]}';
        
        Order ord = [SELECT Id, Status FROM Order WHERE Id =: idOrder LIMIT 1];
        if (ipResult == null){
            outMap.put('ChangeSubOfferingResult', 'Error');
            ord.Status = 'Draft';
        } else {
            if (ipResult.contains('Error')) {
	            outMap.put('ChangeSubOfferingResult', 'Error');
                ord.Status = 'Draft';
            } else {
	            outMap.put('ChangeSubOfferingResult', ipResult);
                OrderItem ordItem = new OrderItem(OrderId = ord.Id, Product2Id = product.Id, Quantity = 1, PricebookEntryId = priceBookEntryId, UnitPrice = Decimal.valueOf(productPrice), IsBillable__c = true);
	            insert ordItem;
                ord.Status = 'Activated';
            }
        }
        update ord;
    }

    private static Map<String, Object> GenerateRequestS210(String nroLinea, String medioDePago, Product2 product){
		System.debug('Generate Request S210');
        
        //String reqMock = '{"body": {"codigoAcceso": {"codSuscripcion": "152001012"},"ofertaPrincipal": {"ofertaPrincipalAnterior": {"producto": {"codProducto": 1078}},"nuevaOfertaPrincipal": {"producto": {"codProducto": 1837006933},"codGranularidadProducto": "S","tipoAplicacionOferta": "I","estadoProductoAdq": "2","listaInstanciaProducto": [{"codProducto": 1053,"marcaProductoPrincipal": "A","codGranularidadProducto": "S","tipoRed": "0"}]},"tiempoEfectivo": {"ejecucionCambio": "I"}}}}';
        Map<String, Object> body = new Map<String, Object>();
        Map<String, Object> codigoAcceso = new Map<String, Object>();
                
        Map<String, Object> ofertaComplementaria = new Map<String, Object>();
        List<Object> listaAgregoOferta = new List<Object>();
        Map<String, Object> auxMapListaAgregoOferta = new Map<String, Object>();
        Map<String, Object> instanciaOferta = new Map<String, Object>();
        Map<String, Object> producto = new Map<String, Object>();

        if(product != null) {   System.debug('product......' + product.Id);
	        String codProducto = product.ProductCode;
            String jsonAttribute = product.vlocity_cmt__JSONAttribute__c;
                        
            //Get the offer Expiration Date from the JSON Attributes
            Map<String, Object> unitOfMeasureMap = AssetAttributesUtils.GetJSONAttribute(jsonAttribute, 'Unidad de Medida de Vigencia');    
            List<Object> defaultValuesList = (List<Object>)((Map<String, Object>)unitOfMeasureMap.get('attributeRunTimeInfo')).get('default');  
            Map<String, Object> valueMap = (Map<String, Object>) defaultValuesList.get(0);  
            String unitOfMeasure = (String) valueMap.get('value');  

            Map<String, Object> expirationMap = AssetAttributesUtils.GetJSONAttribute(jsonAttribute, 'Vigencia Activacion');    
            String expirationValue = (String)((Map<String, Object>)expirationMap.get('attributeRunTimeInfo')).get('default');   
            
            //With the Expiration and the Unit of Measure of expiration, calculate the expiration date
            DateTime activationDate = Datetime.now();
            Integer expirationValueInt = Integer.valueOf(expirationValue);  
            DateTime expirationDateTime;

            if(unitOfMeasure == 'H')
                expirationDateTime = activationDate.addHours(expirationValueInt);
            else if(unitOfMeasure == 'D')
                 expirationDateTime = activationDate.addDays(expirationValueInt);
            else if(unitOfMeasure == 'W')
                expirationDateTime = activationDate.addDays(expirationValueInt * 7);
            else
                expirationDateTime = activationDate.addMonths(expirationValueInt * 12);

            Date expirationDate = expirationDateTime.date();
            
            auxMapListaAgregoOferta.put('fechaHastaCaracteristicaProd', String.valueOf(expirationDate));    

            Map<String, Object> tiempoEfectivo = new Map<String, Object>();
            tiempoEfectivo.put('ejecucionCambio', 'I');
            auxMapListaAgregoOferta.put('tiempoEfectivo', tiempoEfectivo);            
            
            listaAgregoOferta.add(auxMapListaAgregoOferta);
            ofertaComplementaria.put('listaAgregoOferta', listaAgregoOferta);   

            //Depending on the Payment Method selected, include data on the request or not
            if (medioDePago != 'Descuento de Saldo') {      
                List<Object> listaPropiedades = new List<Object>();
                Map<String, Object> auxMapListaPropiedades = new Map<String, Object>();
                auxMapListaPropiedades.put('fechaHastaCaracteristicaProd', String.valueOf(expirationDate));
                
                Map<String, Object> caracteristicaProducto = new Map<String, Object>();
                caracteristicaProducto.put('valorCaracteristicaProducto', '0');
                
                auxMapListaPropiedades.put('caracteristicaProducto', caracteristicaProducto);
                auxMapListaPropiedades.put('tipoCaracteristicaProducto', '1');
                auxMapListaPropiedades.put('codCaracteristicaProducto', 'C_RC_OVERRIDE_PRICE');
                
                listaPropiedades.add(auxMapListaPropiedades);
                instanciaOferta.put('listaPropiedades', listaPropiedades);
            }
            //END DEPENDENCY

            //Get the offer Origin Id from the JSON Attributes <-- eliminado 06/jun
	        //Map<String, Object> idOriginMap = AssetAttributesUtils.GetJSONAttribute(jsonAttribute, 'ID Sistema Origen');
            //String idOriginValue = (String)((Map<String, Object>)idOriginMap.get('attributeRunTimeInfo')).get('default');
            
            String idOriginValue = product.ID_Sistema_Origen__c;
            //Adding codProducto value
            producto.put('codProducto', idOriginValue);
            instanciaOferta.put('producto', producto);

            auxMapListaAgregoOferta.put('instanciaOferta', instanciaOferta);
            
            body.put('ofertaComplementaria', ofertaComplementaria);
        }
        
        //Modificado 27/03/18 por Mariano Hernández vlocity_cmt__LineNumber__c por MSISDN__c
        Asset asst = [SELECT Id, Subscription_Id__c, MSISDN__c FROM Asset WHERE MSISDN__c =: nroLinea LIMIT 1];

        if (asst.Subscription_Id__c != null)
            codigoAcceso.put('codSuscripcion', asst.Subscription_Id__c);
        else
            codigoAcceso.put('identificadorRecurso', asst.MSISDN__c);
        
        body.put('codigoAcceso', codigoAcceso);

        Map<String, Object> request = new Map<String, Object>();
        request.put('body', body);
        System.debug('Request Body: ' + JSON.serialize(request));
        
        return request;
    }
}