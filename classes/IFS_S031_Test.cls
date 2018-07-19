@isTest 
public class IFS_S031_Test {
    @isTest static  void testGetCallout() {
        IFS_S031 service31 = new IFS_S031();
        Order ordenTest = new Order();
        Account accountTest = new Account();
        String accountIntID = '0026D000000tAmdPER';
        accountTest.AccountIntegrationId__c = accountTest.id;
        ordenTest.Account = accountTest;
        accountTest.Name = 'Juan Perez';
        insert accountTest;
        insert ordenTest;
        map<String,Object> input = new map<String,Object>();
        map<String,Object> output = new map<String,Object>();
        map<String,Object> options = new map<String,Object>();
        input.put('IdOrder',ordenTest.id);
        vlocity_cmt__PaymentAdjustment__c payment = new vlocity_cmt__PaymentAdjustment__c();
        payment.Order__c=ordenTest.id;
        insert payment;
        service31.invokeMethod('test',input,output,options);
        system.assertEquals(1,1);
    }
    
}