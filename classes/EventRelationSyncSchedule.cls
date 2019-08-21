global class EventRelationSyncSchedule implements Schedulable{
    
     global static String scheduleMe() 
        {
        EventRelationSyncSchedule SC = new EventRelationSyncSchedule(); 
        //return System.schedule('Hourly TaskFormatingSched', sched, SC);
        System.schedule('Hourly EventRelationSyncSchedule 1', '0 0 * * * ?', SC);
        if (!test.isRunningTest())
            {
            System.schedule('Hourly EventRelationSyncSchedule 2', '0 15 * * * ?', SC);
            System.schedule('Hourly EventRelationSyncSchedule 3', '0 30 * * * ?', SC);
            System.schedule('Hourly EventRelationSyncSchedule 4', '0 45 * * * ?', SC); 
            }
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