global class CaseRecurrenceBatchSched implements System.Schedulable{
    
    
    global void execute(System.SchedulableContext SC) {
        
        CaseRecurrenceBatch c = new CaseRecurrenceBatch();
        database.executebatch(c,2000);
    }
    
    global static String scheduleMe() 

    {
        
        String jobname = !Test.isRunningTest() ? 'Case Recurrence Batch' : 'Case Recurrence Batch' + DateTime.now();        
        
        CaseRecurrenceBatchSched SC = new CaseRecurrenceBatchSched(); 
 		System.schedule(jobname, '0 0 0 * * ?', SC);
        return 'Done';    
    }
    
}