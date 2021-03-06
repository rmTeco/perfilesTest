global with sharing class ta_techCare_Brand implements vlocity_cmt.VlocityOpenInterface{
  public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            if(methodName.equals('GetBrands')) GetBrands(outMap);

        } catch(Exception ex){
            options.put('error', ex.getMessage());
            outMap.put('error', ex.getMessage());
            return false;
        }
        return true;
    }
    
    private void GetBrands(Map<String, Object> outMap){
        try{
            List<Map<String,String>> options = new List<Map<String, String>>();
            
            for (Asset brand :[SELECT Asset_Brand__c FROM Asset WHERE Asset_Brand__c != NULL])
                
            { 
                Map<String, String> tempMap = new Map<String, String>();
                
                tempMap.put('name', (String) brand.get('Asset_Brand__c'));
                tempMap.put('value', (String) brand.get('Asset_Brand__c'));
                
                options.add(tempMap);
            }
            outMap.put('options', options);
            
        } catch(Exception ex){
            throw new FuncException('Error inesperado al obtener marcas: ' + ex.getMessage());
        }
    }
    
}