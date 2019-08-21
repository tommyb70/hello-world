public class RunCampaignSharing {
    
    @InvocableMethod(label='Run Campaign Sharing' description='Runs campaign sharing')
    public static void runCampaignSharing(List<Campaign> campaigns) {
        
        Set<Id> campaignIds = new Set<Id>();
        List<Campaign> setRunSharingFalse = new List<Campaign>();
        
        for (Campaign c: campaigns) {
            campaignIds.add(c.Id);
            setRunSharingFalse.add(new Campaign(Id=c.Id));
        }
        
        List<CampaignShare> sharesToDelete = [SELECT Id FROM CampaignShare WHERE CampaignId in :campaignIds AND RowCause = 'Manual'];
        delete sharesToDelete;
        
        List<CampaignShare> sharesToCreate = new List<CampaignShare>();
        Set<Id> ownerIds = new Set<Id>();
        
        for (Campaign c : campaigns) {
            ownerIds.add(c.OwnerId);
        }
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ActivityTerritoryId__c, ActivityTerritoryRoleGroupId__c, ActivityTerritoryParentId__c, ActivityTerritoryType__c
                                                 FROM User
                                                 WHERE Id in: ownerIds]);
        
        for (Campaign sc: campaigns) {            
            if (userMap.containsKey(sc.OwnerId)) {
                if (userMap.get(sc.OwnerId).ActivityTerritoryRoleGroupId__c != null && userMap.get(sc.OwnerId).ActivityTerritoryRoleGroupId__c != '') {
                    sharesToCreate.add(new CampaignShare(CampaignId=sc.id, 
                                                         UserOrGroupId=userMap.get(sc.OwnerId).ActivityTerritoryRoleGroupId__c, 
                                                         CampaignAccessLevel='Edit', 
                                                         RowCause = 'Manual'));     
                }
            }
        }
        
        //When the owner's Activity Territory is a region, we need to share with all other territories under the region
        Set<Id> regionIdSet = new Set<Id>();
        
        for (User u : userMap.values()) {
            if (u.ActivityTerritoryType__c == 'Region') {
                regionIdSet.add(u.ActivityTerritoryId__c);
            }
        }
        
        Map<Id,Territory__c> childTerritoriesMap = new Map<Id,Territory__c>([SELECT Id, (SELECT Id, RoleGroupId__c FROM Territories__r) FROM Territory__c WHERE Id in :regionIdSet]);       
        
        for (Campaign scr : campaigns) {            
            for (Id i : childTerritoriesMap.keyset()) {               
                List<Territory__c> ct = childTerritoriesMap.get(i).Territories__r;                
                for (Territory__c cts : ct) {                    
                    sharesToCreate.add(new CampaignShare(CampaignId=scr.id, 
                                                         UserOrGroupId=cts.RoleGroupId__c, 
                                                         CampaignAccessLevel='Edit', 
                                                         RowCause = 'Manual'));     
                }
                
            }
        }      
        
        insert sharesToCreate; 
        
        for (Campaign c : setRunSharingFalse) {
            c.RunCampaignSharing__c = FALSE;
        }
        
        update setRunSharingFalse;
        
    }    
    
}