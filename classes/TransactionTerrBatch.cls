global class TransactionTerrBatch implements Database.Batchable<sObject>, Database.Stateful{ 
           // This Batch Zones, Tiers and Shares the TransactionTerr__c object 
           public String query; 
           public integer Count = 0; 
           public static Map<id,Channel__c> ChannelMap { 
                get { 
                    if (ChannelMap == null) { 
                         ChannelMap = new Map<id,Channel__c>([Select Id, Name, TierField__c, ZoneField__c, FocusFirmField__c from Channel__c]); 
                    } 
                    return ChannelMap; 
                } 
                set; 
           } 
                
           global Database.querylocator start(Database.BatchableContext BC){ 
                //query = 'select id, contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,
                //contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.PROZoneWHSE__c, 
                //contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, territory__r.Channel__c, 
                //territory__r.RoleGroupId__c from TransactionTerr__c where territory__r.Channel__r.ZoneField__c!=\'\' LIMIT 550000'; 
                return Database.getQueryLocator(query); 
           } 
                
           global void execute(Database.BatchableContext BC, List<TransactionTerr__c> scope){ 
                List<TransactionTerr__c> TransactionTerrsToUpdate = new List<TransactionTerr__c>(); 
                List<TransactionTerr__Share> TransactionTerrShareToInsert = new List<TransactionTerr__Share>(); 
               
                for(TransactionTerr__c cTransactionTerr: scope){ 
                    TransactionTerr__Share ts = new TransactionTerr__Share(AccessLevel='Read',UserOrGroupId=cTransactionTerr.territory__r.RoleGroupId__c,ParentId=cTransactionTerr.id ); 
                    TransactionTerrShareToInsert.add(ts);                     
                    TransactionTerr__c myTT = new TransactionTerr__c(id=cTransactionTerr.id); 
                    //system.debug('Channel__c---------------------' + cTransactionTerr.territory__r.Channel__c ); 
                    //String FieldName = (String)ChannelMap.get(cTransactionTerr.territory__r.Channel__c).ZoneField__c;
                    String FieldName = (cTransactionTerr.territory__c != null && cTransactionTerr.territory__r.Channel__c != null && ChannelMap.containskey(cTransactionTerr.territory__r.Channel__c) &&  ChannelMap.get(cTransactionTerr.territory__r.Channel__c).ZoneField__c != null) ? (String)ChannelMap.get(cTransactionTerr.territory__r.Channel__c).ZoneField__c : null;
                    
                    if (FieldName <> null){ 
                        //system.debug('---------------------' + (id)cTransactionTerr.get(FieldName)); 
                        myTT.RepZone__c = (id)cTransactionTerr.getSObject('Contact__r').get(FieldName); 
                    } 
                   // FieldName = (String)ChannelMap.get(cTransactionTerr.territory__r.Channel__c).TierField__c;  
                    FieldName = (cTransactionTerr.territory__c != null && cTransactionTerr.territory__r.Channel__c != null && ChannelMap.containskey(cTransactionTerr.territory__r.Channel__c) && ChannelMap.get(cTransactionTerr.territory__r.Channel__c).TierField__c != null) ? (String)ChannelMap.get(cTransactionTerr.territory__r.Channel__c).TierField__c : null; 
                    
                    if (FieldName <> null){ 
                        //system.debug('---------------------' + (id)cTransactionTerr.get(FieldName)); 
                        myTT.Tier__c = (String)cTransactionTerr.getSObject('Contact__r').get(FieldName); 
                    } 
                    
                    TransactionTerrsToUpdate.add(myTT); 
                    Count = Count + 1; 
                } 
               
                if (!TransactionTerrsToUpdate.isEmpty()) {if(!test.isrunningtest()){update TransactionTerrsToUpdate;}} 
                if (!TransactionTerrShareToInsert.isEmpty()){if(!test.isrunningtest()){insert TransactionTerrShareToInsert;}}                 
           } 
                
           global void finish(Database.BatchableContext BC){ 
                /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                String[] toAddresses = new String[] {'dat@ngam.natixis.com'}; 
                mail.setToAddresses(toAddresses); 
                mail.setReplyTo('dat@ngam.natixis.com'); 
                mail.setSenderDisplayName('NGAM SFDC'); 
                mail.setSubject('TransactionTerr__c Processed'); 
                mail.setPlainTextBody(Count + ' TransactionTerr__c records were processed'); 
                if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                */ 
           } 
}