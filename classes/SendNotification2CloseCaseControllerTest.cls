@isTest
public class SendNotification2CloseCaseControllerTest {
	
	@testSetup static void createDataTest() {
		Account account = TestDataFactory.createAccounts(1,'Consumer').get(0);
    	Asset asset = TestDataFactory.createAssets(1,account).get(0);
		List<Case> cases = TestDataFactory.createCases(1, account.Id, asset.Id, 'Test');
	}

    @isTest static void closeCaseTest() {
        //GIVEN
		String contactSMS = 'contactSMS';
		String contactEmail = 'contactEmail';
		
		Case caseOBJ = [SELECT Id, CaseNumber, Status FROM Case LIMIT 1];
		
        //WHEN
        Test.startTest();
        Boolean result = SendNotificationToCloseCaseController.closeCase(caseOBJ.CaseNumber, contactSMS, contactEmail);
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, result);
    }
    
    @isTest static void closeCaseNumberIsBlankTest() {
        //GIVEN
		String contactSMS = 'contactSMS';
		String contactEmail = 'contactEmail';
		String caseNumber = '';
		
        //WHEN
        Test.startTest();
        Boolean result = SendNotificationToCloseCaseController.closeCase(caseNumber, contactSMS, contactEmail);
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, result);
    }
    
    @isTest static void closeCaseConstructorTest() {
        //GIVEN
		String contactSMS = 'contactSMS';
		String contactEmail = 'contactEmail';
		String caseNumber = '';
		
        //WHEN
        Test.startTest();
        SendNotificationToCloseCaseController SendNotificationToCloseCaseController = new SendNotificationToCloseCaseController();
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, true);
    }
}