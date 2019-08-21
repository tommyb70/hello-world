global class UnscheduleHourlyBatchJobs {
    
    global static String UnScheduleMe(){
        
        Set<String> hourlyJobNames = new Set<String>();
        
        hourlyJobNames.add('Hourly TaskFormatingSched 1');
        hourlyJobNames.add('Hourly TaskFormatingSched 2');
        hourlyJobNames.add('Hourly TaskFormatingSched 3');
        hourlyJobNames.add('Hourly TaskFormatingSched 4');
        
        hourlyJobNames.add('Hourly EventRelationSyncSchedule 1');
        hourlyJobNames.add('Hourly EventRelationSyncSchedule 2');
        hourlyJobNames.add('Hourly EventRelationSyncSchedule 3');
        hourlyJobNames.add('Hourly EventRelationSyncSchedule 4');
        hourlyJobNames.add('Hourly EventRelationSyncSchedule TEST'); // Do not remove this or we will lose 100% code coverage for test class
        
        hourlyJobNames.add('Hourly Batch Job Error Notific 1');
        hourlyJobNames.add('Hourly Batch Job Error Notific 2');
        hourlyJobNames.add('Hourly Batch Job Error Notific 3');
        hourlyJobNames.add('Hourly Batch Job Error Notific 4');
        
        hourlyJobNames.add('Communities Reactivate User Batch');
        hourlyJobNames.add('Communities Inactivate User Batch');
        hourlyJobNames.add('Communities Notify New Statements Batch');
        
        hourlyJobNames.add('Case Recurrence Batch');
        
        hourlyJobNames.add('Product Performance Maintenance');
        
        hourlyJobNames.add('CDR Morningstar API 1');
        hourlyJobNames.add('CDR Morningstar API 2');
        hourlyJobNames.add('CDR Morningstar API 3');
        hourlyJobNames.add('CDR Morningstar API 4');
        
        hourlyJobNames.add('Natixis Rollup Batch');

        List<CronJobDetail> hourlyJobIds = new List<CronJobDetail>([SELECT Id from CronJobDetail WHERE Name in : hourlyJobNames]);
        List<CronTrigger> scheduledJobs = new List<CronTrigger>([SELECT Id FROM CronTrigger WHERE CronJobDetailId in : hourlyJobIds]);
        
        for(CronTrigger abortJobs : scheduledJobs) {
            system.abortJob(abortJobs.Id);
        }
        
        return 'Done';
        
    }

}