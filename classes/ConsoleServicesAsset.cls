global with sharing class ConsoleServicesAsset implements vlocity_cmt.VlocityOpenInterface {
    global ConsoleServicesAsset() {
    }

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;

        try 
        {
            if (methodName.Equals('GetPlanAssetsByAccountId')) {
                GetPlanAssetsByAccountId(inputMap, outMap, options);
            }
  

        }
        catch(Exception ex) {
            outMap.put('error', ex.getStackTraceString());
            result = false;
        }
        return result;
    }

    public static void GetPlanAssetsByAccountId(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try 
        {

            //String idAccount = '0016C000009IOSI';
            String idAccount = (String) inputMap.get('Id');
            Map<String,Object> planAsset = GetAssetsToShow(idAccount);
            outMap.put('Result', planAsset);
            //System.debug('Result:'+ JSON.serialize(outMap));
        }
        catch(Exception ex) 
        {
            outMap.put('error', ex.getMessage());
        }
    }


       public static Map<String,Object> GetAssetsToShow (String idAccount) {
        try 
        {   

            Integer i = 0;
            String cuenta = 'SELECT Name FROM Account WHERE id=:idAccount';
            sObject restultAccount = Database.query(cuenta);
            String servicios = 'SELECT Id, CreatedDate, Linked_Product_Family__c, Name, Status, vlocity_cmt__ActivationDate__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__JSONAttribute__c, MSISDN__c, Product2Id FROM Asset WHERE AccountId=:idAccount AND Linked_Product_Family__c =\'Movil\' AND Status IN (\'Active\', \'Inactive\', \'Suspended\')';
            List<Asset> restultAssets = (List<Asset>)Database.query(servicios);
            /*
            Id, CreatedDate, Linked_Product_Family__c, Name, Status, 
            vlocity_cmt__ActivationDate__c, vlocity_cmt__BillingAccountId__c,
            vlocity_cmt__JSONAttribute__c, vlocity_cmt__LineNumber__c 
            */
            JSONGenerator response = JSON.createGenerator(true);

            response.writeStartObject();
            response.writeFieldName('PlanAssets');
            response.writeStartArray();
            
            for (Asset asset : restultAssets) 
            {
                
                if(String.isNotBlank(String.valueOfGmt(asset.vlocity_cmt__ActivationDate__c)))//String.isNotBlank((String)asset.get('vlocity_cmt__BillingAccountId__c')))
                {
                    response.writeStartObject();

                    String productId = asset.Product2Id;
                    String assetId = asset.Id;
                    String product = 'SELECT Name, vlocity_cmt__Type__c FROM Product2 WHERE id=:productId AND vlocity_cmt__Type__c IN (\'Plan Pospago\', \'Plan Prepago\', \'Plan Hibrido\')';
                    List<Product2> resultProducts = (List<Product2>)Database.query(product);
                    Integer totalTransaction = Database.countQuery('SELECT COUNT() FROM Transaction_History__c WHERE Asset__c=:assetId');
                    System.debug('Total Transaction: ' + totalTransaction);

                    for (Product2 product2 : resultProducts){

                        //Ver si combiene usar un mapa o no
                        System.debug('Account Name:' + (String)restultAccount.get('Name'));
                        System.debug('Product Name:' + (String)product2.get('Name'));
                        System.debug('ProductType: '+ (String)product2.get('vlocity_cmt__Type__c'));
                        System.debug('LineNumber: ' + (String)asset.get('MSISDN__c'));
                       
                        //System.debug('ActivationDate: ' + activationDate);
                        System.debug('Status: ' + (String)asset.get('Status'));
                        System.debug('Name: ' + (String)asset.get('Name'));
                        System.debug('Family: ' + (String)asset.get('Linked_Product_Family__c'));
                        System.debug('AssetId: ' + (String)asset.get('Id'));
                        
                        //System.debug('CreatedDate: ' + createdDate);
                        System.debug('NumeroCuenta: ' + (String)asset.get('vlocity_cmt__BillingAccountId__c'));
                        //Datetime activationDate = (Datetime) asset.vlocity_cmt__ActivationDate__c;
                        //Datetime createdDate = (Datetime) asset.CreatedDate;
                        
                        Datetime activationDate, createdDate;
                        activationDate = (Datetime)asset.vlocity_cmt__ActivationDate__c;
                        createdDate = (Datetime)asset.CreatedDate;                    

                        /*if(ISNULL(asset.vlocity_cmt__ActivationDate__c))
                            activationDate = date.today();
                        else 
                            createdDate = (Datetime) asset.vlocity_cmt__ActivationDate__c;       
                        
                        if(ISNULL(asset.CreatedDate))
                            createdDate = date.today();
                        else 
                            createdDate = (Datetime) createdDate;
                        */

                        response.writeFieldName('Account');
                        response.writeStartObject();
                        if(String.isNotBlank((String)asset.get('Name')))
                            response.writeObjectField('Name', (String)restultAccount.get('Name'));
                        else
                            response.writeObjectField('Name', '');
                        response.writeEndObject();
                        
                        response.writeFieldName('Product');
                        response.writeStartObject();
                        if(String.isNotBlank((String)product2.get('Name')))
                            response.writeObjectField('Name', (String)product2.get('Name'));
                        else
                            response.writeObjectField('Name', '');    
                        response.writeEndObject();


                        if(String.isNotBlank((String)product2.get('vlocity_cmt__Type__c')))
                            response.writeObjectField('ProductType', (String)product2.get('vlocity_cmt__Type__c'));
                        else
                            response.writeObjectField('ProductType', '');   
                        

                        //Map<String, Object> mapJsonAttributes = (Map<String, Object>) JSON.deserializeUntyped(asset.vlocity_cmt__JSONAttribute__c);
                        //List<Object> attributes = (List<Object>)mapJsonAttributes.get('MobileHandset');
                        //response.writeObjectField('JSONCatalogo', (String)product2.get('mapJsonAttributes'));
                        //response.writeObjectField('JSONCatalogo', (String)asset.get('vlocity_cmt__JSONAttribute__c'));
                        if(String.isNotBlank((String)asset.get('MSISDN__c')))
                            response.writeObjectField('LineNumber', (String)asset.get('MSISDN__c'));
                        else 
                            response.writeObjectField('LineNumber', '');

                        response.writeObjectField('ActivationDate', activationDate);

                        if(String.isNotBlank((String)asset.get('Status')))
                            response.writeObjectField('Status', (String)asset.get('Status'));
                        else 
                            response.writeObjectField('Status', '');

                        if(String.isNotBlank((String)asset.get('Name')))
                            response.writeObjectField('Name', (String)asset.get('Name'));
                        else 
                            response.writeObjectField('Name', '');
 
                         if(String.isNotBlank((String)asset.get('Linked_Product_Family__c')))
                            response.writeObjectField('Family', (String)asset.get('Linked_Product_Family__c'));
                        else 
                            response.writeObjectField('Family', '');

                        if(String.isNotBlank((String)asset.get('Id')))
                            response.writeObjectField('AssetId', (String)asset.get('Id'));
                        else 
                            response.writeObjectField('AssetId', '');                       
                        
                        response.writeObjectField('CreatedDate', createdDate);  
                        

                        if(String.isNotBlank((String)asset.get('vlocity_cmt__BillingAccountId__c')))
                            response.writeObjectField('NumeroCuenta', (String)asset.get('vlocity_cmt__BillingAccountId__c'));
                        else 
                            response.writeObjectField('NumeroCuenta', '');

                        //If the definition of integration change to array we need change this.
                        if(String.isNotBlank((String)asset.get('MSISDN__c')))
                        {   
                            Map<String, Object> output = CompletePlanAssetInfo((String)asset.get('MSISDN__c'));
                            response.writeObjectField('Balance', output);
                        }
                        else 
                        {
                            response.writeObjectField('Balance', '');
                        }
                    }   
                    response.writeEndObject();
                }
            }
            response.writeEndArray();
            response.writeEndObject();

            /*System.debug('Response:'+ response.getAsString());
            System.debug('Response:'+JSON.deserializeUntyped(response.getAsString()));
            System.debug('JSON: '+ response);*/
            //return response.getAsString();
            return (Map<String, Object>)JSON.deserializeUntyped(response.getAsString());

        }
        catch(Exception ex) {
            System.debug('Error: '+ex.getMessage());
            throw ex;
        }
    }


    public static Map<String,Object> GetAssetsToShow2 (String idAccount) {
        try 
        {   

            Integer i = 0;
            String cuenta = 'SELECT Name FROM Account WHERE id=:idAccount';
            sObject restultAccount = Database.query(cuenta);
            String servicios = 'SELECT Id, CreatedDate, Linked_Product_Family__c, Name, Status, vlocity_cmt__ActivationDate__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__JSONAttribute__c, MSISDN__c, Product2Id FROM Asset WHERE AccountId=:idAccount AND Linked_Product_Family__c =\'Movil\' AND Status IN (\'Active\', \'Inactive\', \'Suspended\')';
            List<Asset> restultAssets = (List<Asset>)Database.query(servicios);
            /*
            Id, CreatedDate, Linked_Product_Family__c, Name, Status, 
            vlocity_cmt__ActivationDate__c, vlocity_cmt__BillingAccountId__c,
            vlocity_cmt__JSONAttribute__c, vlocity_cmt__LineNumber__c 
            */
            JSONGenerator response = JSON.createGenerator(true);

            response.writeStartObject();
            response.writeFieldName('PlanAssets');
            response.writeStartArray();
            
            for (Asset asset : restultAssets) 
            {
                response.writeStartObject();
                if(true)//String.isNotBlank((String)asset.get('vlocity_cmt__BillingAccountId__c')))
                {

                    String productId = asset.Product2Id;
                    String assetId = asset.Id;
                    String product = 'SELECT Name, vlocity_cmt__Type__c FROM Product2 WHERE id=:productId AND vlocity_cmt__Type__c IN (\'Plan Pospago\', \'Plan Prepago\', \'Plan Hibrido\')';
                    List<Product2> resultProducts = (List<Product2>)Database.query(product);
                    Integer totalTransaction = Database.countQuery('SELECT COUNT() FROM Transaction_History__c WHERE Asset__c=:assetId');
                    System.debug('Total Transaction: ' + totalTransaction);

                    for (Product2 product2 : resultProducts){

                        //Ver si combiene usar un mapa o no
                        /*System.debug('Account Name:' + (String)restultAccount.get('Name'));
                        System.debug('Product Name:' + (String)product2.get('Name'));
                        System.debug('ProductType: '+ (String)product2.get('vlocity_cmt__Type__c'));
                        System.debug('LineNumber: ' + (String)asset.get('MSISDN__c'));
                       
                        System.debug('ActivationDate: ' + activationDate);
                        System.debug('Status: ' + (String)asset.get('Status'));
                        System.debug('Name: ' + (String)asset.get('Name'));
                        System.debug('Family: ' + (String)asset.get('Linked_Product_Family__c'));
                        System.debug('AssetId: ' + (String)asset.get('Id'));
                        
                        System.debug('CreatedDate: ' + createdDate);
                        System.debug('NumeroCuenta: ' + (String)asset.get('vlocity_cmt__BillingAccountId__c'));*/
                        //Datetime activationDate = (Datetime) asset.vlocity_cmt__ActivationDate__c;
                        //Datetime createdDate = (Datetime) asset.CreatedDate;
                        
                        Datetime activationDate, createdDate;
                        try{activationDate= (Datetime) asset.vlocity_cmt__ActivationDate__c;}catch(Exception e){activationDate=null;}
                        try{createdDate= (Datetime) asset.vlocity_cmt__ActivationDate__c;}catch(Exception e){activationDate=null;}


                        /*if(ISNULL(asset.vlocity_cmt__ActivationDate__c))
                            activationDate = date.today();
                        else 
                            createdDate = (Datetime) asset.vlocity_cmt__ActivationDate__c;       
                        
                        if(ISNULL(asset.CreatedDate))
                            createdDate = date.today();
                        else 
                            createdDate = (Datetime) createdDate;
                        */

                        response.writeFieldName('Account');
                        response.writeStartObject();
                        if(String.isNotBlank((String)asset.get('Name')))
                            response.writeObjectField('Name', (String)restultAccount.get('Name'));
                        else
                            response.writeObjectField('Name', '');
                        response.writeEndObject();
                        
                        response.writeFieldName('Product');
                        response.writeStartObject();
                        if(String.isNotBlank((String)product2.get('Name')))
                            response.writeObjectField('Name', (String)product2.get('Name'));
                        else
                            response.writeObjectField('Name', '');    
                        response.writeEndObject();


                        if(String.isNotBlank((String)product2.get('vlocity_cmt__Type__c')))
                            response.writeObjectField('ProductType', (String)product2.get('vlocity_cmt__Type__c'));
                        else
                            response.writeObjectField('ProductType', '');   
                        

                        //Map<String, Object> mapJsonAttributes = (Map<String, Object>) JSON.deserializeUntyped(asset.vlocity_cmt__JSONAttribute__c);
                        //List<Object> attributes = (List<Object>)mapJsonAttributes.get('MobileHandset');
                        //response.writeObjectField('JSONCatalogo', (String)product2.get('mapJsonAttributes'));
                        //response.writeObjectField('JSONCatalogo', (String)asset.get('vlocity_cmt__JSONAttribute__c'));
                        if(String.isNotBlank((String)asset.get('MSISDN__c')))
                            response.writeObjectField('LineNumber', (String)asset.get('MSISDN__c'));
                        else 
                            response.writeObjectField('LineNumber', '');

                        response.writeObjectField('ActivationDate', activationDate);

                        if(String.isNotBlank((String)asset.get('Status')))
                            response.writeObjectField('Status', (String)asset.get('Status'));
                        else 
                            response.writeObjectField('Status', '');

                        if(String.isNotBlank((String)asset.get('Name')))
                            response.writeObjectField('Name', (String)asset.get('Name'));
                        else 
                            response.writeObjectField('Name', '');
 
                         if(String.isNotBlank((String)asset.get('Linked_Product_Family__c')))
                            response.writeObjectField('Family', (String)asset.get('Linked_Product_Family__c'));
                        else 
                            response.writeObjectField('Family', '');

                        if(String.isNotBlank((String)asset.get('Id')))
                            response.writeObjectField('AssetId', (String)asset.get('Id'));
                        else 
                            response.writeObjectField('AssetId', '');                       
                        
                        response.writeObjectField('CreatedDate', createdDate);  
                        

                        if(String.isNotBlank((String)asset.get('vlocity_cmt__BillingAccountId__c')))
                            response.writeObjectField('NumeroCuenta', (String)asset.get('vlocity_cmt__BillingAccountId__c'));
                        else 
                            response.writeObjectField('NumeroCuenta', '');

                        //If the definition of integration change to array we need change this.
                        if(String.isNotBlank((String)asset.get('MSISDN__c')))
                        {   
                            Map<String, Object> output = CompletePlanAssetInfo((String)asset.get('MSISDN__c'));
                            response.writeObjectField('Balance', output);
                        }
                        else 
                        {
                            response.writeObjectField('Balance', '');
                        }
                    }   
                }
                response.writeEndObject();
            }
            response.writeEndArray();
            response.writeEndObject();

            /*System.debug('Response:'+ response.getAsString());
            System.debug('Response:'+JSON.deserializeUntyped(response.getAsString()));
            System.debug('JSON: '+ response);*/
            //return response.getAsString();
            return (Map<String, Object>)JSON.deserializeUntyped(response.getAsString());

        }
        catch(Exception ex) {
            System.debug('Error: '+ex.getMessage());
            throw ex;
        }
    }


    public static Map<String, Object> CompletePlanAssetInfo(String lineNumber) {
        try 
        {
            Map<String, Object> assetBalance = GetAssetBalance(lineNumber);
            //System.debug('assetBalance: ' + assetBalance);
            List<Map<String, Object>> freeUnits = GetFreeUnits(assetBalance);
            //System.debug('freeUnits: ' + freeUnits);

            //assetBalance.put('FreeUnits', freeUnits);
            return assetBalance;
            
        }
        catch(Exception ex) {
            throw ex;
        }
    }

    //This method execute IFS439 to get the balance and free units. 
    public static Map<String, Object> GetAssetBalance(String lineNumber) {
        try 
        {
            String integProcName = 'IFS_S439';

            Map<String, Object> input = GetJSONRequest(lineNumber);
            //System.debug('input: ' + input);
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();

            vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
            if (!Test.isRunningTest()) {
            	integProcServ.invokeMethod(integProcName, input, output, options);
            } else {
            	Map<String,Object> IPResult = new Map<String,Object>();
            	Map<String,Object> totalUnidadesLibres = new Map<String,Object>();
            	List<Object> unidadLibre = new List<Object>();
            	
            	Map<String,Object> item1 = new Map<String,Object>();
            	item1.put('codUsoUnidadesLibres','Voice');
            	item1.put('codUnidadDeMedida','SEGUNDOS');
            	item1.put('cantUnidadesRemanentes','10');
            	Map<String,Object> item2 = new Map<String,Object>();
            	item2.put('codUsoUnidadesLibres','Data');
            	item2.put('codUnidadDeMedida','KB');
            	item2.put('cantUnidadesRemanentes','10');
            	
            	unidadLibre.add(item1);
            	unidadLibre.add(item2);
            	
            	totalUnidadesLibres.put('unidadLibre',unidadLibre);
            	IPResult.put('totalUnidadesLibres',totalUnidadesLibres);
            	output.put('IPResult',IPResult);
            }

            return (Map<String, Object>)output.get('IPResult');
            //return (Map<String, Object>)JSON.deserializeUntyped('{"identificadorRecurso":"string","estadoDeLinea":{"estadoSuscripcion":"string"},"estadoSuscripcion":"string","marcaSuspensionActiva":"string","listaDeSuspensiones":{"suspension":[{"codSuspension":"string","tipoSuspension":"string","marcaSuspensionActiva":"string"}]},"ofertaPrincipal":{"codProducto":0,"nombreProducto":"string","descripcionProducto":"string"},"totalesBalance":{"saldoBalance":"Unknown Type: long","saldoSuscripcionComprado":"Unknown Type: long","saldoSuscripcionRegalado":"Unknown Type: long","proximaFechaExpiracionBalance":"string","fechaExpiracionBalance":"string"},"totalUnidadesLibres":{"unidadLibre":[{"codUsoUnidadesLibres":"string","codUnidadDeMedida":0,"cantUnidadesRemanentes":"Unknown Type: long","fechaVigenciaHastaProdAdq":"string"}]},"fechaEstadoSuscripcion":"string","fechaActivacionSuscripcion":"string"}');
        }
        catch(Exception ex) {
            throw ex;
        }
    }

    //Get request from JSON PlanAsset, this method get the lineNUmber.
    public static Map<String, Object> GetJSONRequest(String lineNumber) {
        try 
        {
            lineNumber = '1138305304'; // Hardcode
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> params = new Map<String, Object>();
            params.put('identificadorRecurso', lineNumber); //for test lineNumber = 1138305304
            input.put('params', params);

            return input;
        }
        catch(Exception ex) {
            throw ex;
        }
    }
    
    public static List<Map<String, Object>> GetFreeUnits(Map<String, Object> assetBalance) {
        try 
        {
            List<Map<String, Object>> newFreeUnitsList = new List<Map<String, Object>>();
            Map<String, Object> totalFreeUnits = (Map<String, Object>)assetBalance.get('totalUnidadesLibres');
            //System.debug('totalFreeUnits: ' + totalFreeUnits);
            List<Object> freeUnits = (List<Object>)totalFreeUnits.get('unidadLibre');

            
            //System.debug('freeUnits2: ' + freeUnits);

            for (Object freeUnitObj : freeUnits) {
                Double remainingPrimaryUnits;
                Double remainingSecondaryUnits;
                String newFreeUnitCode;
                Map<String, Object> newFreeUnit = new Map<String, Object>();
                Map<String, Object> freeUnit = (Map<String, Object>)freeUnitObj;

                String freeUnitCode = (String)freeUnit.get('codUsoUnidadesLibres');
                String measureUnitCode = (String)freeUnit.get('codUnidadDeMedida');
                String remainingUnits = String.ValueOf(freeUnit.get('cantUnidadesRemanentes'));

                //System.debug('measureUnitCode: ' + measureUnitCode);
                //System.debug('remainingUnits: ' + remainingUnits);

                if (freeUnitCode.equals('Voice')) {
                    newFreeUnitCode = 'Voz';
                } else if (freeUnitCode.equals('Data')) {
                    newFreeUnitCode = 'Internet';
                }

                if (measureUnitCode.equals('SEGUNDOS')) {
                    Double remainingMinutes = Math.floor(Double.ValueOf(remainingUnits) / 60);
                    Long remainingSeconds = Math.mod(Long.ValueOf(remainingUnits), 60);

                    remainingPrimaryUnits = remainingMinutes;
                    remainingSecondaryUnits = remainingSeconds;
                } else if (measureUnitCode.equals('KB')) {
                    Double remainingMB = Math.floor(Double.ValueOf(remainingUnits) / 1024);
                    Long remainingKB = Math.mod(Long.ValueOf(remainingUnits), 1024);

                    remainingPrimaryUnits = remainingMB;
                    remainingSecondaryUnits = remainingKB;
                }

                //System.debug('remainingPrimaryUnits: ' + remainingPrimaryUnits);
                //System.debug('remainingSecondaryUnits: ' + remainingSecondaryUnits);
                freeUnit.put('remainingPrimaryUnits', remainingPrimaryUnits);
                freeUnit.put('remainingSecondaryUnits', remainingSecondaryUnits);
                freeUnit.put('freeUnitCode', newFreeUnitCode);

                newFreeUnitsList.add(newFreeUnit);
            }

            return newFreeUnitsList;
        }
        catch(Exception ex) {
            System.debug('ex: ' + ex);
            throw ex;
        }
    }

}