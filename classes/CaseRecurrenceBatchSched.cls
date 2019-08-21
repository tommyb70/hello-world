global class CaseRecurrenceBatchSched implements System.Schedulable{
    
    
    global void execute(System.SchedulableContext SC) {
        
        CaseRecurrenceBatch c = new CaseRecurrenceBatch();
        database.executebatch(c,2000);
    }
    
    global static String scheduleMe() 

    {
        CaseRecurrenceBatchSched SC = new CaseRecurrenceBatchSched(); 
 		System.schedule('Case Recurrence Batch', '0 0 0 * * ?', SC);
        return 'Done';    
    }
    
}