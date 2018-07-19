@isTest
public class ta_sales_releaseForeignLinesBatchTest {
	
     static testmethod void test() {  
                TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
            
         		Account acc = TestDataFactory.createAccounts(1,'Consumer')[0];
         		Product2 prod = TestDataFactory.createProduct(1)[0];
               	Order ords = TestDataFactory.createOrders(1, acc)[0];
         		System.debug('All account here -' + acc + 'All orders'+ ords);
                 
                Contact cont = new Contact(LastName ='TestName', AccountId = acc.Id,PermanencyDueDate__c = Date.newInstance(2018,2,27),DocumentType__c = 'PAS');
        		insert cont;
         
   				Asset a = new Asset(Name='TestAsset', Product2Id=prod.Id, AccountId=acc.Id, MSISDN__c='test', ContactId = cont.Id);
                insert a;
         
				Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
    			insert pb;
         
				// First insert a price for the standard price book
				PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
    			insert standardPBE;
         		
         	/*	OrderItem ordItem = new OrderItem(OrderId = ords.Id,PricebookEntryId = standardPBE.Id, Quantity= 200, UnitPrice = 0);
         		insert ordItem;
        		System.debug('All ordeItem here -' + ordItem);*/
       
                Test.startTest();
                
                ta_sales_releaseForeignLinesBatch taSalesRealease = new ta_sales_releaseForeignLinesBatch();
                String sch = '0 0 23 * * ?';
                System.schedule('TestSales Realease Line', sch, taSalesRealease);
                
                Test.stopTest();
                //System.debug('Here code new'+ taSalesChecTest)
               // System.assertEquals(3, [select count() from Order where Delivery_Method__c = 'Retiro']);
   		 }
}