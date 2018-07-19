global with sharing class AdjustmentsService implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        try {
            if (methodName.equals('PopulatePicklist')) {
                PopulatePicklist(inputMap, outMap, options);
            } else if (methodName.equals('PopulateDependentPicklist')) {
                PopulateDependentPicklist(inputMap, outMap, options);
            }

            return true;

        } catch(Exception ex) {
            system.debug('Error***' + ex.getStackTraceString());
            outMap.put('Error***', ex.getStackTraceString());
            return false;
        }
    }

    public void PopulatePicklist(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options2) {
        List<Map<String,String>> options = new List<Map<String, String>>();

        Map<String, String> tempMap = new Map<String, String>();

        tempMap.put('name', 'test');
        tempMap.put('value', 'test');

        options.add(tempMap);

        outMap.put('options', options);
    }

    public void PopulateDependentPicklist(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options2) {
        Map<String, List<Map<String, String>>> dependency = new Map<String, List<Map<String, String>>>();

        /*for (vlocity_namespace__RelationshipType__c rel : [ Select vlocity_namespace__TargetRole__c, vlocity_namespace__SourcePartyType__c Id FROM vlocity_namespace__RelationshipType__c ]) {
            if (!dependency.containsKey(rel.vlocity_namespace__SourcePartyType__c)) {
                dependency.put(rel.vlocity_namespace__SourcePartyType__c, new List<Map<String, String>>());
            }

            Map<String, String> tempMap = new Map<String, String>();

            tempMap.put('name', rel.Id);
            tempMap.put('value', rel.vlocity_namespace__TargetRole__c);

            dependency.get(rel.vlocity_namespace__SourcePartyType__c).add(tempMap);
        }*/

        List<Map<String,String>> options = new List<Map<String, String>>();

       

        Map<String, String> tempMap = new Map<String, String>();

        tempMap.put('name', 'test1');
        tempMap.put('value', 'test2');

        options.add(tempMap);

         dependency.put('test', options);

        //dependency.get(rel.vlocity_namespace__SourcePartyType__c).add(tempMap);
        
        outMap.put('dependency', dependency);
    }
}