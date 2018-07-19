@isTest
public class ConsoleServicesAssetTest {
	
	
	@TestSetup static void createDataTest() {
		Account account = TestDataFactory.createAccounts(1).get(0);
		
		List<Product2> products = TestDataFactory.createProduct(3);
		
		for(Product2 p : products) {
			p.Family = 'Movil';
		}
		products.get(0).vlocity_cmt__Type__c = 'Plan Pospago';
		products.get(1).vlocity_cmt__Type__c = 'Plan Prepago';
		products.get(2).vlocity_cmt__Type__c = 'Plan Hibrido';
		
		update products;
		
		for(Product2 p : products){
			TestDataFactory.createAssets(1, p, account);
		}
		
		List<Asset> assets = [SELECT Status, vlocity_cmt__ActivationDate__c FROM Asset];
		
		assets.get(0).Status = 'Active';
		assets.get(1).Status = 'Inactive';
		assets.get(2).Status = 'Suspended';
		
		Datetime dt = System.now();
		Date activationDate = Date.newinstance(dt.year(), dt.month(), dt.day());
		
		assets.get(0).vlocity_cmt__ActivationDate__c = activationDate;
		assets.get(1).vlocity_cmt__ActivationDate__c = activationDate;
		assets.get(2).vlocity_cmt__ActivationDate__c = activationDate;
		
		update assets;		
	}
	
    @isTest static void GetPlanAssetsByAccountIdTest() {
        //GIVEN
        String nameMethod = 'GetPlanAssetsByAccountId';
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        input.put('Id',account.Id);
        
        ConsoleServicesAsset ConsoleServicesAsset = new ConsoleServicesAsset();
        
        //WHEN
        Boolean result = ConsoleServicesAsset.invokeMethod(nameMethod,input,output,options);
        
        //THEN
        System.assertEquals(true,result);
        System.assertEquals(true,output.containsKey('Result'));
        System.assertEquals(true,output.get('Result') instanceof Map<String,Object>);
        
    }
    
    @isTest static void GetAssetsToShow2Test() {
        //GIVEN
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //WHEN
        Map<String,Object> result = ConsoleServicesAsset.GetAssetsToShow2(account.Id);
        
        //THEN
        System.assertNotEquals(null,result);        
    }
    
    @isTest static void CompletePlanAssetInfoTest() {
        //GIVEN
		String lineNumber = '';
		        
        //WHEN
        Map<String,Object> result = ConsoleServicesAsset.CompletePlanAssetInfo(lineNumber);
        
        //THEN
        System.assertNotEquals(null,result);        
    }
}