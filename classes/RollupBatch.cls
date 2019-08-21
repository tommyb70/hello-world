global class RollupBatch implements Database.Batchable<sObject>, Database.Stateful{     
     
    global Database.querylocator start(Database.BatchableContext BC){  
    
		//Querying Records from dlrs__LookupRollupSummaryScheduleItems__c Object  
        return Database.getQueryLocator([select Id, dlrs__LookupRollupSummary2__c,
                                                dlrs__QualifiedParentID__c,
                                                dlrs__LookupRollupSummary__c, dlrs__ParentId__c
                                         //       dlrs__LookupRollupSummary__r.dlrs__ParentObject__c,
                                         //       dlrs__LookupRollupSummary__r.dlrs__ChildObject__c 
                                         FROM dlrs__LookupRollupSummaryScheduleItems__c]);

    } 
    
    global void execute(Database.BatchableContext BC, List<dlrs__LookupRollupSummaryScheduleItems__c> scope) {         

        if(!scope.IsEmpty()){
            
            // Map to store parent object name and its record Ids
            Set<Id> metaIdSet = new Set<Id>(); 

            for (dlrs__LookupRollupSummaryScheduleItems__c i : scope) {
                metaIdSet.add(i.dlrs__LookupRollupSummary2__c);
            }
            
            Map<Id,dlrs__LookupRollupSummary2__mdt> metadataMap = new Map<Id,dlrs__LookupRollupSummary2__mdt>([SELECT Id, dlrs__ParentObject__c,dlrs__ChildObject__c
                                                                                                              FROM dlrs__LookupRollupSummary2__mdt
                                                                                                              WHERE Id in :metaIdSet]);
            
            Map<String,set<String>> mapSObjects = new Map<String,set<String>>(); 
            
            List<dlrs__LookupRollupSummaryScheduleItems__c> schedulesToDelete = new List<dlrs__LookupRollupSummaryScheduleItems__c>();                
            
            // Looping dlrs__LookupRollupSummaryScheduleItems__c records
            for(dlrs__LookupRollupSummaryScheduleItems__c SI:scope){ 
                
                //if condition to check dlrs__QualifiedParentID__c not null and dlrs__LookupRollupSummary__r.dlrs__ParentObject__c not null
                //and dlrs__LookupRollupSummary__r.dlrs__ChildObject__c not null 
                
                if (metadataMap.containsKey(SI.dlrs__LookupRollupSummary2__c)) {
                String parentObj = metadataMap.get(SI.dlrs__LookupRollupSummary2__c).dlrs__ParentObject__c;
                
                if(SI.dlrs__ParentId__c != null && parentObj != null && !parentObj.contains('/')){                    
                    //checking and adding data to mapSObjects
                    if(!mapSObjects.containsKey(parentObj)){                        
                        mapSObjects.put(parentObj,new set<String>());
                    }                    
                    //checking and adding data to both the maps defined above                   
                    mapSObjects.get(parentObj).add(SI.dlrs__ParentId__c);                 
                    
                  }                
            }
            }
            
            // If Parent Map is not empty looping
            if(!mapSObjects.IsEmpty()){                   
                set<Id> parentIds = new set<Id>();
                for(string keySet:mapSObjects.keyset()){                    
                    set<String> recordIds = mapSObjects.get(keySet); 
                    
                    //Querying Parent data to check whethere records exists or not                    
                    String strQuery = 'SELECT Id, Name FROM '+keySet +' where Id IN:recordIds';                        
                    Map<Id,SObject> mapParentRecords = new Map<Id,Sobject>(Database.query(strQuery));
                    for(string parentId:recordIds){
                        if((mapParentRecords.isEmpty() || !mapParentRecords.containsKey(parentId))){
                            parentIds.add(parentId);
                        }
                    }
                }
                
                if(!parentIds.IsEmpty()){                   
                   for(dlrs__LookupRollupSummaryScheduleItems__c SI:scope){                        
                       if(SI.dlrs__ParentId__c != null && parentIds.contains(SI.dlrs__ParentId__c)){
                       		schedulesToDelete.add(SI);
                       }
                   }
                   
                   if(!schedulesToDelete.IsEmpty()){
                      delete schedulesToDelete;
                   }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        
        if (!test.isRunningTest()) {
            Id batchJobId = Database.executeBatch(new dlrs.RollupJob());
       }
            
    }    
}