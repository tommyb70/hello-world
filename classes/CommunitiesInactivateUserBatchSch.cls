global class CommunitiesInactivateUserBatchSch implements Schedulable{
    
    global static String scheduleMe() 
    {
        CommunitiesInactivateUserBatchSch SC = new CommunitiesInactivateUserBatchSch();         
        System.schedule('Communities Inactivate User Batch', '0 15 23 * * ?', SC);		
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        CommunitiesInactivateUserBatch b2 = new CommunitiesInactivateUserBatch();
        ID b2id = Database.executeBatch(b2,2000);
    }

    
    

}