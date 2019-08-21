global class CommunitiesScheduleJob implements Schedulable{

    global static String scheduleMe() 
    	{
        CommunitiesScheduleJob SC = new CommunitiesScheduleJob();         
        System.schedule('CommunitiesScheduleJob', '0 0 23 * * ?', SC);		
        return 'Done';    
    	}

    global void execute(SchedulableContext sc) {
               	        
        // inactivate the users
            CommunitiesInactivateUserBatch b3 = new CommunitiesInactivateUserBatch();
            ID b3id = Database.executeBatch(b3,2000);

        // reactivate the users
            CommunitiesReactivateUserBatch b1 = new CommunitiesReactivateUserBatch();
            ID b1id = Database.executeBatch(b1,2000);
        
        // send email to FA
            CommunitiesNotifyNewStatementsBatch b2 = new CommunitiesNotifyNewStatementsBatch();
            ID b2id = Database.executeBatch(b2,2000);
    }
}