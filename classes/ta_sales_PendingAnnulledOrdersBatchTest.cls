@isTest
public class ta_sales_PendingAnnulledOrdersBatchTest {
    static testMethod void testMethod1() 
    {
        SalesOrderAnnulmentTimeout__c cs = new SalesOrderAnnulmentTimeout__c();
        cs.Name = 'DefaultTimeout';
        cs.TimeoutDays__c = 0;
        
        insert cs;
        
        vlocity_cmt__PriceList__c taPriceList = TestDataFactory.createPriceList('Telecom Price List');
        
    	Id orderRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'TechCare_Repair_Estimate' AND SobjectType = 'Order' LIMIT 1].Id;

        Account acc = new Account();
        acc.Name ='Name';
        
        insert acc;        

        Order o = new Order(Name='TestOrder',
                            RecordTypeId = orderRecordTypeId,
                            AccountId=acc.Id,
                            EffectiveDate=Date.today(),
                            Status='Draft',
                            TrackingStatus__c = 'Pendiente de Anulacion',
                            Pricebook2Id =Test.getStandardPricebookId(),
                            vlocity_cmt__PriceListId__c=taPriceList.Id,
                            vlocity_cmt__OriginatingChannel__c='Agentes');

        insert o;

        Order o2 = new Order(Name='TestOrder2',
                            RecordTypeId = orderRecordTypeId,
                            AccountId=acc.Id,
                            EffectiveDate=Date.today(),
                            Status='Draft',
                            TrackingStatus__c = 'Pendiente de Anulacion',
                            Pricebook2Id =Test.getStandardPricebookId(),
                            vlocity_cmt__PriceListId__c=taPriceList.Id,
                            vlocity_cmt__OriginatingChannel__c='Agentes');

        insert o2;
        
        Test.setCreatedDate(o.Id, DateTime.newInstance(2018,01,12));
        
        Test.startTest();

            ta_sales_PendingAnnulledOrdersBatch obj = new ta_sales_PendingAnnulledOrdersBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}