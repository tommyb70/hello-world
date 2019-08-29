global class CommunitiesReactivateUserBatchSch implements Schedulable{
    
    global static String scheduleMe() 
    {
        CommunitiesReactivateUserBatchSch SC = new CommunitiesReactivateUserBatchSch();   

        String jobname = !Test.isRunningTest() ? 'Communities Reactivate User Batch' : 'Communities Reactivate User Batch' + DateTime.now();
        
        System.schedule(jobname, '0 0 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesReactivateUserBatch b2 = new CommunitiesReactivateUserBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }

    
    

}