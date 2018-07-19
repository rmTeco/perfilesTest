global class taCareSuspensionsAndReconnections2 implements vlocity_cmt.VlocityOpenInterface
{

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {

        try
        {
            if (methodName.equals('createOrder')) {
                createOrder(input, outMap, options);
            }
            if (methodName.equals('createOrderBackoffice')) {
                createOrderBackoffice(input, outMap, options);
            }
            if (methodName.equals('getActiveOrSuspendedAssets')) {
                getActiveOrSuspendedAssets(input, outMap, options);
            }
            if (methodName.equals('createListChildCasesUnfraudBA')) {
                createListChildCasesUnfraudBA(input, outMap, options);
            }
            if (methodName.equals('createListChildCasesFraudBA')) {
                createListChildCasesFraudBA(input, outMap, options);
            }
            if (methodName.equals('createListChildCasesAssets')) {
                createListChildCasesAssets(input, outMap, options);
            }
            return true;
        }
        catch(Exception e)
        {
            outMap.put('error', e.getMessage() + e.getStackTraceString());
            System.debug('taCareSuspensionsAndReconnections:invokeMethod -> exception: '+e);
            return false;
        }
    }




private void createOrderBackoffice(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
         Map<String,Object> step3 = (Map<String,Object>)inputMap.get('Step3');
         List<Object> AssetsM = (List<Object>) step3.get('AssetsM');
         Map<String,Object> selectedAsset = (Map<String,Object>) AssetsM[0];
         
         AssetsM = new List<Object>(); 
         step3 = new Map<String,Object>();
         
         ///////////////Crear order a partir de un Asset (asset y todos sus assets hijos como order items)//////////////////
            
             Map<String,Object> step2 = (Map<String,Object>)inputMap.get('Step2-SelectAssetOrDocument');
             String seleccion = (String) step2.get('optionSelectAsset');
             
             step2 = new Map<String,Object>();
            
            if(seleccion == 'linea'){
            
              Map<String,Object> input = new Map<String,Object>();
              Map<String,Object> output = new Map<String,Object>();
              Map<String,Object> optionsMap = new Map<String,Object>();
              
              String idStr = (String)selectedAsset.get('AssetId');
              Id idval = idStr;                   
              idStr = idval;                    

              input.put('id', idStr); //Id del asset recibido

              input.put('accountId', (String)inputMap.get('ContextId')); //Id de la cuenta
              input.put('subaction','assetToOrder');
              input.put('methodName', 'assetToOrder');
              
              String fecha = Date.today().day() + '/' + Date.today().month() + '/' + Date.today().year();
              
              input.put('requestDate', fecha); //No puede crearse dos ordenes para un mismo asset en la misma fecha ni fecha anterior
            
              vlocity_cmt.CpqAppHandler cpqa = new vlocity_cmt.CpqAppHandler();
              cpqa.invokeMethod('assetToOrder', input, output, optionsMap);
              
              vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) output.get('result');
              List<vlocity_cmt.JSONRecord> records = result.records;
              vlocity_cmt.JSONRecord record1 = records[0];
              Map<String,Object> fields = (Map<String,Object>)record1.fields;
              
              
              String idOrder = (String) fields.get('cartId');
              
              
              Order ordenCreada = [Select id from Order where id = : idOrder];
              
              ordenCreada.Delivery_Method__c = 'Presencial';
              ordenCreada.vlocity_cmt__OriginatingChannel__c = 'Presencial Agente';
              
              update ordenCreada;
            
            
        //////////////////Agrego a cada item de la orden los campos de suspension////////////
        
        List<OrderItem> items = new List<OrderItem>();
        
        items = [select id, orderId from OrderItem where orderid =: idOrder limit 10];
        
        Map<String,Object> mapaTipo = (Map<String,Object>)inputMap.get('Step1-SelectSuspensionOrReconnection');
        String tipo = (String) mapaTipo.get('SelectSuspensionOrReconnection');
        
         
        for(OrderItem itm : items){
            
            if(tipo == 'Suspension'){
            
            itm.vlocity_cmt__SubAction__c = 'Suspend-Operador';
            itm.vlocity_cmt__ProvisioningStatus__c = 'Suspend';
            
            }
            
            if(tipo == 'Reconection'){
                itm.vlocity_cmt__SubAction__c = 'Resume-Operador';
            itm.vlocity_cmt__ProvisioningStatus__c = 'Resume';
            }
        }
        
        update items;
         
        
        ///////////Checkout Order////////////////////
         
         Map<String,Object> input2 = new Map<String, Object>();
         Map<String,Object> output2 = new Map<String, Object>();
         Map<String,Object> options2 = new Map<String, Object>();
         
          List<Id> orderList = new List<Id>();
           
                
                orderList.add(idOrder);
            
            input2.put('orderIds', orderList);
            vlocity_cmt.VOIInvoker voi = vlocity_cmt.VOIInvoker.getInstance();
            voi.invoke('SubmitOrder', 'submitOrder', input2, output2, options2);
         
         
         //////////Submit de la orden a OM//////////
         
         vlocity_cmt.SimpleDecompositionController.decomposeOrder(idOrder);
         //vlocity_cmt.SimpleDecompositionController.startOrchestrationPlan(idOrder);
         
         ///////////////////////////////////////////
            } 
       }


