global class ActivityContactRollupBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    //public String query = ' select Id, Type__c, Contact__c, Account__c, Case__c, Lastmodifieddate, Date__c from ActivityContact__c where SystemModStamp >= LAST_N_DAYS:1 order by Account__c, Contact__c'; 
    
    global Database.querylocator start(Database.BatchableContext BC){  
        NGAMSettings__c NamRecord =[select id,ActivityContactRollupBatchFromDate__c,ActivityContactRollupBatchToDate__c  from NGAMSettings__c  limit 1];
        Datetime fromDate = NamRecord.ActivityContactRollupBatchFromDate__c != null ? NamRecord.ActivityContactRollupBatchFromDate__c : system.today().adddays(-1);
        Datetime toDate = NamRecord.ActivityContactRollupBatchToDate__c != null ? NamRecord.ActivityContactRollupBatchToDate__c : system.today().adddays(1);
        
        NamRecord.ActivityContactRollupBatchFromDate__c  = system.now();
        update NamRecord;
        return Database.getQueryLocator([select Id, 
                                         Type__c, 
                                         Contact__c, 
                                         Account__c, 
                                         Case__c, 
                                         Lastmodifieddate,
                                         Date__c from ActivityContact__c 
                                         where SystemModStamp >=:fromDate and SystemModStamp <=:toDate
                                         order by Account__c, Contact__c]); 
    } 
    
    global void execute(Database.BatchableContext BC, List<ActivityContact__c> scope) { 
        
        List<ActivityContact__C> ACs = [select id, type__c, contact__c, case__c, account__c from ActivityContact__C where id in: scope];
        
        //List<SObject> parents = (List<SObject>) dlrs.RollupService.rollup(ACs);
        List<SObject> parents = new List<SObject>();
        Map<Id,SObject> distinctParents = new Map<Id,SObject>();
        
        for (SObject s : parents) {
            distinctParents.put(s.Id,s);
        }
        
        update distinctParents.values(); 
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        NGAMSettings__c NamRecord =[select id,
                                    ActivityContactRollupBatchFromDate__c,
                                    FailureNotificationEmailAddress__c,
                                    ActivityContactRollupBatchToDate__c  from NGAMSettings__c  limit 1];
        NamRecord.ActivityContactRollupBatchToDate__c = null;
        update NamRecord;
        
        AsyncApexJob a = [Select Id, 
                          Status,
                          ExtendedStatus,
                          NumberOfErrors,     
                          JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {NamRecord.FailureNotificationEmailAddress__c};
        mail.setToAddresses(toAddresses);
        mail.setSubject('ActivityContactRollupBatch ' + a.Status);
        mail.setHtmlBody('Hi Team,<br/>Records processed ' + a.TotalJobItems +
                         ' with '+ a.NumberOfErrors + ' failures. <br/><br/> Start Date: '+NamRecord.ActivityContactRollupBatchFromDate__c+'.<br/>' +
                         'Update Custom Setting Activity Contact Rollup Batch From Date with the above Start Date and run another batch from the Dev Console with the following command: <br/>' + 
                         '  Id batchJobId = Database.executeBatch(new ActivityContactRollupBatch(), 100); <br/><br/>' +
                         'If the job fails again, use the Custom Setting Activity Contact Rollup Batch To Date (and Start Date) to limit the number of batches in the run.');
        if(a.NumberOfErrors  > 0){
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }    
}