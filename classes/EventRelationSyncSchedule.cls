global class EventRelationSyncSchedule implements Schedulable{
    
    global static String scheduleMe() 
    {
        
        String jobname1 = !Test.isRunningTest() ? 'Hourly EventRelationSyncSchedule 1' : 'Hourly EventRelationSyncSchedule 1' + Datetime.now();
        String jobname2 = !Test.isRunningTest() ? 'Hourly EventRelationSyncSchedule 2' : 'Hourly EventRelationSyncSchedule 2' + Datetime.now();
        String jobname3 = !Test.isRunningTest() ? 'Hourly EventRelationSyncSchedule 3' : 'Hourly EventRelationSyncSchedule 3' + Datetime.now();
        String jobname4 = !Test.isRunningTest() ? 'Hourly EventRelationSyncSchedule 4' : 'Hourly EventRelationSyncSchedule 4' + Datetime.now();
        
        EventRelationSyncSchedule SC = new EventRelationSyncSchedule(); 
        System.schedule(jobname1, '0 0 * * * ?', SC);
        System.schedule(jobname2, '0 15 * * * ?', SC);
        System.schedule(jobname3, '0 30 * * * ?', SC);
        System.schedule(jobname4, '0 45 * * * ?', SC); 
        
        return 'Done';    
    }
    
    global void execute(SchedulableContext sc) {
        
        // ActivityContact__c rollup (where ActivityContact__c is child)
        EventRelationSyncBatch myevents = new EventRelationSyncBatch();
        Datetime xminutesBack = Datetime.now().addMinutes(-15);
        String formattedDt = xminutesBack.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        myevents.query = ' Select Product__c,Type,id,ActivityType__c,Whoid,WhatId,EventWhoIds,Subject,ActivityDate,OwnerId,recordTypeID, (select id, RelationId,EventId from EventRelations where iswhat=false) from Event Where SystemModStamp >= LAST_N_DAYS:1  AND SystemModStamp >=' + formattedDt ;
        Database.executeBatch(myevents,100);
        
        
    }
}