private void createOrder(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
            
         Map<String,Object> selectedAsset = (Map<String,Object>)inputMap.get('selectedAsset');

         ///////////////Create Order a partir de un Asset (asset y todos sus assets hijos como order items)//////////////////
            
            
            if(selectedAsset != null || !selectedAsset.isEmpty()){
            
              Map<String,Object> input = new Map<String,Object>();
              Map<String,Object> output = new Map<String,Object>();
              Map<String,Object> optionsMap = new Map<String,Object>();
              
              String idStr = (String)selectedAsset.get('AssetId');
              Id idval = idStr;                   
              idStr = idval;                    

              input.put('id', idStr); //Id del asset recibido

              input.put('accountId', (String)inputMap.get('ContextId')); //Id de la cuenta
              input.put('subaction','assetToOrder');
              input.put('methodName', 'assetToOrder');
              
              String fecha = Date.today().day() + '/' + Date.today().month() + '/' + Date.today().year();
              
              input.put('requestDate', fecha); //No puede crearse dos ordenes para un mismo asset en la misma fecha ni fecha anterior
            
              vlocity_cmt.CpqAppHandler cpqa = new vlocity_cmt.CpqAppHandler();
              cpqa.invokeMethod('assetToOrder', input, output, optionsMap);
              
              vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) output.get('result');
              List<vlocity_cmt.JSONRecord> records = result.records;
              vlocity_cmt.JSONRecord record1 = records[0];
              Map<String,Object> fields = (Map<String,Object>)record1.fields;
              
              
              String idOrder = (String) fields.get('cartId');
            
            
        //////////////////Agrego a cada item de la orden los campos de suspension////////////
        
        List<OrderItem> items = new List<OrderItem>();
        
        items = [select id, orderId from OrderItem where orderid =: idOrder];
        
        Map<String,Object> mapaTipo = (Map<String,Object>)inputMap.get('Step1-SuspensionOrReconnection');
        String tipo = (String) mapaTipo.get('Radio1-SuspensionOrReconnection');
        
         
        for(OrderItem itm : items){
            
            if(tipo == 'Suspension'){
            
            itm.vlocity_cmt__SubAction__c = 'Suspend-Cliente';
            itm.vlocity_cmt__ProvisioningStatus__c = 'Suspend';
            
            }
            
            if(tipo == 'Reconexion'){
                itm.vlocity_cmt__SubAction__c = 'Resume-Cliente';
            itm.vlocity_cmt__ProvisioningStatus__c = 'Resume';
            }
        }
        
        update items;
         
        
        ///////////Checkout Order////////////////////
         
         Map<String,Object> input2 = new Map<String, Object>();
         Map<String,Object> output2 = new Map<String, Object>();
         Map<String,Object> options2 = new Map<String, Object>();
         
          List<Id> orderList = new List<Id>();
           
                
                orderList.add(idOrder);
            
            input2.put('orderIds', orderList);
            vlocity_cmt.VOIInvoker voi = vlocity_cmt.VOIInvoker.getInstance();
            voi.invoke('SubmitOrder', 'submitOrder', input2, output2, options2);
         
         
         //////////Submit de la orden a OM//////////
         
         vlocity_cmt.SimpleDecompositionController.decomposeOrder(idOrder);
         vlocity_cmt.SimpleDecompositionController.startOrchestrationPlan(idOrder);
         
         ///////////////////////////////////////////
            } 
            
        }

    private void getActiveOrSuspendedAssets (Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean debug = false;

        if(debug){System.debug('InputMap: ' + inputMap);}
        if(debug){System.debug('OutputMap: ' + outMap);}
        if(debug){System.debug('OptionsMap: ' + options);}

        String accId = (String)options.get('accId');

        if(debug){System.debug('accId: ' + accId);}

        List<Asset> assets = [SELECT Id, imei__c, Asset_Brand__c, assetModel__c, Status, Sub_Status__c, Linked_Product_Family__c,
                                Name, vlocity_cmt__ActivationDate__c, MSISDN__c, Product2Id
                                FROM Asset
                                WHERE AccountId=:accId
                                AND Linked_Product_Family__c = 'Movil'
                                AND Status IN ('Active','Suspended')];


        if(debug){System.debug('List assets: ' + assets);}

        outMap.put('Assets',assets);

        if(debug){System.debug('outMap: ' + outMap);}

    }

    void createListChildCasesUnfraudBA(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Id parentId = (Id)inputMap.get('DRId_Case');
       // Map<String, Object> clientInformation = (Map<String, Object>) inputMap.get('ClientInformation');
        List<Object> billingAccs = (List<Object>)options.get('BillingAccs');


        List<Case> listChildCases = new List<Case>();
        for(Object ba : billingAccs){
            Map<String, Object> baMap = (Map<String, Object>) ba; 
            Id accId =  (Id) baMap.get('Id');
            //string newId = myId.substring(0, 15);
            Case myCase = new Case();
            myCase.ParentId = parentId;
            myCase.AccountId = accId;
            myCase.Subject = 'Suspension/Habilitacion por Administrativas';
            myCase.Status = 'Cerrado';
            listChildCases.add(myCase);
        }
        insert listChildCases;
        outMap.put('Cases',listChildCases);
    }
    void createListChildCasesFraudBA(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Id parentId = (Id)inputMap.get('DRId_Case');
       // Map<String, Object> clientInformation = (Map<String, Object>) inputMap.get('ClientInformation');
        List<Object> billingAccs = (List<Object>)options.get('FraudBillingAccs');


        List<Case> listChildCases = new List<Case>();
        for(Object ba : billingAccs){
            Map<String, Object> baMap = (Map<String, Object>) ba; 
            Id accId =  (Id) baMap.get('Id');
            //string newId = myId.substring(0, 15);
            Case myCase = new Case();
            myCase.ParentId = parentId;
            myCase.AccountId = accId;
            myCase.Subject = 'Suspension/Habilitacion por Administrativas';
            myCase.Status = 'Cerrado';
            listChildCases.add(myCase);
        }
        insert listChildCases;
        outMap.put('Cases',listChildCases);
    }
        void createListChildCasesAssets(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Id parentId = (Id)inputMap.get('DRId_Case');
       // Map<String, Object> clientInformation = (Map<String, Object>) inputMap.get('ClientInformation');
        List<Object> billingAccs = (List<Object>)options.get('AssetsM');


        List<Case> listChildCases = new List<Case>();
        for(Object ba : billingAccs){
            Map<String, Object> baMap = (Map<String, Object>) ba; 
            Id assetId =  (Id) baMap.get('Id');
            //string newId = myId.substring(0, 15);
            Case myCase = new Case();
            myCase.ParentId = parentId;
            myCase.AssetId = assetId;
            myCase.Subject = 'Suspension/Habilitacion por Administrativas';
            myCase.Status = 'Cerrado';
            listChildCases.add(myCase);
        }
        insert listChildCases;
        outMap.put('Cases',listChildCases);
    }
}