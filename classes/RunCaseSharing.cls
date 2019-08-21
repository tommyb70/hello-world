public class RunCaseSharing {
    
    @InvocableMethod(label='Run Case Sharing' description='Runs case sharing')
    public static void runCaseSharing(List<Case> cases) {
        
        Id PWRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId(); //never share Private Wealth Cases
        
        Set<Id> caseIds = new Set<Id>();
        List<Case> setRunSharingFalse = new List<Case>();
        
        for (Case c: cases) {
            caseIds.add(c.Id);
            setRunSharingFalse.add(new Case(Id=c.Id));
        }
        
        List<CaseShare> sharesToDelete = [SELECT Id FROM CaseShare WHERE CaseId in :caseIds AND RowCause = 'Manual'];
        delete sharesToDelete;
        
        Map<Id,CaseShare> sharesToCreateMap = new Map<Id,CaseShare>();
        Set<Id> userIds = new Set<Id>();
        
        for (Case c : cases) {
            if (c.Requestor__c != null && String.valueOf(c.Requestor__c).startsWith('005')) userIds.add(c.Requestor__c);
            if (c.SubmittedOnBehalfOf__c != null && String.valueOf(c.SubmittedOnBehalfOf__c).startsWith('005')) userIds.add(c.SubmittedOnBehalfOf__c);
        }
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ActivityTerritoryId__c, ActivityTerritoryRoleGroupId__c, ActivityTerritoryParentId__c, ActivityTerritoryType__c
                                                 FROM User
                                                 WHERE Id in: userIds]);
        
        for (Case sc: cases) {    
            if (!sc.IsPrivateWealthCase__c) {
                if (userMap.containsKey(sc.Requestor__c)) {
                    if (userMap.get(sc.Requestor__c).ActivityTerritoryRoleGroupId__c != null) {
                        sharesToCreateMap.put(userMap.get(sc.Requestor__c).ActivityTerritoryRoleGroupId__c,
                                              (new CaseShare(CaseId=sc.id, 
                                                             UserOrGroupId=userMap.get(sc.Requestor__c).ActivityTerritoryRoleGroupId__c, 
                                                             CaseAccessLevel='Edit', 
                                                             RowCause = 'Manual')));     
                    }
                }
                
                if (sc.SubmittedOnBehalfOf__c != null && userMap.containsKey(sc.SubmittedOnBehalfOf__c)) {
                    if (userMap.get(sc.SubmittedOnBehalfOf__c).ActivityTerritoryRoleGroupId__c != null) {
                        sharesToCreateMap.put(userMap.get(sc.SubmittedOnBehalfOf__c).ActivityTerritoryRoleGroupId__c,
                                              (new CaseShare(CaseId=sc.id, 
                                                             UserOrGroupId=userMap.get(sc.SubmittedOnBehalfOf__c).ActivityTerritoryRoleGroupId__c, 
                                                             CaseAccessLevel='Edit', 
                                                             RowCause = 'Manual')));                  }
                }
            }
            
            
            
        }
        
        //When the requestor's Activity Territory is a region, we need to share with all other territories under the region
        Set<Id> regionIdSet = new Set<Id>();
        
        for (User u : userMap.values()) {
            if (u.ActivityTerritoryType__c == 'Region') {
                regionIdSet.add(u.ActivityTerritoryId__c);
            }
        }
        
        Map<Id,Territory__c> childTerritoriesMap = new Map<Id,Territory__c>([SELECT Id, (SELECT Id, RoleGroupId__c FROM Territories__r) FROM Territory__c WHERE Id in :regionIdSet]);       
        
        for (Case scr : cases) {   
            if (scr.RecordTypeId != PWRecordTypeId) {
                for (Id i : childTerritoriesMap.keyset()) {               
                    List<Territory__c> ct = childTerritoriesMap.get(i).Territories__r;                
                    for (Territory__c cts : ct) { 
                        if (cts.RoleGroupId__c != null) { 
                            sharesToCreateMap.put(cts.RoleGroupId__c, (new CaseShare(CaseId=scr.id, 
                                                                                     UserOrGroupId=cts.RoleGroupId__c, 
                                                                                     CaseAccessLevel='Read', 
                                                                                     RowCause = 'Manual')));     
                        }
                    }
                    
                }
            }
        }      
        
        insert sharesToCreateMap.values(); 
        
        for (Case c : setRunSharingFalse) {
            c.RunCaseSharing__c = FALSE;
        }
        
        update setRunSharingFalse;
        
    }
    
    
}