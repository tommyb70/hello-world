global class CommunitiesNotifyNewStateBatchSch implements Schedulable {
    
    global static String scheduleMe() 
    {
        CommunitiesNotifyNewStateBatchSch SC = new CommunitiesNotifyNewStateBatchSch();         
        System.schedule('Communities Notify New Statements Batch', '0 30 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesNotifyNewStatementsBatch b2 = new CommunitiesNotifyNewStatementsBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }
}