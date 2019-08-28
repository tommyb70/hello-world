global class ProdPerfMaintSched implements System.Schedulable{
    
    
    global void execute(System.SchedulableContext SC) {
        
        ProdPerfMaintRollupBatch pp = new ProdPerfMaintRollupBatch();
        database.executebatch(pp);
    }
    
    global static String scheduleMe() 

    {
        String jobname = !Test.isRunningTest() ? 'Product Performance Maintenance' : 'Product Performance Maintenance' + DateTime.now();
        
        ProdPerfMaintSched SC = new ProdPerfMaintSched(); 
        System.schedule(jobname, '0 0 5 * * ?', SC);
        return 'Done';    
    }
    
}