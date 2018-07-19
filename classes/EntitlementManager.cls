public with sharing class EntitlementManager {
    
    public static Entitlement CreateEntitlement(String entitleName,ID accId, Date startDate, ID entitlementProcessId){
        Entitlement entitleObj = New Entitlement(name=entitleName , AccountId=accId, StartDate=startDate, SlaProcessId=entitlementProcessId);
        return entitleObj;
    }
    
    /*public static Entitlement GetExistentEntitlement (ID accId, ID entitlementProcessId){
        Entitlement entitle = [SELECT id,AccountId,SlaProcessId,name FROM Entitlement WHERE AccountId=:accId AND SlaProcessId=:entitlementProcessId LIMIT 1];
        return entitle;
    }*/
    
    public static Map<Id,Entitlement> GetExistentEntitlementMap (Set<Id> accIdSet, ID entitlementProcessId){
        Map<Id,Entitlement> resultMap = New Map<Id,Entitlement>();
        List<Entitlement> entitle = [SELECT id,AccountId,SlaProcessId,name FROM Entitlement WHERE AccountId IN: accIdSet AND SlaProcessId=:entitlementProcessId LIMIT 1];
        if(entitle.size() > 0){
            for(Entitlement ent: entitle){
                resultMap.put(ent.AccountId,ent);
            }
        }
        return resultMap;
    }
}