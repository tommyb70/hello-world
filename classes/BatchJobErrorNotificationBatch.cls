global class BatchJobErrorNotificationBatch implements Database.batchable<sObject>{
    
    global final String query;
    
    global BatchJobErrorNotificationBatch(String q){
        query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<AsyncApexJob> scope){
        String PlainTextBody = 'The following apex batch job(s) have failed or have at least one error batch: ';
        String Subject = 'Apex Scheduled Job Batch Errors';
        Set<Id> apexClassIds = new Set<Id>();
        
        Organization SandboxOrg = [Select IsSandbox from Organization limit 1];
        
        If (SandboxOrg.IsSandbox || Test.isRunningTest()) {
            Subject = 'Sandbox: Apex Scheduled Job Batch Errors';
        }
        
        for (AsyncApexJob aaj : scope) {
            apexClassIds.add(aaj.ApexClassID);
        }
        
        Map<Id,String> apexClassNamesMap = new Map<Id,String>();
        List<ApexClass> apexClassNamesList = new List<ApexClass>([SELECT Id,Name FROM ApexClass WHERE Id in : apexClassIds]);
        for (ApexClass acnl: apexClassNamesList) {
            apexClassNamesMap.put(acnl.Id,acnl.Name);    
        }
        
        for (AsyncApexJob aaje : scope) {
            PlainTextBody += '\r\n';
            PlainTextBody += '\r\n';
            PlainTextBody += apexClassNamesMap.get(aaje.ApexClassId) + '\r\n';
            PlainTextBody += 'The job processed ' + aaje.TotalJobItems + ' batches with ' + aaje.NumberOfErrors + ' failures.' + '\r\n';
            PlainTextBody += 'The first error encountered was: ' + aaje.ExtendedStatus;
        }
        
        // Send an email 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject(Subject);
        mail.setPlainTextBody(PlainTextBody);
        if(!Test.isRunningTest()) {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }     
    global void finish(Database.BatchableContext BC){

        AsyncApexJob a = [SELECT Id, CompletedDate
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];

        List<NGAMSettings__c> cs = NGAMSettings__c.getall().values();
        cs[0].LastBatchJobErrorNotificationCompletion__c = a.CompletedDate;
        update cs;
    }
    
}