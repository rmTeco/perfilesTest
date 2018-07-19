global with sharing class ta_techCare_diagnosis implements vlocity_cmt.VlocityOpenInterface{

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            if(methodName.equals('PopulateMotives')) PopulateMotives(input, outMap, options);
            else if(methodName.equals('ObtenerInfoMovil')) ObtenerInfoMovil(input, outMap, options);
            else if(methodName.equals('GetCpeIdentifierByModemAssetId')) GetCpeIdentifierByModemAssetId(input, outMap, options);
            else if(methodName.equals('GetServiceAttributes')) GetServiceAttributes(input, outMap, options);
            
        } catch(Exception ex){
            outMap.put('error', ex.getMessage());
            options.put('error', ex.getMessage());
        }
        
        return true;
    }

    public void ObtenerInfoMovil(Map<String, Object> inputMap,
        Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            Map<String, Object> tempElem = new Map<String, Object>();
            tempElem.put('statusFlag', true);

            outMap.put('options',tempElem);
        } catch(Exception ex){
            throw ex;
        }
    }

    // Returns all the motives and their associated service.
    public void PopulateMotives(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            Map<String, List<Map<String, String>>> dependency = new Map<String,List<Map<String, String>>>();

            for (Contact_Motive__c mot : [SELECT name,
                                         id,
                                         Id_Service__c
                                    FROM Contact_Motive__c
                                   WHERE is_active__c = true])
            { 
                if (!dependency.containsKey(mot.Id_Service__c))
                {
                    dependency.put(mot.Id_Service__c, new List<Map<String, String>>());
                }

                Map<String, String> tempMap = new Map<String, String>();

                tempMap.put('name', mot.Id);
                tempMap.put('value', mot.Name);

                dependency.get(mot.Id_Service__c).add(tempMap);
            }
            
            outMap.put('dependency', dependency);
        } catch(Exception ex){
            ex.setMessage('PopulateMotives - ' + ex.getMessage());
            throw ex;
        }
    }

    //private void GetServiceAttributes(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    public static void GetServiceAttributes(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            String idAsset = (String)options.get('AssetId');
            List<String> assetAttributes = new List<String>();
            assetAttributes.add('Real Download Speed');
            assetAttributes.add('Tecnologia');

            Map<String, Object> attribute = AssetAttributesUtils.getAssetAttribute(idAsset,assetAttributes);

            outMap.put('ServiceAttributes', attribute);

        } catch(FuncException ex){
            throw ex;
        } catch(Exception ex){
            //outMap.put('debug', debug+' options: ' + options);
            outMap.put('error', 'Error inesperado al obtener datos del servicio: ' + ex.getMessage());
            throw ex;
        }
    }

    private void GetCpeIdentifierByModemAssetId(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
    {
        try{
            String idAsset = (String)options.get('ModemAssetId');
            List<String> assetAttributes = new List<String>();
            assetAttributes.add('Serial Number');

            Map<String, Object> attribute = AssetAttributesUtils.getAssetAttribute(idAsset,assetAttributes);

            outMap.put('ModemAttributes', attribute);

        } catch(FuncException ex){
            throw ex;
        } catch(Exception ex){
            outMap.put('error', 'Error inesperado al obtener datos del producto: ' + ex.getMessage());
            throw ex;
        }
    }
}