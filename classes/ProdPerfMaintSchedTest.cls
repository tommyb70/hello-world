@isTest
public class ProdPerfMaintSchedTest {

    @testSetup 
    static void SetupTest() {
        
        Date ppAsOfDate = Date.newInstance(2017,9,18);
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     BusinessHoursName__c = '24 Hours, Monday - Friday GMT', 
                                                     ProdPerfMaintDeleteBatchFromDate__c = ppAsOfDate, 
                                                     ProdPerfBatchLASTNDAYS__c = '1');                                                     
        insert settings;
        
        String BHName = settings.BusinessHoursName__c;
        
        businessHours bh = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, 
                            WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, 
                            SaturdayStartTime, SundayEndTime, SundayStartTime 
                            FROM BusinessHours WHERE Name = :BHName LIMIT 1];
        
        List<Holiday> holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday];

    }  
    
    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testmethod void test() {
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new ProdPerfMaintSched());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime));

		ProdPerfMaintSched.scheduleMe();
        Test.stopTest();
        
    }    
    
    
    
}