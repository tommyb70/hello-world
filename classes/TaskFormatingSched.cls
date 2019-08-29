global class TaskFormatingSched implements Schedulable{
    
    global static String scheduleMe() {
        
        String jobname1 = !Test.isRunningTest() ? 'Hourly TaskFormatingSched 1' : 'Hourly TaskFormatingSched 1' + Datetime.now();
        String jobname2 = !Test.isRunningTest() ? 'Hourly TaskFormatingSched 2' : 'Hourly TaskFormatingSched 2' + Datetime.now();
        String jobname3 = !Test.isRunningTest() ? 'Hourly TaskFormatingSched 3' : 'Hourly TaskFormatingSched 3' + Datetime.now();
        String jobname4 = !Test.isRunningTest() ? 'Hourly TaskFormatingSched 4' : 'Hourly TaskFormatingSched 4' + Datetime.now();
        
        TaskFormatingSched SC = new TaskFormatingSched(); 
        System.schedule(jobname1, '0 0 8-19 * * ?', SC);
        System.schedule(jobname2, '0 15 8-19 * * ?', SC);
        System.schedule(jobname3, '0 30 8-19 * * ?', SC);
        System.schedule(jobname4, '0 45 8-19 * * ?', SC); 
        
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        
        // Outlook Email Sync
        TaskRelationActContactSynchBatch b1 = new TaskRelationActContactSynchBatch();
        ID b1id = Database.executeBatch(b1,2000);
        
        // ActivityContact__c rollup (where ActivityContact__c is child)
        ActivityContactRollupBatch myACRollups = new ActivityContactRollupBatch();
        Database.executeBatch(myACRollups,100);
        
    }
}