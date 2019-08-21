global class MassEmailBatch implements Database.Batchable<sObject>, Database.Stateful{

    Public String query = 'select id from Task where Id = null';
    
    global MassEmailBatch() {
        System.Debug('MassEmailBatch');
    }
    
 
   global Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator(query);
   }
 
   global void execute(Database.BatchableContext BC, List<Task> scope) {
       
/*      List<Task> TasksToUpdate = new List<Task>();
       
      for (Task tsk : scope)
            {
			TasksToUpdate.add(new Task(id=tsk.id,Type = 'Mass Email',Description=tsk.Subject,Subject = 'Mass Email', ActivitySource__c = 'SFDC Mass Email'));
            }  
       
        if (TasksToUpdate.size()>0)
        	{
            // This is to Perform the Before Update / After Update
        	update TasksToUpdate;
            } 
       
       // This is to Insert ONE ActivityContact__c record
       If (!test.isRunningTest())
       {
       	TaskTriggerHandler.TaskTriggerAfterInsert(scope);
       }*/
   }
 
   global void finish(Database.BatchableContext BC) {
       /*try 
       {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC');
            mail.setSubject('MassEmailBatch');
            String EmailBody =   'SOQL='+ query + ' <br/>'; 
            mail.setHTMLBody(EmailBody);
            System.Debug('EmailBody '  + EmailBody);             
            if (!Test.IsRunningTest())  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
       }
      catch (Exception e) {
           System.debug('Exception: ' + e);            
           }     */
   }


    
}