global with sharing class AssetConciliator implements vlocity_cmt.VlocityOpenInterface {

    global AssetConciliator () {

    } 

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        
        try {
            if (methodName.equals('updateOrderToOM')){

                String parameterOrderId = (String) inputMap.get('orderFdoId');
                List<Object> assetIdList = (List<Object>) inputMap.get('assetIdList');

                if(parameterOrderId.length() > 0 ){ 
                    updateOrderToOM(parameterOrderId, methodName, assetIdList);
                }else{
                     
                    throw new FuncException('Error en Orden a Conciliar');
                    
                }

            }else if(methodName.equals('sendOrderToOM')){

                String orderId = (String) inputMap.get('sendOrderFdoId');
                                            
                sendOrderToOM(orderId);

            }
                result = true; 

            }catch(Exception e){
                throw e;
            }
        return result;
    }



    public static void updateOrderToOM(String orderId, String action, List<Object> assetIdList) {

        try {

            Order order = [SELECT Gestion__c , Status FROM Order where Id = :orderId];
            order.Gestion__c = 'Conciliate';

            update order;

            List<OrderItem> listOrderItems = [SELECT Id, Order.Id, vlocity_cmt__Action__c, vlocity_cmt__SubAction__c, vlocity_cmt__ProvisioningStatus__c FROM OrderItem WHERE Order.Id =:orderId];
            if (listOrderItems.size()==0){
                throw new FuncException('Error: No Existen OrderItems');
            }

            Map<Id,Object> standardPriceMap = new Map<Id,Object>();
            for(OrderItem getOrderItem : listOrderItems ){
                getOrderItem.vlocity_cmt__Action__c = 'Existing';
                getOrderItem.vlocity_cmt__SubAction__c = 'Conciliate' ;
                getOrderItem.vlocity_cmt__ProvisioningStatus__c = 'Active';
               
            }

            update listOrderItems;
           
            }catch(Exception ex) {

                throw ex;

            }

        }

    private static void sendOrderToOM(String orderIdToOM) {
        
        String responseOM = vlocity_cmt.SimpleDecompositionController.decomposeAndCreatePlanEx(orderIdToOM, false );
        Map<String, Object> mapResponseOM = (Map<String, Object>) JSON.deserializeUntyped(responseOM);

        if(mapResponseOM.get('isOk')!= true){
            throw new FuncException('Error: ' + mapResponseOM.get('errorMsg'));
        }
        

    }  
}