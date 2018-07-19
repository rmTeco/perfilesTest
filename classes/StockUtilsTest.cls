@isTest(seeAllData = false)
public with sharing class StockUtilsTest
{
	@TestSetup
	static void setup()
	{
		MockupFactory.generate();
		Order order = [SELECT Id FROM Order LIMIT 1];
		List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
		for (OrderItem orderItem : orderItems)
		{
			orderItem.vlocity_cmt__SerialNumber__c = 'algo';
		}
		update orderItems;
	}
	
	static testMethod void stockMovementTest()
	{
		Order order = [SELECT Id FROM Order LIMIT 1];
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			StockUtils.StockMovement(order.Id, 'codOperacion', 'codDeposito');
		Test.stopTest();
	}
	
	static testMethod void stockMovementErrorTest()
	{
		Order order = [SELECT Id FROM Order LIMIT 1];
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorGenerator());
			try
			{
				StockUtils.StockMovement(order.Id, 'codOperacion', 'codDeposito');
			}
			catch (CallOutException e)
			{
				System.assert(e.getMessage().contains('Error en el llamado al servicio') ? true : false);
			}
		Test.stopTest();
	}
	
	public static testmethod void StockMovementTest2()
	{
		Map<String,String> mapSerialNumber = new Map<String,String>();
		mapSerialNumber.put('1111111','serial');
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			StockUtils.StockMovement(mapSerialNumber, 'codDeposito');
		Test.stopTest();
	}
}