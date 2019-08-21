Global class ApexActivitiesStatsLoggerCleanup implements Database.Batchable<sObject>, Database.Stateful{
    String query='Select Id from ApexActivitiesStatsLog__c where CreatedDate < LAST_N_DAYS:180';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
   }
    
  global void execute(Database.BatchableContext BC, List<ApexActivitiesStatsLog__c> scope) {     
    List<Database.DeleteResult> results = Database.delete(scope);
 if(results != null)
      {
           for (Database.DeleteResult r: results)
           {
            System.debug( r);
           }
       }
  }
    
   global void finish(Database.BatchableContext BC) {
   }

 public static void CleanupLoggger(Integer OldersThanMonths){
       // to check the governece limits
     if(OldersThanMonths<= 0)return;
     Integer months = -1*OldersThanMonths;
     date d = system.today().addMonths(months);
    String query ='Select Id from ApexActivitiesStatsLog__c where CreatedDate <=' + d;
    for (List<ApexActivitiesStatsLog__c> logs: [Select Id from ApexActivitiesStatsLog__c where CreatedDate <=:d ])
            {
              try{
                DELETE logs;
            }
            catch (Exception ex) { System.debug('Failed to INSERT the ApexActivitiesStatsLog__c record. ' + 'Error: ' + ex.getMessage()
                );
            }  
            }
 }
}