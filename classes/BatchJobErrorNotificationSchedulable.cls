global class BatchJobErrorNotificationSchedulable implements System.Schedulable {
    
    global void execute(System.SchedulableContext SC) {
        
        Datetime LastCompletionDTTM = Datetime.now();
        String query;
        
        List<NGAMSettings__c> cs = NGAMSettings__c.getall().values();
        if (cs[0].LastBatchJobErrorNotificationCompletion__c != null) {
            LastCompletionDTTM = cs[0].LastBatchJobErrorNotificationCompletion__c;
        } 
        
        String GMTDateTime = LastCompletionDTTM.format('yyyy-MM-dd HH:mm:ss','GMT');
        String formattedGMTDateTime = GMTDateTime.left(10) + 'T' + GMTDateTime.right(8)+'Z';
        
        query = 'SELECT ApexClassId, TotalJobItems, CompletedDate, ExtendedStatus, JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status ';
        query += 'FROM AsyncApexJob ';
        query += 'WHERE (Status = \'Failed\' ';
        query += 'OR NumberOfErrors > 0) ';
        query += 'AND CompletedDate >= ' + formattedGMTDateTime;
        
        system.debug('query: ' + query);
        
        BatchJobErrorNotificationBatch bjnb = new BatchJobErrorNotificationBatch(query);
        database.executebatch(bjnb);
    }
    
    global static String scheduleMe() 
    {
        BatchJobErrorNotificationSchedulable SC = new BatchJobErrorNotificationSchedulable(); 
        
        String jobname1 = !Test.isRunningTest() ? 'Hourly Batch Job Error Notific 1' : 'Hourly Batch Job Error Notific 1' + Datetime.now();
        String jobname2 = !Test.isRunningTest() ? 'Hourly Batch Job Error Notific 2' : 'Hourly Batch Job Error Notific 2' + Datetime.now();
        String jobname3 = !Test.isRunningTest() ? 'Hourly Batch Job Error Notific 3' : 'Hourly Batch Job Error Notific 3' + Datetime.now();
        String jobname4 = !Test.isRunningTest() ? 'Hourly Batch Job Error Notific 4' : 'Hourly Batch Job Error Notific 4' + Datetime.now();
        
        System.schedule(jobname1, '0 5 * * * ?', SC);
        System.schedule(jobname2, '0 20 * * * ?', SC);
        System.schedule(jobname3, '0 35 * * * ?', SC);
        System.schedule(jobname4, '0 50 * * * ?', SC); 
        
        return 'Done';    
    }
    
}