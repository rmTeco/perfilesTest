@isTest
private class BillingResponseHandlerTest {
	
	@testSetup static void createDataTest(){
		//List<Account> accounts = TestDataFactory.createAccounts(1,'Consumer');
		TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
        /*
		List<Order> orders = new List<Order>();
		for (Account a: accounts) {
			orders.addAll(TestDataFactory.createOrders(1,a));
		}
        */
        MockUpFactory.generate();
	}
    
    static testMethod void BillingResponse_Handler() {
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, String>();
        options.put('ContactFirstName', 'Contact First Name');
        options.put('ContactLastName', 'Contact LastName');
        options.put('AccountName', 'Sample Account');
        options.put('DocumentType', 'DNI');
        options.put('DocumentNumber', '12345678');
        options.put('AccountNumber', '1234');
        options.put('Email', 'test@yopmail.com');
        options.put('PhoneNumber', '1234567890');
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod('callBackService224', inputMap, outMap, options);
        BResp.invokeMethod('testGetSystemURL', inputMap, outMap, options);
        //BResp.invokeMethod('callNominationCheckout', inputMap, outMap, options);
        BResp.invokeMethod('getNominationAssets', inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest static void callBackService224_OKWithOrderStatusSucced() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","Status":"payment succeed","StatusInvoice":"invoice succeed","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest static void callBackService224_OKWithOrderStatusSuccedRecarga() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id, Gestion__c, OriginStoreLocation__c FROM Order LIMIT 1];
        order.Gestion__c = 'Recarga';
        update order;
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Product2> product = TestDataFactory.createProduct(1);
        List<Asset> assets = TestDataFactory.createAssets(1,product.get(0),account);
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsWithAsset(1,order,assets.get(0));
        String MSISDN = '{"MSISDN":[{"attributedisplayname__c":"MSISDN","attributeRunTimeInfo":{"value":"nroLinea"}}]}';
        orderItems.get(0).vlocity_cmt__JSONAttribute__c = MSISDN;
        update orderItems.get(0);
        
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","Status":"payment succeed","StatusInvoice":"invoice succeed","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest static void callBackService224_OKWithOrderIdNull() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        String ReasonCode = 'ReasonCode';
        
        insert new Order_Failed_Payment_Messages__c(Name = 'Error_Code__c', Error_Code__c=ReasonCode);
                
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","ReasonCode":"'+ReasonCode+'","Status":"Draft","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }
    @isTest static void callBackService224_Error001() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        TASalesCodeValue__c cod2 = new TASalesCodeValue__c();
        cod2.Name= 'IF224ReasonAnulada';
        cod2.Value__c = '2';
        insert cod2;
        
        String ReasonCode = '2';
        insert new Order_Failed_Payment_Messages__c(Name = 'Error_Code__c', Error_Code__c=ReasonCode);
                
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","ReasonCode":"'+ReasonCode+'","Status":"payment failed","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }

    @isTest static void callBackService224_Error002() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        TASalesCodeValue__c cod3 = new TASalesCodeValue__c();
        cod3.Name= 'IF224ReasonCancelada';
        cod3.Value__c = '3';
        insert cod3;
        
        String ReasonCode = '3';
        insert new Order_Failed_Payment_Messages__c(Name = 'Error_Code__c', Error_Code__c=ReasonCode);
                
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","ReasonCode":"'+ReasonCode+'","Status":"payment failed","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }

    @isTest static void callBackService224_OKWithOrderDeliveryMethodStorePickUp() {
        //GIVEN
        String methodName = 'callBackService224';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        order.Delivery_Method__c = 'Store Pick Up';
        update order;
        
        String ReasonCode = 'ReasonCode';
        insert new Order_Failed_Payment_Messages__c(Name = 'Error_Code__c', Error_Code__c=ReasonCode);
                
        String JSONResponse = '{"invoiceAndPaymentNotification":{"SalesOrderId":"'+order.Id+'","Status":"payment succeed","StatusInvoice":"invoice succeed","LegalInvoiceNumber":"LegalInvoiceNumber"}}';
        
        options.put('JSONResponse',JSONResponse);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest static void callNominationCheckoutOK() {
        //GIVEN
        String methodName = 'callNominationCheckout';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Product2> product = TestDataFactory.createProduct(1);
        List<Asset> assets = TestDataFactory.createAssets(1,product.get(0),account);
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsWithAsset(1,order,assets.get(0));
        
        options.put('orderId', order.Id);
        options.put('accountId', account.Id);
        options.put('assetId', assets.get(0).Id);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }
    
    @isTest static void prepareOrderForOM() {
        //GIVEN
        String methodName = 'prepareOrderForOM';
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = null;
        Map<String, Object> options = new Map<String, Object>();
        
        Order order = [SELECT Id FROM Order LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Product2> product = TestDataFactory.createProduct(1);
        List<Asset> assets = TestDataFactory.createAssets(1,product.get(0),account);
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsWithAsset(1,order,assets.get(0));
        
        options.put('orderId', order.Id);
        options.put('accountId', account.Id);
        options.put('assetId', assets.get(0).Id);
        
        //WHEN
        Test.startTest();
        BillingResponseHandler BResp = new BillingResponseHandler();
        BResp.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    }

    static testMethod void SendSuccesfulOrderClientNotification() {
        Test.startTest();
        Order order = [SELECT Id FROM Order LIMIT 1];
        BillingResponseHandler.SendSuccesfulOrderClientNotification(order.Id);
        Test.stopTest();
    }

    static testMethod void SendSuccesfulPaymentClientNotification() {
        Test.startTest();
        Order order = [SELECT Id FROM Order LIMIT 1];
        BillingResponseHandler.SendSuccesfulPaymentClientNotification(order.Id);
        Test.stopTest();
    }
 }