global with sharing class ta_care_refundsGetWorrkTeamPermisess implements vlocity_cmt.VlocityOpenInterface{
    global ta_care_refundsGetWorrkTeamPermisess(){}
    
     public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String,Object> options)
    {
        Boolean result = true;
        try
        {
            if(methodName.equals('getQueueByWorkTeamPermisess')){
                getQueueByWorkTeamPermisess(outMap,options);
            }            
        }
        catch(Exception e)
        {
            System.debug('getQueueByWorkTeamPermisess:invokeMethod -> exception: '+e);
            result = false;
        }
        return result;
    }
    
    void getQueueByWorkTeamPermisess(Map<String, Object> outMap, Map<String,Object> options){
        List<Object> resultList = new List<Object>();
        List<Object> queueName = (List<Object>)options.get('PermissesName');
        System.debug('Name queue' + queueName);
        
        String queueNameTeam;
        for(Object obj: queueName){
            Map<String, Object> resultMap = (Map<String, Object>)obj;
            queueNameTeam = (String)resultMap.get('APIName');
        }
        String bb='_';
        String gg = ' ';
        String queueNameTeamComplete = queueNameTeam.replace(bb, gg);
        System.debug('really name:' + queueNameTeamComplete);
        
        Group groupQueue = [SELECT Id,Name,Type FROM Group where Name LIKE :('%'+ queueNameTeamComplete +'%')];
        ID idQueueTeam = groupQueue.Id;
        resultList.add(idQueueTeam);
        
        System.debug('resultList:' + resultList);
        
        outMap.put('NewQueueTeam',resultList);        
    }
}