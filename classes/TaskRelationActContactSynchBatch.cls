global class TaskRelationActContactSynchBatch implements Database.Batchable<sObject>, Database.Stateful{
    
// 20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
/*     
    // This Batch job synchs up TaskRelation and ActivityContact__c
    Public integer Count = 0;
    // Get Query from Custom setting
     static NGAMSettings__c TaskRelationOutlookSyncQuery = NGAMSettings__c.getValues('NGAM_ALL');
     Public string whereCreteria =  '';// TaskRelationOutlookSyncQuery.TaskRelationOutlookSyncQuery__c;
     public String query = 'select id, (select id, RelationId, TaskId from TaskRelations where iswhat=false) from Task ';
    
     Public String msg = '';
     
    public Map<String, List<String>> m = new Map<String,  List<String>>();
    
    global TaskRelationActContactSynchBatch() {
        System.Debug('TaskRelation to ActivityContact__c Synching for Outlook Emails');
        if (!Test.IsRunningTest()) whereCreteria = TaskRelationOutlookSyncQuery.TaskRelationOutlookSyncQuery__c;
      
    }*/

   global Database.QueryLocator start(Database.BatchableContext BC) {
/* 20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent
       if( String.isBlank(whereCreteria))  // if query is blank in cutom settings
      {
         System.Debug('TaskRelation to ActivityContact__c Synching for Outlook Emails - Custom setting Blank, using default Query' + query);
        query = 'select id, (select id, RelationId, TaskId from TaskRelations where iswhat=false) from Task where (Type like \'%Email%\' or Type like \'%Seismic LiveSend%\') and LastModifiedDate >= LAST_N_DAYS:5 and owner.isactive = true and whocount>0 and CreatedDate >= 2015-01-01T00:00:00.000Z and LastModifiedBy.alias != \'inatixis\' and ActivitySource__c = null LIMIT 2000';
         System.Debug('TaskRelation to ActivityContact__c Synching for Outlook Emails - Custom setting Blank, using default Query' + query);
      }
        else
        {
         System.Debug('TaskRelation to ActivityContact__c Synching for Outlook Emails and Seismic - Using Query');
            query = query + ' where LastModifiedDate >= LAST_N_DAYS:5 and owner.isactive = true and whocount>0 and CreatedDate >= 2015-01-01T00:00:00.000Z and LastModifiedBy.alias != \'inatixis\' and ';
            query = query + ' ' + whereCreteria;
            query = query + ' ' + 'LIMIT 200';
         System.Debug('Query - ' + query);
        }*/
		String query = 'select id FROM Task WHERE Id = null';
       return Database.getQueryLocator(query);
   }
 
    global void execute(Database.BatchableContext BC, List<Task> scope) {
/* 20190707 - No Longer Need this since using trigger on TaskRelationChangeEvent*/
        
        String deleteThis = 'YES';
/*
        List<String> temp = new List<String>();
     
       set<id> ActivityIds = new set<id>();
       set<id> ContactIds = new set<id>();
       
       for (Task tsk : scope)
            {
            ActivityIds.add(tsk.id); 
            temp.Add(tsk.id );
            } 
       // Create msg to add in the email
        msg = 'Activity Ids Count ' +  ActivityIds.size();
        m.put('Task-Activity Ids' , temp );  
        
        List<Task> TaskToUdpate = new List<Task>();       
        List<ActivityContact__c> newRElatedAC = new List<ActivityContact__c>();
       
        for (Task cTask : scope)
            {    
            for (TaskRelation cTr : cTask.TaskRelations) 
                {
                ActivityContact__c ac = new ActivityContact__c();
                ac.ActivityId__c = cTask.Id;     
                ac.Contact__c = (id)cTr.RelationId; 
                    system.debug('Adding AC for Contact: ' + ac.Contact__c);
                ContactIds.add(ac.Contact__c);
                newRElatedAC.add(ac); 
                Count = Count + 1;
                }
            TaskToUdpate.add(new Task(id=cTask.Id, ActivitySource__c='Outlook Integration'));
            }
        
        List<ActivityContact__c> ActivityContactsToDelete = [select id from ActivityContact__c where ActivityId__c in: ActivityIds]; 
       // Create msg to add in the email
         msg = msg + '   ActivityContactsToDelete Count : ' + ActivityContactsToDelete.size();
         List<String> ActivityContactsToDeleteList = new List<String>();
         for(ActivityContact__c ac: ActivityContactsToDelete){
             ActivityContactsToDeleteList.add(ac.Id);
         }
        m.put('ActivityContacts - Delete - ActivityContact Ids' , ActivityContactsToDeleteList );  
       
         
        if (ActivityContactsToDelete.size()>0)
            {
            delete ActivityContactsToDelete;
            }
       
       List<TaskRelation> TRToDelete = [select id from TaskRelation where TaskId in: ActivityIds];
       // Create msg to add in the email
         msg = msg + '   TRToDelete Count:  ' + TRToDelete.size() ;
        List<String> TRToDeleteList = new List<String>();
         for(TaskRelation tr: TRToDelete){
             TRToDeleteList.add(tr.Id);
         }
        m.put('TaskRelation - Delete -  TaskRelation Ids' , TRToDeleteList );  
       
       if (TRToDelete.size()>0)
            {
            delete TRToDelete;
            }
          
       // Create msg to add in the email
        msg = msg + '   newRElatedAC Count: ' + newRElatedAC.size();
        List<String> newRElatedACList = new List<String>();
         for(ActivityContact__c ac: newRElatedAC){
             newRElatedACList.add(ac.ActivityId__c);
         }
        m.put('Contact Activity - Create - Activity Ids' , newRElatedACList );  
       
        if (newRElatedAC.size()>0)
            {
            insert newRElatedAC;
            ActivityContactTriggerHandler.rollupCId(ContactIds);
            }     
       
       // Create msg to add in the email
         msg = msg + '   TaskToUdpate Count ' + TaskToUdpate.size();
         List<String> TaskToUdpateList = new List<String>();
         for(Task t: TaskToUdpate){
             TaskToUdpateList.add(t.Id);
         }
        m.put('Task - Update Activity Source - Activity Ids' , TaskToUdpateList );
       
        if ( TaskToUdpate.size()>0)
            {
            update TaskToUdpate;
            }     */
   }
 
   global void finish(Database.BatchableContext BC) {
       String deleteThis = 'YES';
//20190707   try{
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC');
            mail.setSubject('TaskRelation to ActivityContact__c Synching for Outlook Emails');*/
           
          
/*20190707             System.debug('query : ' + query );
           // System.debug('mail : ' + mail );
           // String body = Count + ' Email Activities were Processed<br/>Query: ' + query +'<br/>Batch Name: TaskRelationActContactSynchBatch <br/>' + msg + '<br/>';
          
            string Temp = '';
          for(String id: m.keyset()){
                   List<String> stringset= m.get(id);
               System.debug('id : ' + id );
                Temp = '<br/><table  border= "1" >';
                Temp = Temp + '<tr><th  >' + id + '</th><th> Count = '  + stringset.size() + '</th><tr>';
                  for(String a: stringset){
                      Temp = temp + '<tr  ><td>' +a + '</tr></td>';
                  }
              Temp = Temp + '</table><br/>';
             // body = body + Temp;
          }             
          //  mail.setHTMLBody(body);   
        String AdditionalCounts = '';
       for(String id: m.keyset()){
                   List<String> stringset= m.get(id);
               System.debug('id : ' + id );
               
                Temp =  'Object ' + id + ' Count = '  + stringset.size() ;
                  for(String a: stringset){
                      Temp = temp + ' ' +a + '\n\r';
                  }
             
              AdditionalCounts = AdditionalCounts + Temp;
          }     
       
       String Msg = Count + ' Email Activities were Processed';       
       ApexActivitiesStatsLogger.logMessage('TaskRelationActContactSynchBatch', 'TaskRelationActContactSynchBatch', Msg, query, AdditionalCounts, 'Task,ActivityContact__c,TaskRelations');
       
           // if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }  catch (Exception e) {
           System.debug('TaskRelationActContactSynchBatch - Exception: ' + e);            
           }   */     
   } 


    
}