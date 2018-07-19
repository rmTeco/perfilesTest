@isTest
public class ta_Sales_NotifyPickupExpiration_Test {
    
		static testmethod void test() {  
                TestDataFactory.setTeamMember('Test', userinfo.getUserId(), null);
            	Date newDate = Date.today();
            
                Account acc = [SELECT Id FROM Account LIMIT 1];   
                List<Order> ords = TestDataFactory.createOrders(3, acc);
                            
                for(Order ordTes : ords){
                    ordTes.vlocity_cmt__ExpirationDate__c = Date.newInstance(2018, 03, 03);
                }
            	update ords;
            	System.debug('All orders here -'+ ords);
            
            	PlazoEsperaPickup__c plazo = new PlazoEsperaPickup__c();
            	plazo.Name = 'TestP';
            	plazo.DiasDeEspera__c = 1;
            	insert plazo;
            
            	System.debug('Here Plazo'+ plazo);
                   
                Crossobject__c crossObjectTest = new Crossobject__c( 
                    PickList1__c = 'Vencimiento de Pickup',
                    DateTime1__c = newDate, 
                    Account__c = acc.Id,  
                    Checkbox1__c = true,
                    RecordTypeId = '0126C0000000AHZQA2',
                    Order__c = ords.get(0).Id
                );
                insert crossObjectTest;
            
                Test.startTest();
                
                ta_Sales_NotifyPickupExpiration taSalesNotifyTesT = new ta_Sales_NotifyPickupExpiration();
                String sch = '0 0 23 * * ?';
                System.schedule('TestSales Notify Pickup', sch, taSalesNotifyTesT);
                
                Test.stopTest();
                //System.debug('Here code new'+ taSalesChecTest)
               // System.assertEquals(3, [select count() from Order where Delivery_Method__c = 'Retiro']);
   		 }
}