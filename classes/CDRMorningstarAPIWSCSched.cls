global class CDRMorningstarAPIWSCSched implements Schedulable{
    
    global void execute(SchedulableContext sc) {        
        if (TestContext.TestCase != 'YES') CDRMorningstarAPIWSC.callMorningstarCDR();
    }    
    
    global static String scheduleMe() {
        String jobname1 = !Test.isRunningTest() ? 'CDR Morningstar API 1' : 'CDR Morningstar API 1' + Datetime.now();
        String jobname2 = !Test.isRunningTest() ? 'CDR Morningstar API 2' : 'CDR Morningstar API 2' + Datetime.now();
        String jobname3 = !Test.isRunningTest() ? 'CDR Morningstar API 3' : 'CDR Morningstar API 3' + Datetime.now();
        String jobname4 = !Test.isRunningTest() ? 'CDR Morningstar API 4' : 'CDR Morningstar API 4' + Datetime.now();
        
        CDRMorningstarAPIWSCSched SC = new CDRMorningstarAPIWSCSched(); 
        System.schedule(jobname1, '0 05 03 * * ?', SC);		
        System.schedule(jobname2, '0 10 03 * * ?', SC);
        System.schedule(jobname3, '0 15 03 * * ?', SC);
        System.schedule(jobname4, '0 20 03 * * ?', SC); 
        
        return 'Done';
        
    }
    
}