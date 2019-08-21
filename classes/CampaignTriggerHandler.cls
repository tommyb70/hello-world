public class CampaignTriggerHandler {
  
   public static void CampaignTriggerBeforeInsert(List<Campaign> myCampaigns){
    
    set<string> profileNames = new set<string>();
    List<NGAMSettings__c> lstNAM = [select id,ProfileCventIntegration__c from NGAMSettings__c];
    
    for(NGAMSettings__c nam:lstNAM){
    if(nam.ProfileCventIntegration__c != null){profileNames.add(nam.ProfileCventIntegration__c);}
    }
    
    system.debug('profileNames==='+profileNames);
    profile pInfo = [select id,name from profile where Id =:userinfo.getProfileId()];
    system.debug('pInfo==='+pInfo.Name);
    system.debug('value==='+profileNames.contains(pInfo.Name));
    for(campaign cm:myCampaigns){
        
        cm.CventCampaign__c = profileNames.contains(pInfo.Name);
    }
}
 /*   public static void CampaignTriggerAfterInsert(List<Campaign> myCampaigns){
        
        List<CampaignShare> CampaignShareToCreate = new List<CampaignShare>();
        Set<id> OwnerIds = new Set<Id>();
        Map<id,id> RoleIdGroupId = new Map<id,id>();
        
        for (Group cgrp :  [Select Id, relatedid from Group where Type='Role'])
        {
            RoleIdGroupId.put(cgrp.relatedid, cgrp.Id);
        } 
        
        for (Campaign curCampaign : myCampaigns)
        {
            OwnerIds.add(curCampaign.ownerid);
        }
        
        Map<id,id> UserIdRoleId = new Map<id,id>();
        
        for (User usr : [Select id, UserRoleid from User where id in: OwnerIds])
        {
            UserIdRoleId.put(usr.id, usr.UserRoleid);
        }
        
        Set<Id> removeCampaignIDs = new Set<ID>();
        
        for (Campaign cItem : myCampaigns) {
            CampaignShareToCreate.add(new CampaignShare(
                CampaignId=cItem.id,
                UserOrGroupId=RoleIdGroupId.get(UserIdRoleId.get(cItem.ownerid)), 
                CampaignAccessLevel='Edit',
                RowCause='Manual')
                                     );   
            removeCampaignIDs.add(cItem.id);
            
            if (CampaignShareToCreate.size()>0)
            {
                insert CampaignShareToCreate; 
            }
            
        }
        
    }*/
}