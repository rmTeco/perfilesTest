@isTest
private class OrderManagerIntegrationConnectorTest {
	
	@isTest(SeeAllData=true)
	private static void TestOrderManagerIntegrationConnector() {
		
		Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOrderController());
            OrderManagerIntegrationConnector connector = new OrderManagerIntegrationConnector();
            String result =	connector.getMilestones('8016C0000000dPR');
            
        Test.stopTest();
	}
	

	
}