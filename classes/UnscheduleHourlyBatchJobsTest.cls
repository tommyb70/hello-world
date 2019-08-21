@isTest
private class UnscheduleHourlyBatchJobsTest {
    
    static testmethod void UnscheduleHourlyBatchJobsTest() {       

        Id jobid = System.schedule('Hourly EventRelationSyncSchedule TEST', '0 0 0 * * ?', new TaskFormatingSched());
        
        Test.startTest();
        UnscheduleHourlyBatchJobs.UnscheduleMe();
        Test.stopTest();

    }
    
}