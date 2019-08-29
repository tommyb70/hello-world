global class CommunitiesNotifyNewStateBatchSch implements Schedulable {
    
    global static String scheduleMe() 
    {
        
        String jobname = !Test.isRunningTest() ? 'Communities Notify New Statements Batch' : 'Communities Notify New Statements Batch' + DateTime.now();
        
        CommunitiesNotifyNewStateBatchSch SC = new CommunitiesNotifyNewStateBatchSch();         
        System.schedule(jobname, '0 30 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesNotifyNewStatementsBatch b2 = new CommunitiesNotifyNewStatementsBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }
}