@IsTest
public class AdjustmentsService_test {
	@IsTest static void invoke_PopulatePicklist(){
    	String methodName = 'PopulatePicklist';
        
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
		
        AdjustmentsService adj = new AdjustmentsService();
        
        Test.startTest();
        adj.invokeMethod(methodName, input, outMap, options);
		Test.stopTest();
        
        system.assertNotEquals(null, outMap.get('options'));
    }
    
    @IsTest static void invoke_PopulateDependentPicklist(){
    	String methodName = 'PopulateDependentPicklist';
        
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
		
        AdjustmentsService adj = new AdjustmentsService();
        
        Test.startTest();
        adj.invokeMethod(methodName, input, outMap, options);
		Test.stopTest();
        
        system.assertNotEquals(null, outMap.get('dependency'));
    }
}