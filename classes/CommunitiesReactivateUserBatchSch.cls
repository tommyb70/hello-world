global class CommunitiesReactivateUserBatchSch implements Schedulable{
    
    global static String scheduleMe() 
    {
        CommunitiesReactivateUserBatchSch SC = new CommunitiesReactivateUserBatchSch();         
        System.schedule('Communities Reactivate User Batch', '0 0 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesReactivateUserBatch b2 = new CommunitiesReactivateUserBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }

    
    

}