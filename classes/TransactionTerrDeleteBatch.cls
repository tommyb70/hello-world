global class TransactionTerrDeleteBatch implements Database.Batchable<sObject>{
    
   public String query; 
    
   global TransactionTerrDeleteBatch() {
     System.Debug('Deleting TransactionTerr');
   }
 
   global Database.QueryLocator start(Database.BatchableContext BC) {
     return Database.getQueryLocator(query);
   }
 
   global void execute(Database.BatchableContext BC, List<sObject> scope) {
     delete scope;
   }
 
   global void finish(Database.BatchableContext BC) {
           /* Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC');
            mail.setSubject('TransactionTerr__c Processed');
            mail.setPlainTextBody('All TransactionTerr__c Records are deleted ');
             if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); */
   }
 
}