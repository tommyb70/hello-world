global class RollupBatchSched implements Schedulable{
    
    global static String scheduleMe() 
    {
        
        String jobname = !Test.isRunningTest() ? 'Natixis Rollup Batch' : 'Natixis Rollup Batch' + DateTime.now();        
        
        RollupBatchSched SC = new RollupBatchSched(); 
        System.schedule(jobname, '0 0 5-19 * * ?', SC);
        return 'Done';    
    }
    
    global void execute(SchedulableContext SC) {
        
        RollupBatch myRollups = new RollupBatch();
        Database.executeBatch(myRollups);
        
    }
}