public class ApexActivitiesStatsLogger {
    
    public static void logMessage(String ClassName, String MethodName, STring Message, String QueryBatchJob, String AdditionalStats, String ObjectName){
       // to check the governece limits
                   System.debug('Limits.getDMLRows() ' + Limits.getDMLRows());
                     System.debug('Limits.getLimitDMLRows() ' + Limits.getLimitDMLRows());
        System.debug('Limits.getDMLStatements()  ' + Limits.getDMLStatements() );
                     System.debug('Limits.getLimitDMLStatements()  ' + Limits.getLimitDMLStatements() );
        if (  
            (Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
            (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
        ){           
            ApexActivitiesStatsLog__c newMsg =
                new ApexActivitiesStatsLog__c(
                   ClassName__c = ClassName,
                    MethodName__c = MethodName,
                   Message__c = Message, 
                    QueryBatchJob__c = QueryBatchJob,
                    AdditionalStats__c = AdditionalStats,
                    ObjectName__c = ObjectName                    
                );
        
        
            try{
                System.debug( 'insert new message ' + newMsg.ClassName__c);
                  Database.SaveResult results = Database.insert(newMsg, false);
                if(results != null)
                {
                  System.debug(  results.isSuccess());
                }
            }
            catch (Exception ex){
                System.debug(
                    'Failed to INSERT the ApexActivitiesStatsLog__c record. ' +
                    'Error: ' + ex.getMessage()
                );
            }
        }
       else {
            System.debug(
                'Failed to INSERT the ApexActivitiesStatsLog__c record. ' +
                'Error: The APEX RUNTIME GOVERNOR LIMITS has been reached.'
            );
        }
    }
}