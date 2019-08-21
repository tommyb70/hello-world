global class MassTaskUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    // This Batch job synchs up TaskRelation and ActivityContact__c
    Public integer Count = 0;
    Public String query = '';
    //Public String query = 'select id from Task where ActivityDateProxy__c >= 2015-01-01 and ActivityDateProxy__c <= TODAY';
    
    global MassTaskUpdateBatch() {
        System.Debug('Dummy Udpate of Activities');
    }
 
   global Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator(query);
   }
 
   global void execute(Database.BatchableContext BC, List<Task> scope) {
       
       set<id> ActivityIds = new set<id>();
       
       for (Task tsk : scope)
            {
            ActivityIds.add(tsk.id);   
            }   
       
        List<Task> TaskToUdpate = new List<Task>();
       
        for (Task cTask : scope)
            {    
            TaskToUdpate.add(new Task(id=cTask.Id, DTFlag__c=true));
            Count = Count + 1;
            }
       
        if ( TaskToUdpate.size()>0)
            {
            update TaskToUdpate;
            }     

   }
 
   global void finish(Database.BatchableContext BC) {
       /*try
       {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC');
            mail.setSubject('TaskRelation to ActivityContact__c Synching for Outlook Emails');
            mail.setHTMLBody(Count + ' Email Activities were Processed<br/>Query: ' + query +'<br/>Batch Name: TaskRelationActContactSynchBatch');
            if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
       }
         catch (Exception e) {
           System.debug('Exception: ' + e);            
           } */    
   }


    
}