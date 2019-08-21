@isTest
public class CaseRecurrenceBatchSchedTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup 
    static void SetupTest() {
        
        NGAMSettings__c settings = new NGAMSettings__c(Name = 'NGAM_ALL', CaseRecurrenceLeadTime__c = 21, CaseRecurrenceToEmail__c = 'dat@natixis.com');
        insert settings;
    }
    
    static testmethod void test() {
        //TestContext.testCase = 'YES';  
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new CaseRecurrenceBatchSched());
        
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

		CaseRecurrenceBatchSched.scheduleMe();
        Test.stopTest();
        
        
    }    

}