global class RollupBatchSched implements Schedulable{
    
    global static String scheduleMe() 
    {
        RollupBatchSched SC = new RollupBatchSched(); 
        System.schedule('Natixis Rollup Batch', '0 0 5-19 * * ?', SC);
        return 'Done';    
    }
    
    global void execute(SchedulableContext SC) {
        
        RollupBatch myRollups = new RollupBatch();
        Database.executeBatch(myRollups);
        
    }
}