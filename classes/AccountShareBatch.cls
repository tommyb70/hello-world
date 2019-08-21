global class AccountShareBatch implements Database.Batchable<sObject>, Database.Stateful{
// This Batch update the Territories with the corresponding role id
   public String query;
   public set<id> GAccountIds = new set<id>();  
   public integer AScount = 0;

    global Database.querylocator start(Database.BatchableContext BC){  
            return Database.getQueryLocator(query);
            }

    global void execute(Database.BatchableContext BC, List<AccountTerritory__c> scope)
            { 
            List<AccountShare> sharesToCreate = new List<AccountShare>(); 
            set<id> AccountIds = new set<id>();   
                
            for (AccountTerritory__c TA: scope)
                {
                if (!GAccountIds.contains(TA.Account__c))  
                    {
                    AccountIds.add(TA.Account__c);    
                    }
                    
                AccountShare cs = new AccountShare();
                cs.AccountAccessLevel = 'Edit';
                cs.OpportunityAccessLevel = 'None';
                cs.ContactAccessLevel = 'None';   
                cs.AccountId = TA.Account__c;
                cs.UserOrGroupId = TA.Territory__r.RoleGroupId__c  ;
                sharesToCreate.add(cs);  
                
                //AccountShare cs2 = new AccountShare();
                //cs2.AccountAccessLevel = 'Edit';
                //cs2.OpportunityAccessLevel = 'None';
                //cs2.ContactAccessLevel = 'None';   
                //cs2.AccountId = TA.Account__c;
                //cs2.UserOrGroupId = TA.GroupId__c;
                //sharesToCreate.add(cs2);  
                
                AScount = AScount + 1;
                GAccountIds.add(TA.Account__c);    
                } 
                
            
            // 8/1/2015 Addition to rollup the Territory List to the Account Record
            List<AccountTerritory__c> ACs = [select Account__c from AccountTerritory__c where Id in :scope];
            List<SObject> parents = (List<SObject>) dlrs.RollupService.rollup(ACs);
            update parents;  
                
            List<AccountShare> sharesToDelete = new List<AccountShare>([select id from AccountShare where Rowcause='Manual' and accountid in: AccountIds]);    
              
            if (!sharesToDelete.isEmpty())
                {   
                delete sharesToDelete;
                }   
                
            if (!sharesToCreate.isEmpty())
                {   
                insert sharesToCreate;
                }                   
            }
    
    global void finish(Database.BatchableContext BC)
            {
                
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('DAT');
            mail.setSubject('Accountshare computation Completed');
            mail.setPlainTextBody('Batch Process has completed and ' + ASCount + ' Accountshare were created');
            //mail.setPlainTextBody('All Good !');
           if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        */        
                
            }
 
}