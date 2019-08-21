global class CDRMorningstarAPIWSCSched implements Schedulable{
    
    global void execute(SchedulableContext sc) 
    {        
        if (TestContext.TestCase != 'YES') CDRMorningstarAPIWSC.callMorningstarCDR();
    }    

    global static String scheduleMe() 
    {
        CDRMorningstarAPIWSCSched SC = new CDRMorningstarAPIWSCSched(); 
        System.schedule('CDR Morningstar API 1', '0 05 03 * * ?', SC);		
        if (!test.isRunningTest())
        {
            System.schedule('CDR Morningstar API 2', '0 10 03 * * ?', SC);
            System.schedule('CDR Morningstar API 3', '0 15 03 * * ?', SC);
            System.schedule('CDR Morningstar API 4', '0 20 03 * * ?', SC); 
        }        
        
        return 'Done';
        
    }

}