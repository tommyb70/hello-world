public class ActivityProductTriggerHandler {
    
    public static void PreventDeletionOfOldRecords (List<ActivityProduct__c> ActivityProducts)  {
        
        Integer cannotCUDActivityAfterDays = (Integer)NGAMSettingsHierarchy__c.getInstance().CannotCUDActivityAfterDays__c;      
        system.debug('cannotCUDActivityAfterDays: ' + CannotCUDActivityAfterDays);
        
        for (ActivityProduct__c acd : ActivityProducts) {
            if (acd.date__c.daysBetween(Date.Today()) >= cannotCUDActivityAfterDays) {
                acd.addError('Cannot Delete Activity Product more than '+ cannotCUDActivityAfterDays + ' days after Activity Date');
            }
        } 
    }
    
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // ActivityProductAfterDelete
    // Will Delete all related ProductofInterest__c records
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void ActivityProductAfterDelete (List<ActivityProduct__c> ActivityProducts)  
        // Deletes all related  ProductofInterest__c records 
    {
        set <id> ActivityProductIds = new set<Id>();    
        
        for (ActivityProduct__c actProd : ActivityProducts)
        {    
            ActivityProductIds.add(actProd.id);    
        }
        
        List<ProductofInterest__c> POI_ToDelete = [select id from ProductofInterest__c where ActivityProductId__c in: ActivityProductIds];     
        
        if (!POI_ToDelete.isEmpty())
        {
            delete POI_ToDelete;
        } 
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    //  ActivityProductBeforeUpdate
    //  Sets the ActivityProduct__c key on the records
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void ActivityProductBeforeUpdate (List<ActivityProduct__c> ActivityProducts)  
    {
        for (ActivityProduct__c act : ActivityProducts)
        {
            act.ActivityProduct__c = act.ActivityId__c + '-' + act.Product__c;
        } 
    } 
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // ActivityProductBeforeInsert
    // Sets the ActivityProduct__c key on the records
    // Takes all the needed attributes from the related Task and copies them to the ActivityProduct__c records
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void ActivityProductBeforeInsert (List<ActivityProduct__c> ActivityProducts)  
    {         
        set <id> ActivityIds = new set<Id>();
        //set <id> ProductIds = new set<Id>();    
        
        for (ActivityProduct__c act : ActivityProducts)
        {
            act.ActivityProduct__c = act.ActivityId__c + '-' + act.Product__c;
            ActivityIds.add(act.ActivityId__c);
            //ProductIds.add(act.Product__c);   
        }
        
        Map<Id, Task> TaskMap = new Map<Id, Task>([Select Id, 
                                                   type, 
                                                   Subject, 
                                                   Status, 
                                                   ActivityDate, 
                                                   ActivitySource__c,                                  
                                                   OwnerChannel__c,
                                                   OwnerChannelId__c,
                                                   OwnerTerritory__c,
                                                   OwnerTerritoryMARS__c,
                                                   OwnerTerritoryId__c,
                                                   OwnerZoneFormula__c,
                                                   ownerid 
                                                   from Task where id in: ActivityIds]); 
        
        Map<Id, Event> EventMap = new Map<Id, Event>([Select Id, 
                                                      type, 
                                                      Subject, 
                                                      //Status, 
                                                      ActivityDate, 
                                                      ActivitySource__c,                                  
                                                      OwnerChannel__c,
                                                      OwnerChannelId__c,
                                                      OwnerTerritory__c,
                                                      OwnerTerritoryMARS__c,
                                                      OwnerTerritoryId__c,
                                                      OwnerZoneFormula__c,
                                                      ownerid 
                                                      from Event where id in: ActivityIds]); 
        
        for (ActivityProduct__c actProd : ActivityProducts)
        {
            if( TaskMap.containsKey(actProd.ActivityId__c))
            {
                actProd.Date__c = TaskMap.get(actProd.ActivityId__c).ActivityDate;
                actProd.Subject__c = TaskMap.get(actProd.ActivityId__c).Subject;
                actProd.Type__c = TaskMap.get(actProd.ActivityId__c).Type;
                actProd.Status__c = TaskMap.get(actProd.ActivityId__c).Status;
                actProd.ActivitySource__c = TaskMap.get(actProd.ActivityId__c).ActivitySource__c;  
                actProd.OwnerId = TaskMap.get(actProd.ActivityId__c).ownerid;     
                actProd.OwnerChannel__c = TaskMap.get(actProd.ActivityId__c).OwnerChannel__c;
                actProd.Channel__c = TaskMap.get(actProd.ActivityId__c).OwnerChannelId__c;
                actProd.OwnerTerritory__c = TaskMap.get(actProd.ActivityId__c).OwnerTerritory__c;
                actProd.OwnerTerritoryMARS__c = TaskMap.get(actProd.ActivityId__c).OwnerTerritoryMARS__c;
                actProd.OwnerTerritoryId__c = TaskMap.get(actProd.ActivityId__c).OwnerTerritoryId__c;
                actProd.OwnerZone__c = (id)TaskMap.get(actProd.ActivityId__c).OwnerZoneFormula__c; 
                
            }
            else
            {
                if( EventMap.containsKey(actProd.ActivityId__c))
                {
                    actProd.Date__c = EventMap.get(actProd.ActivityId__c).ActivityDate;
                    actProd.Subject__c = EventMap.get(actProd.ActivityId__c).Subject;
                    actProd.Type__c = EventMap.get(actProd.ActivityId__c).Subject;
                    
                    actProd.ActivitySource__c = EventMap.get(actProd.ActivityId__c).ActivitySource__c;  
                    actProd.OwnerId = EventMap.get(actProd.ActivityId__c).ownerid;     
                    actProd.OwnerChannel__c = EventMap.get(actProd.ActivityId__c).OwnerChannel__c;
                    actProd.Channel__c = EventMap.get(actProd.ActivityId__c).OwnerChannelId__c;
                    actProd.OwnerTerritory__c = EventMap.get(actProd.ActivityId__c).OwnerTerritory__c;
                    actProd.OwnerTerritoryMARS__c = EventMap.get(actProd.ActivityId__c).OwnerTerritoryMARS__c;
                    actProd.OwnerTerritoryId__c = EventMap.get(actProd.ActivityId__c).OwnerTerritoryId__c;
                    actProd.OwnerZone__c = (id)TaskMap.get(actProd.ActivityId__c).OwnerZoneFormula__c; 
                } 
            }
        }        
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // ActivityProductAfterInsert
    // Trigger finds all the ActivityContact__c related to the related tasks  
    // Generate / attaches the Product of Interest Records to these Contacts and to their related Accounts
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void ActivityProductAfterInsert (List<ActivityProduct__c> activityProducts)  
    {      
        set <id> ActivityIds = new set<Id>();  
        List<ProductofInterest__c> POI_ToInsert = new List<ProductofInterest__c>();   
        
        for (ActivityProduct__c act : ActivityProducts)
        {
            ActivityIds.add(act.ActivityId__c);   
        }   
        
        List<TaskRelation> taskRelationList = [SELECT Id, RelationId, AccountId, TaskId FROM TaskRelation WHERE TaskId IN: activityIds];
        
        for (ActivityProduct__c ap : activityProducts) {
            
            for (TaskRelation tr : taskRelationList) {
                Id activityId = (Id)ap.ActivityId__c;
                String realtionId = (String)tr.RelationId;
                if (tr.TaskId == activityId && realtionId.startsWith('003')) {
                    
                    ProductofInterest__c PoI = new ProductofInterest__c();
                    Poi.Subject__c = ap.Subject__c;
                    Poi.RepContact__c = tr.RelationId;
                    Poi.FirmBranch__c = tr.AccountId;
                    Poi.ActivityProductId__c = ap.id;
                    Poi.RelationId__c = tr.Id;
                    Poi.Product__c = ap.Product__c;
                    Poi.ActivityId__c = ap.ActivityId__c;
                    Poi.Date__c = ap.Date__c;
                    POI_ToInsert.add(PoI);
                }
                
            }
        }
        
        if (!POI_ToInsert.isEmpty()) insert POI_ToInsert;
    }
    
}