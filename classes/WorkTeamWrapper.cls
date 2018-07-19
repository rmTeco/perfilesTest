/**
* @author       Norwill Gutiérrez href=<ngutierrez@aconcaguabs.com>
* Project:      Telecom Security
* Description:  Wrapper Class for Security Hierarchy
*
* Changes (Version)
* -------------------------------------
*      No.    Date          Author                 Description
*      -----  ----------    --------------------   ---------------
*      1.0    2018-03-09    Norwill Gutiérrez      Class creation.
*************************************************************************************************************/
public with sharing class WorkTeamWrapper {
	public Boolean checked{ get; set; }
	public WorkTeam__c wt { get; set;}    
    public Integer wtPosInSet { get; set;}
    public String parent { get; set;}
    public Integer wtSetSize { get; set;}
    public Work_Team_Permission__c wtP { get; set;}

    public String parentName { get; set;}
    public String teamName { get; set;}
    

    public WorkTeamWrapper(WorkTeam__c wtN, String vlcActionName, Integer totalChildrens, Integer counter, String prefixP, Boolean isTopLevel){
        try{
            wt = wtN;
            wtSetSize = totalChildrens;
            wtP = null; 
            if(isTopLevel){
                parent = String.valueOf(wtN.WorkteamLevel__c);
            }else{
                parent = prefixP + String.valueOf(counter);
            }
            
            if(wtP != null){ 
                checked = wtP.Is_Active__c;
            }else{
                checked = false;
            }
        }catch(Exception e){
            wtP = null; 
            checked = false;              
        }
    }

    // public WorkTeamWrapper(WorkTeam__c wtN){
    //     try{
    //         teamName = wtN.Team_Name__c;
    //         if(String.isNotBlank(wtN.Parent_Team__c)){
    //             parentName = wtN.Parent_Team__c;
    //         }else{
    //             parentName = wtN.Team_Name__c;
    //         }
    //     }catch(Exception e){

    //     }
    // }

    public static void setPermissions(Map<Id, WorkTeamWrapper> teamNodes, String vlcActionName){     
        List<Work_Team_Permission__c> wtpResult = [SELECT 
                                                        Id, Work_Team__c, RecordTypeId, Permission_Set_API_Name__c, Is_Active__c
                                                    FROM 
                                                        Work_Team_Permission__c 
                                                    WHERE 
                                                        Work_Team__c = :teamNodes.keySet() AND Permission_Set_API_Name__c = :vlcActionName]; 

        for(Work_Team_Permission__c wtP :wtpResult){
            teamNodes.get(wtP.Work_Team__c).checked = wtP.Is_Active__c;
        }                                                        
    }
}