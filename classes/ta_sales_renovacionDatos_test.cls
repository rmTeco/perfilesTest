@isTest 
private class ta_sales_renovacionDatos_test {
    
    @isTest static void GetAvailableOffersTest() {
    	//GIVEN
    	String nameMethod = 'GetAvailableOffers';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = '';
    	
    	Account account = TestDataFactory.createAccounts(1).get(0);
    	TestDataFactory.createAssets(1,account);
    	
    	Asset asset = [SELECT vlocity_cmt__LineNumber__c, AccountId FROM Asset LIMIT 1];
    	asset.vlocity_cmt__LineNumber__c = nroLinea;
    	update asset;
    	
    	input.put('nroLinea',nroLinea);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
    
    @isTest static void EnviarSMSExitoTest() {
    	//GIVEN
    	String nameMethod = 'EnviarSMSExito';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = '';    	
    	input.put('nroLinea',nroLinea);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
    
    @isTest static void ChangeSubOfferingMeasureMTest() {
    	//GIVEN
    	String nameMethod = 'ChangeSubOffering';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = 'NroLinea';
    	TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
    	Account account = [SELECT Id FROM Account LIMIT 1];
    	TestDataFactory.createAssets(1,account);
    	
    	Asset asset = [SELECT vlocity_cmt__LineNumber__c, AccountId FROM Asset LIMIT 1];
    	asset.vlocity_cmt__LineNumber__c = nroLinea;
    	asset.MSISDN__c = nroLinea;
    	update asset;
    	    	
        List<Object> selectedCombo = new List<Object>();
        Map<String,Object> combo = new Map<String,Object>();
        
        Product2 product = TestDataFactory.createProduct(1).get(0);
        product.vlocity_cmt__JSONAttribute__c = '{"attributes":[{"attributedisplayname__c":"Unidad de Medida de Vigencia","attributeRunTimeInfo":{"default":[{"value":"H"}]}},{"attributedisplayname__c":"Vigencia Activacion","attributeRunTimeInfo":{"default":"24"}},{"attributedisplayname__c":"ID Sistema Origen","attributeRunTimeInfo":{"default":"FAN_PRDA_00003"}}]}';                                                                                         
        product.ProductCode = 'FAN_PRDA_00003'; // OJO CON ESTE VALOR, ESTÁ HARD CODE EN EL SOURCE
        update product;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id =Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true
        );

        insert standardPrice;
        
        String codOferta = product.ProductCode;
        Id idListaPrecio = standardPrice.Id;
        String precioConImp = '100';
        
        combo.put('vlcSelected',true);
        combo.put('codOferta',codOferta);
        combo.put('idListaPrecio',idListaPrecio);
        combo.put('precioConImp',precioConImp);
        
        selectedCombo.add(combo);
        
        Order orderOBJ = TestDataFactory.createOrders(1,account).get(0);
        String idOrder = (String) orderOBJ.Id;
        
        Schema.DescribeFieldResult fieldResult = Order.PaymentMethodType__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        String medioDePago = pleList.get(0).getValue();
    	
    	options.put('NroLinea', nroLinea);
    	options.put('SelectedCombo', selectedCombo);
    	options.put('IdOrder', idOrder);
    	options.put('MedioDePago', medioDePago);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
    
    @isTest static void ChangeSubOfferingMeasureWTest() {
    	//GIVEN
    	String nameMethod = 'ChangeSubOffering';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = 'NroLinea';
    	TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
    	Account account = [SELECT Id FROM Account LIMIT 1];
    	TestDataFactory.createAssets(1,account);
    	
    	Asset asset = [SELECT vlocity_cmt__LineNumber__c, AccountId FROM Asset LIMIT 1];
    	asset.vlocity_cmt__LineNumber__c = nroLinea;
    	asset.MSISDN__c = nroLinea;
    	update asset;
    	    	
        List<Object> selectedCombo = new List<Object>();
        Map<String,Object> combo = new Map<String,Object>();
        
        Product2 product = TestDataFactory.createProduct(1).get(0);
        product.vlocity_cmt__JSONAttribute__c = '{"attributes":[{"attributedisplayname__c":"Unidad de Medida de Vigencia","attributeRunTimeInfo":{"default":[{"value":"W"}]}},{"attributedisplayname__c":"Vigencia Activacion","attributeRunTimeInfo":{"default":"24"}},{"attributedisplayname__c":"ID Sistema Origen","attributeRunTimeInfo":{"default":"FAN_PRDA_00003"}}]}';                                                                                         
        product.ProductCode = 'FAN_PRDA_00003'; // OJO CON ESTE VALOR, ESTÁ HARD CODE EN EL SOURCE
        update product;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id =Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true
        );

        insert standardPrice;
        
        String codOferta = product.ProductCode;
        Id idListaPrecio = standardPrice.Id;
        String precioConImp = '100';
        
        combo.put('vlcSelected',true);
        combo.put('codOferta',codOferta);
        combo.put('idListaPrecio',idListaPrecio);
        combo.put('precioConImp',precioConImp);
        
        selectedCombo.add(combo);
        
        Order orderOBJ = TestDataFactory.createOrders(1,account).get(0);
        String idOrder = (String) orderOBJ.Id;
        
        Schema.DescribeFieldResult fieldResult = Order.PaymentMethodType__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        String medioDePago = pleList.get(0).getValue();
    	
    	options.put('NroLinea', nroLinea);
    	options.put('SelectedCombo', selectedCombo);
    	options.put('IdOrder', idOrder);
    	options.put('MedioDePago', medioDePago);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
    
    @isTest static void ChangeSubOfferingMeasureDTest() {
    	//GIVEN
    	String nameMethod = 'ChangeSubOffering';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = 'NroLinea';
    	TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
    	Account account = [SELECT Id FROM Account LIMIT 1];
    	TestDataFactory.createAssets(1,account);
    	
    	Asset asset = [SELECT vlocity_cmt__LineNumber__c, AccountId FROM Asset LIMIT 1];
    	asset.vlocity_cmt__LineNumber__c = nroLinea;
    	asset.MSISDN__c = nroLinea;
    	update asset;
    	    	
        List<Object> selectedCombo = new List<Object>();
        Map<String,Object> combo = new Map<String,Object>();
        
        Product2 product = TestDataFactory.createProduct(1).get(0);
        product.vlocity_cmt__JSONAttribute__c = '{"attributes":[{"attributedisplayname__c":"Unidad de Medida de Vigencia","attributeRunTimeInfo":{"default":[{"value":"D"}]}},{"attributedisplayname__c":"Vigencia Activacion","attributeRunTimeInfo":{"default":"24"}},{"attributedisplayname__c":"ID Sistema Origen","attributeRunTimeInfo":{"default":"FAN_PRDA_00003"}}]}';                                                                                         
        product.ProductCode = 'FAN_PRDA_00003'; // OJO CON ESTE VALOR, ESTÁ HARD CODE EN EL SOURCE
        update product;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id =Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true
        );

        insert standardPrice;
        
        String codOferta = product.ProductCode;
        Id idListaPrecio = standardPrice.Id;
        String precioConImp = '100';
        
        combo.put('vlcSelected',true);
        combo.put('codOferta',codOferta);
        combo.put('idListaPrecio',idListaPrecio);
        combo.put('precioConImp',precioConImp);
        
        selectedCombo.add(combo);
        
        Order orderOBJ = TestDataFactory.createOrders(1,account).get(0);
        String idOrder = (String) orderOBJ.Id;
        
        Schema.DescribeFieldResult fieldResult = Order.PaymentMethodType__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        String medioDePago = pleList.get(0).getValue();
    	
    	options.put('NroLinea', nroLinea);
    	options.put('SelectedCombo', selectedCombo);
    	options.put('IdOrder', idOrder);
    	options.put('MedioDePago', medioDePago);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
    
    @isTest static void ChangeSubOfferingMonthTest() {
    	//GIVEN
    	String nameMethod = 'ChangeSubOffering';
    	Map<String,Object> input = new Map<String,Object>();
    	Map<String,Object> output = new Map<String,Object>();
    	Map<String,Object> options = new Map<String,Object>();
    	
    	String nroLinea = 'NroLinea';
    	TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
    	Account account = [SELECT Id FROM Account LIMIT 1];
    	TestDataFactory.createAssets(1,account);
    	
    	Asset asset = [SELECT MSISDN__c, vlocity_cmt__LineNumber__c, AccountId FROM Asset LIMIT 1];
    	asset.vlocity_cmt__LineNumber__c = nroLinea;
    	asset.MSISDN__c = nroLinea;
    	update asset;
    	    	
        List<Object> selectedCombo = new List<Object>();
        Map<String,Object> combo = new Map<String,Object>();
        
        Product2 product = TestDataFactory.createProduct(1).get(0);
        product.vlocity_cmt__JSONAttribute__c = '{"attributes":[{"attributedisplayname__c":"Unidad de Medida de Vigencia","attributeRunTimeInfo":{"default":[{"value":"MONTH"}]}},{"attributedisplayname__c":"Vigencia Activacion","attributeRunTimeInfo":{"default":"24"}},{"attributedisplayname__c":"ID Sistema Origen","attributeRunTimeInfo":{"default":"FAN_PRDA_00003"}}]}';                                                                                         
        product.ProductCode = 'FAN_PRDA_00003'; // OJO CON ESTE VALOR, ESTÁ HARD CODE EN EL SOURCE
        update product;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id =Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true
        );

        insert standardPrice;
        
        String codOferta = product.ProductCode;
        Id idListaPrecio = standardPrice.Id;
        String precioConImp = '100';
        
        combo.put('vlcSelected',true);
        combo.put('codOferta',codOferta);
        combo.put('idListaPrecio',idListaPrecio);
        combo.put('precioConImp',precioConImp);
        
        selectedCombo.add(combo);
        
        Order orderOBJ = TestDataFactory.createOrders(1,account).get(0);
        String idOrder = (String) orderOBJ.Id;
        
        Schema.DescribeFieldResult fieldResult = Order.PaymentMethodType__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        String medioDePago = pleList.get(0).getValue();
    	
    	options.put('NroLinea', nroLinea);
    	options.put('SelectedCombo', selectedCombo);
    	options.put('IdOrder', idOrder);
    	options.put('MedioDePago', medioDePago);
    	
    	ta_sales_renovacionDatos ta_sales_renovacionDato = new ta_sales_renovacionDatos();
    	
    	//WHEN
    	Test.startTest();
    	ta_sales_renovacionDato.invokeMethod(nameMethod,input,output,options);
    	Test.stopTest();
    	
    	//THEN
    	System.assert(true);
    }
}