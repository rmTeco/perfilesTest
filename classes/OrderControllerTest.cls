@isTest
private class OrderControllerTest {

	@isTest(SeeAllData=true)
	private static void TestGetOrderConciliateOM() {

		Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOrderController());
            OrderController testOrderController = new OrderController();
        Test.stopTest();
	}
}