@isTest
public class taSalesChangeTerminalInWarrantyTest
{
  Public static testmethod void test1()
  {
    List<Account> lstAccount = TestDataFactory.createAccounts(1, 'Consumer');
    List<Product2> lstProduct2 = TestDataFactory.createProduct(1);
    Asset assetTest = new Asset();
    assetTest.Name = 'Test Asset';
    assetTest.AccountId = lstAccount[0].Id;
    assetTest.Product2Id =  lstProduct2[0].Id;
    lstProduct2[0].productCode = 'CHIPPRUEBA';
    update lstProduct2;
    insert assetTest;
    vlocity_cmt__BusinessSite__c storeLocation = new vlocity_cmt__BusinessSite__c(
      Name = 'Barrio Norte',
      vlocity_cmt__OrganizationId__c = lstAccount[0].Id,
      Status__c = 'Activo',
      Type__c = 'POS',
      Channel__c = 'Físico',
      Channel_Type__c = 'Agentes',
      Channel_Type_2__c = 'Agentes',
      Channel_Type_3__c = 'Agentes',
      Region__c='AMBA');
    insert storeLocation;

        WorkTeam__c workTeamParent = new WorkTeam__c(
      Team_Name__c = 'Test Parent',
      Name = 'Test Parent');
        insert workTeamParent;

    AnnulmentTimeLimit__c objTimeAnnul = new AnnulmentTimeLimit__c();
    objTimeAnnul.Channel__c = 'Físico';
    objTimeAnnul.LocationCode__c = 'C';
    objTimeAnnul.Name = 'CABA_Fisico';
    objTimeAnnul.TimeLimit__c = 30.0;
    insert objTimeAnnul;

    User usernew = new user(ID = UserInfo.getUserID());
        String strIdUser = UserInfo.getUserID();

        String manager = UserInfo.getUserId();
        String parent = workTeamParent.Id;
        WorkTeam__c workTeam = new WorkTeam__c(Team_Name__c = 'Test', Name = 'Test');
    Team_Member__c tm = TestDataFactory.setTeamMember('Call Center', UserInfo.getUserId(), null);
    List<Order>OrdList = TestDataFactory.createOrders(2,lstAccount[0]);
    OrdList[0].OriginStoreLocation__c = storeLocation.Id;
    OrdList[0].PaymentMethodType__c ='1001';
    OrdList[0].vlocity_cmt__OriginatingChannel__c ='Presencial Oficina Comercial';
    OrdList[0].Gestion__c = 'Venta';
    OrdList[1].SubGestion__c = '';
    OrdList[1].OriginStoreLocation__c = storeLocation.Id;
    OrdList[1].PaymentMethodType__c ='1001';
    OrdList[1].vlocity_cmt__OriginatingChannel__c ='Presencial Oficina Comercial';
    OrdList[1].Gestion__c = 'Venta';
    OrdList[1].SubGestion__c = '';
    update OrdList;
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    options.put('assetId', assetTest.Id);
    Test.startTest();
      taSalesChangeTerminalInWarrantyHandler tsctiw = new taSalesChangeTerminalInWarrantyHandler();
      tsctiw.invokeMethod('ValidateCEGRazonSocial', inputMap, outputMap, options);
      tsctiw.invokeMethod('validationTimeDefenseConsumer', inputMap, outputMap, options);
    Test.stopTest();
  }

  public static testmethod void ChangeTerminalInWarrantyHandlerTest()
  {
    Account account = TestDataFactory.createAccounts(1, 'Consumer')[0];
    account.AccountIntegrationId__c = '10000000564';
    update account;

    vlocity_cmt__BusinessSite__c storeLocation = new vlocity_cmt__BusinessSite__c(
      Name = 'Barrio Norte',
      vlocity_cmt__OrganizationId__c = Account.Id,
      Status__c = 'Activo',
      Type__c = 'POS',
      Channel__c = 'Físico',
      Channel_Type__c = 'Agentes',
      Channel_Type_2__c = 'Agentes',
      Channel_Type_3__c = 'Agentes',
      Region__c='AMBA');
    insert storeLocation;

    WorkTeam__c workTeamParent = new WorkTeam__c(
      Team_Name__c = 'Test Parent',
      Name = 'Test Parent');
      insert workTeamParent;

    User usernew = new user(ID = UserInfo.getUserID());
        String strIdUser = UserInfo.getUserID();

        String manager = UserInfo.getUserId();
        String parent = workTeamParent.Id;
        WorkTeam__c workTeam = new WorkTeam__c(Team_Name__c = 'Test', Name = 'Test');
    Team_Member__c tm = TestDataFactory.setTeamMember('Call Center', UserInfo.getUserId(), null);

    List<Order> ordList = TestDataFactory.createOrders(1, account);
    Order ord1 = ordList[0];
    Order order1 = [SELECT Id FROM Order WHERE Id = :ord1.Id];
    order1.Name = 'OrderTestVPA1';
    order1.OriginStoreLocation__c = storeLocation.Id;
    order1.DeliveryDate__c = Date.parse('04/04/2018');
    update order1;

    List<OrderItem> itemsList = new List<OrderItem>();
    List<OrderItem> itemsList1 = TestDataFactory.createOrderItem(1, order1);
    itemsList1[0].vlocity_cmt__OneTimeTotal__c  = 0;
    itemsList1[0].vlocity_cmt__SerialNumber__c  = '89543410307680582547';
    itemsList.add(itemsList1[0]);
    update itemsList;

    // Se setea el id de orderItem en asset para relacionarlo como order creadora del asset
    OrderItem ordItem1 = itemsList1[0];
    Asset asset = TestDataFactory.CreateAssets(1, account)[0];
    asset.vlocity_cmt__OrderProductId__c = ordItem1.Id;
    update asset;


 /*   AnnulmentAvailableChannels__c annulmentAvailableChannels = new AnnulmentAvailableChannels__c(
      Name = 'Test',
      OriginChannel__c = 'Oficinas Comerciales',
      AnnulmentChannel__c = 'Oficinas Comerciales');
    insert annulmentAvailableChannels; */

  //  List<vlocity_cmt__PaymentAdjustment__c> paymentAdjustmentList = TestDataFactory.createPaymentAdjustments(1, account, order1, null, 1);

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    //options.put('OrderID', order1.Id);
    //options.put('orderId', order1.Id);
    options.put('assetId', asset.Id);

    Test.startTest();
      taSalesChangeTerminalInWarrantyHandler tsctiw = new taSalesChangeTerminalInWarrantyHandler();
      tsctiw.invokeMethod('ValidateCEGRazonSocial', inputMap, outputMap, options);
    Test.stopTest();
  }
}