global class ApexLoggerCleanupSched implements Schedulable{

    //public static String sched = '0 0 * * * ?';  

    global static String scheduleMe() 
    	{
        ApexLoggerCleanupSched SC = new ApexLoggerCleanupSched(); 
        String sch = '0 0 22 ? * 6';
        System.schedule('Weekly ApexLoggerCleanupSched', sch, SC);	
        return 'Done';    
        }
    global void execute(SchedulableContext sc) {        
        	ApexActivitiesStatsLoggerCleanup b1 = new ApexActivitiesStatsLoggerCleanup();
            ID b1id = Database.executeBatch(b1,2000);
        
    }
}