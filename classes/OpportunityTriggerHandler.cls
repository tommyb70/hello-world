public class OpportunityTriggerHandler {
    
    public static Id instRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('InstSubAdv').getRecordTypeId();
    public static Boolean systemUser = (Boolean)NGAMSettingsHierarchy__c.getInstance().ApexSystemUserOrProfile__c;
    
    public static void OpportunityBeforeInsert(List<Opportunity> newOpptyList, Map<Id,Opportunity> newOpptyMap){
        
        validateData(newOpptyList);
        newOpptyList = setOpptyTerrRegChannel(newOpptyList, null);
        newOpptyList = setOpptyFirmId(newOpptyList, null);
        
    }
    
    public static void OpportunityBeforeUpdate(List<Opportunity> newOpptyList, Map<Id,Opportunity> newOpptyMap, Map<Id,Opportunity> oldOpptyMap){
        
        validateData(newOpptyList);
        newOpptyList = setOpptyTerrRegChannel(newOpptyList, oldOpptyMap);
        newOpptyList = setOpptyFirmId(newOpptyList, oldOpptyMap);
        
    }
    
    public static void OpportunityAfterUpdate (List<Opportunity> newOpptyList, Map<Id,Opportunity> newOpptyMap, Map<Id,Opportunity> oldOpptyMap) { 
        
        createOpptyContactRole(newOpptyList, newOpptyMap, oldOpptyMap);
        createOpptyShares(newOpptyList);
        
    }
    
    public static void OpportunityAfterInsert(List<Opportunity> newOpptyList, Map<Id,Opportunity> newOpptyMap) {
        
        createOpptyContactRole(newOpptyList, newOpptyMap, null);
        createOpptyShares(newOpptyList);
        
    }
    
    public static List<Opportunity> setOpptyFirmId(List<Opportunity> newOpptyList, Map<Id,Opportunity> oldOpptysMap) {
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for (Opportunity o : newOpptyList) {
            if (oldOpptysMap == null || o.AccountId != oldOpptysMap.get(o.Id).AccountId || o.Touch__c != oldOpptysMap.get(o.Id).Touch__c) {            
                accountIdSet.add(o.AccountId);
            }
        }
        
        if (!accountIdSet.isEmpty()) {
            Map<Id,Id> accountFirmIdMap = Util.getAccountFirmIdMap(accountIdSet);
            for (Opportunity o : newOpptyList) {
                if (accountFirmIdMap.containsKey(o.AccountId)) {
                    o.Firm__c = accountFirmIdMap.get(o.AccountId);
                }
            }
        }
        
        return newOpptyList;
        
    }    
    
    public static void createOpptyContactRole(List<Opportunity> newOpptyList, Map<Id,Opportunity> newOpptyMap, Map<Id,Opportunity> oldOpptysMap) {
        
        List<OpportunityContactRole> contactRolesToUpsert = new List<OpportunityContactRole>();
        
        for (Opportunity o : [SELECT Id, RepContact__c, (SELECT Id, IsPrimary, ContactId, OpportunityId FROM OpportunityContactRoles)
                              FROM Opportunity
                              WHERE Id IN : newOpptyList]) {
                                  
                                  if (o.OpportunityContactRoles.isEmpty() && o.RepContact__c != null) {
                                      contactRolesToUpsert.add(new OpportunityContactRole(OpportunityId = o.Id, ContactId = o.RepContact__c, IsPrimary = TRUE));
                                  } else {
                                      
									Set<Id> existingContacts = new Set<Id>();

                                      for (OpportunityContactRole ocr : o.OpportunityContactRoles) {
                                          existingContacts.add(ocr.Id);
                                      }
                                      
                                      for (OpportunityContactRole ocr : o.OpportunityContactRoles) {
                                          
                                          if (!existingContacts.contains(ocr.Id)) {
                                              contactRolesToUpsert.add(new OpportunityContactRole(OpportunityId = o.Id, 
                                                                                                              ContactId = o.RepContact__c, 
                                                                                                              IsPrimary = TRUE));
                                          }
                                          
                                          if (ocr.IsPrimary && o.RepContact__c != ocr.ContactId) {
                                              ocr.IsPrimary = FALSE;
                                              contactRolesToUpsert.add(ocr);
                                          }
                                          
                                          if (!ocr.IsPrimary && o.RepContact__c == ocr.ContactId) {
                                              ocr.IsPrimary = TRUE;
                                              contactRolesToUpsert.add(ocr);
                                          }
                                                                                    
                                      }
                                      
                                  }                              
                                  
                              }
        
        upsert contactRolesToUpsert;
        
    }
    
    public static List<Opportunity> setOpptyTerrRegChannel(List<Opportunity> newOpptyList, Map<Id,Opportunity> oldOpptysMap) {
        
        Set<Id> ownerIdSet = new Set<Id>();
        
        for (Opportunity o : newOpptyList) {
            if (oldOpptysMap == null || o.OwnerId != oldOpptysMap.get(o.Id).OwnerId || o.Touch__c != oldOpptysMap.get(o.Id).Touch__c) {
                ownerIdSet.add(o.OwnerId);
            }
        }
        
        if (!ownerIdSet.isEmpty()) {
            
            Map<Id,User> userTerritoryMap = Util.getUserTerritoryMap(ownerIdSet);
            
            for (Opportunity o : newOpptyList) {
                
                if (userTerritoryMap.containsKey(o.OwnerId)) {
                    
                    switch on userTerritoryMap.get(o.OwnerId).ActivityTerritoryType__c {
                        when 'Territory' {
                            o.OpportunityRegion__c = userTerritoryMap.get(o.OwnerId).ActivityTerritoryParentId__c;
                        }
                        when 'Region' {
                            o.OpportunityRegion__c = userTerritoryMap.get(o.OwnerId).ActivityTerritoryId__c;
                        }
                    }
                    
                    o.OpportunityTerritory__c = userTerritoryMap.get(o.OwnerId).ActivityTerritoryId__c;
                    o.OpportunityRegionDept__c = userTerritoryMap.get(o.OwnerId).ActivityTerritoryParentId__c;
                    o.OpportunityChannel__c = userTerritoryMap.get(o.OwnerId).ActivityChannelId__c;
                    
                }
                
            }
            
        }
        
        return newOpptyList;
        
    }    
    
    
    private static void createOpptyShares(List<Opportunity> newOpptyList) {
        
        List<OpportunityShare> opptySharesToCreate = new List<OpportunityShare>();
        
        Set<Id> ownerIdSet = new Set<Id>();
        Map<Id,Id> opptyRegionSharingMap = new Map<Id,Id>();
        Map<Id,Id> opptyTerritorySharingMap = new Map<Id,Id>();
        
        for (Opportunity op : newOpptyList) {
            ownerIdSet.add(op.OwnerId);
        }
        
        Map<Id,User> userTerritoryMap = Util.getUserTerritoryMap(ownerIdSet);
        
        for (Opportunity o : newOpptyList) {
            
            if (userTerritoryMap.containsKey(o.OwnerId)) {
                
                switch on userTerritoryMap.get(o.OwnerId).ActivityTerritoryType__c {
                    when 'Territory' {
                        opptyTerritorySharingMap.put(o.Id, userTerritoryMap.get(o.OwnerId).ActivityTerritoryId__c);
                        opptyRegionSharingMap.put(o.Id, userTerritoryMap.get(o.OwnerId).ActivityTerritoryParentId__c);
                    }
                    when 'Region' {
                        opptyRegionSharingMap.put(o.Id, userTerritoryMap.get(o.OwnerId).ActivityTerritoryId__c);
                    }
                    when else {
						opptyTerritorySharingMap.put(o.Id, userTerritoryMap.get(o.OwnerId).ActivityTerritoryId__c);
                    }
                }
                
            }
            
        }
        
        Map<Id,Id> territoryRoleMap = new Map<Id,Id>();
        Set<Id> roleIdSet = new Set<Id>();
        
        for (Territory__c t : [SELECT Id, RoleId__c FROM Territory__c
                               WHERE Id IN :opptyRegionSharingMap.values()
                               OR Id IN :opptyTerritorySharingMap.values()]) {
                                   
                                   territoryRoleMap.put(t.Id,t.RoleId__c);
                                   roleIdSet.add(t.RoleId__c);
                                   
                               }
        
        Map<Id,Id> roleGroupMap = new Map<Id,Id>();
        
        for (Group g : [SELECT Id, RelatedId
                        FROM Group
                        WHERE RelatedId IN :roleIdSet
                        AND Type = 'RoleAndSubordinates']) {
                            roleGroupMap.put(g.RelatedId, g.Id);
                        }
        
        for (Opportunity o : newOpptyList) {
            
            if (opptyTerritorySharingMap.containsKey(o.Id) &&
                roleGroupMap.get(territoryRoleMap.get(opptyTerritorySharingMap.get(o.Id))) != null) {
                opptySharesToCreate.add(new OpportunityShare(OpportunityId = o.id,
                                                             UserOrGroupId = roleGroupMap.get(territoryRoleMap.get(opptyTerritorySharingMap.get(o.Id))),
                                                             OpportunityAccessLevel='Edit'));     
            }            
            
            if (opptyRegionSharingMap.containsKey(o.Id) &&
                roleGroupMap.get(territoryRoleMap.get(opptyRegionSharingMap.get(o.Id))) != null) {
                opptySharesToCreate.add(new OpportunityShare(OpportunityId = o.id,
                                                             UserOrGroupId = roleGroupMap.get(territoryRoleMap.get(opptyRegionSharingMap.get(o.Id))),
                                                             OpportunityAccessLevel='Edit'));     
            }            
            
        }    
        
        insert opptySharesToCreate;
        
    }
    
    private static void validateData(Map<Id,Opportunity> newOpptyMap) {
        
        if (!systemUser) {
            
           for (Opportunity o : newOpptyMap.values()) {
                if (Trigger.IsInsert && o.RecordTypeId == instRecTypeId && o.StageName == 'Won Unfunded') {
                     o.addError('You must provide both Fee Structure and Funding for every product associated with this opporunity before moving to Won Unfunded. Add the opportunity in a different stage and provide this information.');
                }
            }

        List<Opportunity> opptyLineCheck = [SELECT Id, RecordTypeId, StageName, (SELECT OpportunityId, FeeStructure__c, Funding__c FROM OpportunityLineItems)
                                            FROM Opportunity
                                            WHERE Id IN: newOpptyMap.keySet()];
        
        for (Opportunity o : opptyLineCheck) {

                if (o.RecordTypeId == instRecTypeId && newOpptyMap.get(o.Id).StageName == 'Won Unfunded') {
                    
                    for (OpportunityLineItem oli : o.OpportunityLineItems) {
                        
                        if (String.isBlank(oli.FeeStructure__c) || String.isBlank(oli.Funding__c)) {
                            Opportunity actualOppty = newOpptyMap.get(o.Id);
                            actualOppty.addError('You must provide both Fee Structure and Funding for every product associated with this opporunity before moving to Won Unfunded');
                        }
                        
                    }
                    
                }
                
            }
                        
        }
        
    }

    private static void validateData(List<Opportunity> newListOpps) {

        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        for (Integer i = 0; i < newListOpps.size(); i++) {
            newOpptyMap.put(newListOpps[i].Id, newListOpps[i]);
        }

        validateData(newOpptyMap);
        
    }
    
}