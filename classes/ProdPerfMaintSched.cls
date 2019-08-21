global class ProdPerfMaintSched implements System.Schedulable{
    
    
    global void execute(System.SchedulableContext SC) {
        
        ProdPerfMaintRollupBatch pp = new ProdPerfMaintRollupBatch();
        database.executebatch(pp);
    }
    
    global static String scheduleMe() 

    {
        ProdPerfMaintSched SC = new ProdPerfMaintSched(); 
        System.schedule('Product Performance Maintenance', '0 0 5 * * ?', SC);
        return 'Done';    
    }
    
}