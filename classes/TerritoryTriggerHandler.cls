public with sharing class TerritoryTriggerHandler{
    
    public static void UpdateTerritorySharing(List<Territory__c> NewTerrs, Map<Id,Territory__c> MyoldTerrMap){
        
        List<Territory__Share> TerrShareToCreate = new List<Territory__Share>();
        List<Territory__Share> TerrShareToDelete = new List<Territory__Share>();
        
        Set<id> TerrWithChanges= new set<id>();
        
        for (Territory__c cTerr: NewTerrs) {
            if (cTerr.RoleGroupId__c != null &&
                (cTerr.RoleGroupId__c != MyoldTerrMap.get(cTerr.id).RoleGroupId__c || cTerr.Touch__c != MyoldTerrMap.get(cTerr.id).Touch__c) ) {
                TerrWithChanges.add(cTerr.id);  
                Territory__Share TsR = new  Territory__Share(AccessLevel='Read',UserOrGroupId=cTerr.RoleGroupId__c,ParentId=cTerr.id );    
                TerrShareToCreate.add(TsR);
            }
        }
        
        TerrShareToDelete = [select id from Territory__Share where RowCause = 'Manual' and parentid in: TerrWithChanges];
        
        if (!TerrShareToDelete.isEmpty()) {
            delete TerrShareToDelete;
        } 
        if (!TerrShareToCreate.isEmpty()) {
            insert TerrShareToCreate;
        } 
        
    }
    
    
    public static void UpdateUserTerritoryName(List<Territory__c> NewTerritories, Map<Id,Territory__c> OldTerritories){
        
        List<User> usersToUpdate = New List<User>(); 
        Set<Id> ActivityTerritoryIds = New Set<Id>();
        
        for (Territory__c sti : NewTerritories) {
            ActivityTerritoryIds.add(sti.Id);
        }
        
        List<User> userList = New List<User>([SELECT Id, ActivityChannelName__c, ActivityChannelId__c, ActivityTerritoryParentMARSName__c, ActivityTerritoryParentId__c, ActivityTerritoryParentType__c, ActivityTerritoryName__c, DefaultTerritory__c FROM User WHERE IsActive = TRUE AND ActivityTerritoryId__c IN : ActivityTerritoryIds]);
        
        for (Territory__c nt : NewTerritories){
            Territory__c ot = OldTerritories.get(nt.Id);
            if (nt.Name != ot.Name || ot.ParentTerritory__c == null || nt.ParentTerritory__c != ot.ParentTerritory__c || nt.Channel__c != ot.Channel__c || nt.Touch__c != ot.Touch__c) {
                for (User utu : userList) {
                    utu.ActivityTerritoryName__c = nt.Name;
                    utu.DefaultTerritory__c = nt.Name;
                    utu.ActivityChannelId__c = nt.Channel__c;
                    utu.ActivityChannelName__c = nt.ChannelName__c;
                    utu.ActivityTerritoryParentMARSName__c = nt.ParentTerritoryMARSName__c;
                    utu.ActivityTerritoryParentId__c = nt.ParentTerritory__c;
                    utu.ActivityTerritoryParentType__c = nt.ParentTerritoryType__c;
                    utu.ActivityTerritoryParentName__c = nt.ParentTerritoryName__c;
                    usersToUpdate.add(utu);                    
                }
            }
        }
        
        Update usersToUpdate;
    }
}