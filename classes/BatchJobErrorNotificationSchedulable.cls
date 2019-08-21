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

        System.schedule('Hourly Batch Job Error Notific 1', '0 5 * * * ?', SC);
        if (!test.isRunningTest())
        {
            System.schedule('Hourly Batch Job Error Notific 2', '0 20 * * * ?', SC);
            System.schedule('Hourly Batch Job Error Notific 3', '0 35 * * * ?', SC);
            System.schedule('Hourly Batch Job Error Notific 4', '0 50 * * * ?', SC); 
        }
        return 'Done';    
    }
    
}