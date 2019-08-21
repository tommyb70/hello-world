@isTest
private class BusinessDaysSched_Test  {
    
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void BusinessDaysSchedTesting() 
   		{
      	Test.startTest();
        String jobId = System.schedule('BusinessDaysSched_Test', CRON_EXP, new BusinessDaysSched());
      	Test.stopTest();
   		}
}