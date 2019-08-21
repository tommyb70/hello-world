global class TaskFormatingSched implements Schedulable{
    
    //public static String sched = '0 0 * * * ?';  
    
    global static String scheduleMe() 
    {
        TaskFormatingSched SC = new TaskFormatingSched(); 
        //return System.schedule('Hourly TaskFormatingSched', sched, SC);
        System.schedule('Hourly TaskFormatingSched 1', '0 0 8-19 * * ?', SC);
        if (!test.isRunningTest())
        {
            System.schedule('Hourly TaskFormatingSched 2', '0 15 8-19 * * ?', SC);
            System.schedule('Hourly TaskFormatingSched 3', '0 30 8-19 * * ?', SC);
            System.schedule('Hourly TaskFormatingSched 4', '0 45 8-19 * * ?', SC); 
        }
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        
        // Outlook Email Sync
        TaskRelationActContactSynchBatch b1 = new TaskRelationActContactSynchBatch();
        ID b1id = Database.executeBatch(b1,2000);
        
        // ActivityContact__c rollup (where ActivityContact__c is child)
        ActivityContactRollupBatch myACRollups = new ActivityContactRollupBatch();
        Database.executeBatch(myACRollups,100);
        
        // TaskDeleteBatch
        /*TaskDeleteBatch batch = new TaskDeleteBatch();
        ID batchId = database.executeBatch(batch);    */
        
    }
}