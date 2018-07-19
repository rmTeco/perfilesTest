global with sharing class mkt_productSearch implements vlocity_cmt.VlocityOpenInterface {

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        if(methodName.equals('PopulateProductsTypeAhead')){
            PopulateProductsTypeAhead(input, outMap, options);
        }
        return true;
    }

    public void PopulateProductsTypeAhead(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        try{
            List<Product2> products = [SELECT Name FROM Product2];

            outMap.put('products', products);
        }catch (Exception e){}
    }
}