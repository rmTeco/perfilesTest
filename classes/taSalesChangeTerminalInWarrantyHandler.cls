global with sharing class taSalesChangeTerminalInWarrantyHandler implements vlocity_cmt.VlocityOpenInterface
{
    public static final String CONST_CHANNEL_PRESENTIAL = 'Presencial';
    public static final String CONST_TANGIBLE_CONSIGNADO = 'MTPL';
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
    Boolean result = true;
    try
        {
        if (methodName.equals('ValidateCEGRazonSocial')){
             ValidateCEGRazonSocial(inputMap, outMap, options);
            }
        if (methodName.equals('ValidateTangibleConsignado')){
             ValidateTangibleConsignado(inputMap, outMap, options);
        }
        if (methodName.equals('validationTimeDefenseConsumer')){
             validationTimeDefenseConsumer(inputMap, outMap, options);
        }
        if (methodName.equals('ValidateClientMaterial')){
             ValidateClientMaterial(inputMap, outMap, options);
        }
        if (methodName.equals('ValidateSTEnElPais')){
             ValidateSTEnElPais(inputMap, outMap, options);
        }
         result = false;
        }
        catch(Exception e)
        {
            System.debug('ValidateCEGRazonSocial:invokeMethod -> exception: '+e);
            throw e;
        }
        return result;
    }

    public void ValidateCEGRazonSocial(Map<String,Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        try
        {        
            Id assetId = (Id) options.get('assetId');
            Boolean mismaRazonSocial = false;

            // En vlocity_cmt__OrderProductId__c se guarda la instancia de order item de la order creadora de asset.
        //    Id orderProduct = [SELECT vlocity_cmt__OrderProductId__c FROM Asset WHERE Id = :assetId].Id;

          //  Id origOrderId = [SELECT OrderId FROM OrderItem WHERE vlocity_cmt__AssetId__c = :orderProduct].Id;

            
            //Order order = [SELECT Id, OriginStoreLocation__c FROM Order WHERE Id = :origOrderId];
            
           list<Order> orders = AssetUtils.getOrderByAsset(assetId);
           System.debug('ELIANA');
            for(Order order : orders){
            vlocity_cmt__BusinessSite__c orderStore = [SELECT Id, Name, Channel__c, Channel_Type__c, Channel_Type_2__c, Channel_Type_3__c
                                                        FROM vlocity_cmt__BusinessSite__c
                                                        WHERE Id = :order.OriginStoreLocation__c];

  system.debug('Origin store location =====> '+ order.OriginStoreLocation__c);
            vlocity_cmt__BusinessSite__c userStore = [SELECT Id, Name, Channel__c, Channel_Type__c, Channel_Type_2__c, Channel_Type_3__c
                                                        FROM vlocity_cmt__BusinessSite__c
                                                    WHERE Id = :[SELECT Id, Work_Place__c
                                                                    FROM WorkTeam__c
                                                                    WHERE Id = :[SELECT Id, Work_Team__c
                                                                                    FROM Team_Member__c
                                                                                WHERE User_member__c = :UserInfo.getUserId()].Work_Team__c
                                                                    ].Work_Place__c];
            
            
            system.debug('userStore =====> '+userStore);
              // Misma razón social
                if(orderStore.Name == userStore.Name)
                {
                    mismaRazonSocial = true;
                }

                outMap.put('mismaRazonSocial', mismaRazonSocial);
            }
        }
        catch(Exception e)
        {
        System.debug('Exception Msg: ' + e.getMessage());
        System.debug('Exception Cause: ' + e.getCause());
        System.debug('Exception Stack Trace: ' + e.getStackTraceString());
        throw e;
        }
    }

    public void ValidateTangibleConsignado(Map<String,Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        try
        {
            //Id orderId = (Id) options.get('orderId');
            Id assetId = (Id) options.get('assetId');
            Boolean existTangibleConsignado = false;

            List<Order> orders = AssetUtils.getOrderByAsset(assetId);

            for(Order order: orders){
                //Se comprueban si existen TANGIBLES en orden
                List<OrderItem> orderItems = new List<OrderItem>();
                orderItems = [SELECT Id, Product2.ProductCode, Product2.Name, FromStock__c, Product2.Tangible__c
                            FROM OrderItem
                            WHERE OrderId = :order.Id];
                for(OrderItem item : orderItems)
                {
                    //Se comprueba si es tangible
                    if(item.Product2.Tangible__c)
                    {
                        //Se comprueba si es un tangible CONSIGNADO
                        if(item.FromStock__c.equals('CONST_TANGIBLE_CONSIGNADO'))
                        {
                            existTangibleConsignado = true;
                        }
                    }
                }

                outMap.put('existTangibleConsignado', existTangibleConsignado);
            }
        }
        catch(Exception e)
        {
        System.debug('Exception Msg: ' + e.getMessage());
        System.debug('Exception Cause: ' + e.getCause());
        System.debug('Exception Stack Trace: ' + e.getStackTraceString());
        throw e;
        }
    }
    
    public void validationTimeDefenseConsumer(Map<String,Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
        try{
            
            Id assetId = (Id) options.get('assetId');          
            Decimal timeLimit = 0;
            Date created;      
            
            List<Order> orders = AssetUtils.getOrderByAsset(assetId);

            for(Order order: orders){
                    vlocity_cmt__BusinessSite__c storeLocation = [SELECT Id, Channel__c, vlocity_cmt__State__c
                                                                FROM vlocity_cmt__BusinessSite__c
                                                                WHERE Id = :order.OriginStoreLocation__c];
                    if([SELECT count() FROM WarrantyTimeLimit__c WHERE Channel__c = :storeLocation.Channel__c AND LocationCode__c = :storeLocation.vlocity_cmt__State__c] > 0)
                        timeLimit = [SELECT TimeLimit__c
                                    FROM WarrantyTimeLimit__c
                                    WHERE LocationCode__c = :storeLocation.vlocity_cmt__State__c
                                        AND Channel__c = :storeLocation.Channel__c].TimeLimit__c;
                    else if([SELECT count() FROM WarrantyTimeLimit__c WHERE LocationCode__c = :storeLocation.vlocity_cmt__State__c AND Channel__c = null] > 0)
                        timeLimit = [SELECT TimeLimit__c
                                    FROM WarrantyTimeLimit__c
                                    WHERE LocationCode__c = :storeLocation.vlocity_cmt__State__c
                                        AND Channel__c = null].TimeLimit__c;
                    else
                        timeLimit = [SELECT TimeLimit__c
                                        FROM WarrantyTimeLimit__c
                                        WHERE Channel__c = null
                                        AND LocationCode__c = null].TimeLimit__c;
                    if(order.Delivery_Method__c.equals('CONST_CHANNEL_PRESENTIAL')){
                        created = date.newinstance(order.CreatedDate.year(), order.CreatedDate.month(), order.CreatedDate.day());
                    }else{
                        created = date.newinstance(order.DeliveryDate__c.year(), order.DeliveryDate__c.month(), order.DeliveryDate__c.day());
                    }

                    Boolean validTime = created.daysBetween(system.today()) <= timeLimit;

                outMap.put('validTime', validTime);
            }  
        }catch(Exception e){
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    }

public void ValidateClientMaterial(Map<String,Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
   {
   try
    {
        boolean isValid = false;
        Id assetId = (Id) options.get('assetId');
        String inputSerial = [SELECT SerialNumber FROM Asset WHERE Id = : assetId].SerialNumber;
        Map<String, Object> serialsMap = new Map<String, Object>();
        serialsMap.put(inputSerial, null);
        //accedo a los valores del nuevo custom setting StockMovementConfiguration__c
        StockMovementConfiguration__c stockConf = StockMovementConfiguration__c.getInstance(UserInfo.getProfileId());
        
        String codDeposito = stockConf.Codigo_Deposito__c;
        String matClient = stockConf.Material_del_Cliente__c;
        List<String> stocks =  new  List<String> { matClient };
        
        IccidManager manager = new IccidManager();
        manager.ValidateSerialNumbers(serialsMap, codDeposito, stocks);
        Object serialValidado = serialsMap.get(inputSerial);
        
        if(serialValidado != null){
            isValid = true;
        }
        
        outMap.put('ValidateClientMaterial', isValid);
    }
    catch(Exception e){
           System.debug('Exception Msg: ' + e.getMessage());
           System.debug('Exception Cause: ' + e.getCause());
           System.debug('Exception Stack Trace: ' + e.getStackTraceString());
           throw e;
       }
   }
   
   public void ValidateSTEnElPais(Map<String,Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
   {
   try
    {
        Id assetId = (Id) options.get('assetId');
        
        List<String> atributoABuscar = new List<String>();
        atributoABuscar.add('Susceptible de Servicio Tecnico');

        Map<String,Object> valorAtributo = AssetAttributesUtils.getAssetAttribute(assetId, atributoABuscar);

        Boolean stValidation = Boolean.valueOf((String)valorAtributo.get('Susceptible de Servicio Tecnico'));
        
        outMap.put('ValidateST', stValidation);
    }
    catch(Exception e){
           System.debug('Exception Msg: ' + e.getMessage());
           System.debug('Exception Cause: ' + e.getCause());
           System.debug('Exception Stack Trace: ' + e.getStackTraceString());
           throw e;
       }
   }
}