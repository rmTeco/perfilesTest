/**
* @author       Norwill Gutiérrez <ngutierrez@aconcaguabs.com>
* Project:      Telecom Security
* Description:  Class for Security Hierarchy
*
* Changes (Version)
* -------------------------------------
*      No.    Date          Author                 Description
*      -----  ----------    --------------------   ---------------
*      1.0    2018-03-28    Norwill Gutiérrez      Class creation.
*************************************************************************************************************/
public class WorkTeamHierarchyNode {
    @AuraEnabled
    public string teamId {get; set;}
    @AuraEnabled
    public string teamLevel {get; set;}
    @AuraEnabled
    public string teamName {get; set;}
    @AuraEnabled
    public string parentTeam {get; set;}
    @AuraEnabled    
    public Boolean checked {get; set;}    
    @AuraEnabled
    public List<WorkTeamHierarchyNode> children;

    WorkTeamHierarchyNode(WorkTeam__c wt, Integer counter, Map<Id, Work_Team_Permission__c> mapCheckPermissions) {
		teamId = wt.Id;
        teamName = wt.Team_Name__c;
        if(String.isNotBlank(wt.Parent_Team__c)){
            parentTeam = wt.Parent_Team__c + '-' + String.valueOf(counter);
        }else{
            parentTeam = wt.Id;
        }         
        teamLevel = String.valueOf(wt.WorkTeamLevel__c);
        if(mapCheckPermissions.containsKey(wt.Id)){
            checked = mapCheckPermissions.get(wt.Id).Is_Active__c;
        }else{
            checked = false;
        }
        
        children = new List<WorkTeamHierarchyNode>();
    }

    WorkTeamHierarchyNode(WorkTeam__c wt) {
		teamId = wt.Id;
    }

    public static Set<Id> getSetWorkTeamIds(List<WorkTeam__c> top_workTeams) {
        Set<Id> nodes = new Set<Id>();
        Set<Id> parent_wt_ids = new Set<Id>();
        
        for (WorkTeam__c a : top_workTeams) {
            nodes.add(a.Id);
            parent_wt_ids.add(a.Id);
        }
        
        while (parent_wt_ids.size() > 0) {
            Map<Id,WorkTeam__c> subordinate_workTeams =
                new Map<Id,WorkTeam__c>([
                    SELECT Id, Team_Name__c, Parent_Team__c, WorkTeamLevel__c
                    FROM WorkTeam__c
                    WHERE Parent_Team__c  IN :parent_wt_ids
                ]);
            
            parent_wt_ids = subordinate_workTeams.keySet();
            
            for (WorkTeam__c wt : subordinate_workTeams.values()) {
                nodes.add(wt.id);
            }            
        }
        return nodes;
    }

    public static WorkTeamHierarchyNode getWorkTeamHierarchyNode(List<WorkTeam__c> top_workTeams, Map<Id, Work_Team_Permission__c> permissionMap) {
        Integer counter = 1;
        Map<Id,WorkTeamHierarchyNode> nodes = new Map<Id,WorkTeamHierarchyNode>();
        Set<Id> parent_wt_ids = new Set<Id>();
        
        for (WorkTeam__c a : top_workTeams) {
            nodes.put(a.Id, new WorkTeamHierarchyNode(a, counter, permissionMap));
            parent_wt_ids.add(a.Id);
        }
        
        while (parent_wt_ids.size() > 0) {
            counter = counter + 1;
            Map<Id,WorkTeam__c> subordinate_workTeams =
                new Map<Id,WorkTeam__c>([
                    SELECT Id, Team_Name__c, Parent_Team__c, WorkTeamLevel__c
                    FROM WorkTeam__c
                    WHERE Parent_Team__c  IN :parent_wt_ids
                ]);
            
            parent_wt_ids = subordinate_workTeams.keySet();
            
            for (WorkTeam__c wt : subordinate_workTeams.values()) {
                counter = counter + 1;
                WorkTeamHierarchyNode new_node = new WorkTeamHierarchyNode(wt, counter, permissionMap);
                nodes.put(wt.id, new_node);
                WorkTeamHierarchyNode ref_node = nodes.get(wt.Parent_Team__c);
                ref_node.children.add(new_node);
            }            
        }
        return nodes.values()[0];
    }      	
}