global class CommunitiesInactivateUserBatchSch implements Schedulable{
    
    global static String scheduleMe() 
    {
        
        String jobname = !Test.isRunningTest() ? 'Communities Inactivate User Batch' : 'Communities Inactivate User Batch' + DateTime.now();        
        
        CommunitiesInactivateUserBatchSch SC = new CommunitiesInactivateUserBatchSch();         
        System.schedule(jobname, '0 15 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesInactivateUserBatch b2 = new CommunitiesInactivateUserBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }

    
    

}