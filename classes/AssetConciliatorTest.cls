/**
   */
   @isTest
   private class AssetConciliatorTest {

    @isTest static void TestSendOrderToOM() {

      Map<String,Object> inputMap = new Map<String,Object>();
      Map<String,Object> outMap = new Map<String,Object>();
      Map<String,Object> options = new Map<String,Object>();

      AssetConciliator assetConciliator = new AssetConciliator();

      Case getCase = createCase ();
      inputMap.put('sendOrderFdoId', getCase.Order__c);

      Test.startTest();
      assetConciliator.invokeMethod('sendOrderToOM',inputMap,outMap,options) ;
            
      Test.stopTest();

    }

    @isTest static void TestUpdateOrderToOM() {

      Map<String,Object> inputMap = new Map<String,Object>();
      Map<String,Object> outMap = new Map<String,Object>();
      Map<String,Object> options = new Map<String,Object>();

      AssetConciliator assetConciliator = new AssetConciliator();

      Case getCase = createCase ();
      inputMap.put('orderFdoId', getCase.Order__c);

      Test.startTest();
      assetConciliator.invokeMethod('updateOrderToOM',inputMap,outMap,options) ;
            
      Test.stopTest();

    }



    @isTest static void TestOrderToOMNotOk() {

      Map<String,Object> inputMap = new Map<String,Object>();
      Map<String,Object> outMap = new Map<String,Object>();
      Map<String,Object> options = new Map<String,Object>();

      AssetConciliator assetConciliator = new AssetConciliator();
      Test.startTest();
      assetConciliator.invokeMethod('Conciliate',inputMap,outMap,options) ;
      Test.stopTest();

    }

  public static Case createCase(){

    Account accountExample = TestDataFactory.createAccounts(1)[0];
    Product2 prod = TestDataFactory.createProduct(1)[0];
    Contact contactExample = TestDataFactory.createContacts(1,accountExample)[0];

    Asset getAsset = createAsset(accountExample,prod,contactExample);
    Order getOrder = createOrder(getAsset);

    Case newCaseExample = new Case(
    Subject='New Case Test Conciliator',
    AccountId = getAsset.AccountId,
    AssetId = getAsset.Id,
    Order__c = getOrder.Id,
    Status = 'Informada');

   insert newCaseExample;
   return newCaseExample;

   }

   public static Asset createAsset(Account accountExample, Product2 prod, Contact contactExample){   

      Asset newAssetExample = new Asset(Name='New Asset Test', Product2Id=prod.Id, AccountId=accountExample.Id, ContactId=contactExample.Id, MSISDN__c='1123568749');

      insert newAssetExample;
      return newAssetExample;
    }

  public static Order createOrder (Asset assetTest){

    Contract contractExample = new Contract(Name='New Order Test Conciliator',StartDate=Date.Today(),Status = 'Draft', AccountId = assetTest.AccountId,  ContractTerm = 4);
    insert contractExample;

    vlocity_cmt__PriceList__c taPriceList = TestDataFactory.createPriceList('Telecom Price List');

    Order orderExample = new Order();
    orderExample.Name = 'test order conciliator';
    orderExample.AccountId = assetTest.AccountId;
    orderExample.ContractId = contractExample.Id;
    orderExample.Pricebook2Id =Test.getStandardPricebookId();
    orderExample.EffectiveDate = Date.Today();
    orderExample.Status = 'Draft';
    orderExample.vlocity_cmt__PriceListId__c=taPriceList.Id;
    orderExample.Delivery_Method__c = 'Presencial';
    orderExample.vlocity_cmt__OriginatingChannel__c='Agentes';    

    insert orderExample;

    TestDataFactory.createOrderItem(2, orderExample);

    return orderExample;

  }
}