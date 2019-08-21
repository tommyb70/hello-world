global class DictionaryItemObjectBatch implements Database.batchable<sObject>, Database.Stateful{
    
    global final Id objectRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
    global final String query;
    global Set<String> schemaObjects = new Set<String>();
    
    global DictionaryItemObjectBatch(){
        query='SELECT Id, APIName__c FROM DictionaryItem__c WHERE RecordTypeId =: objectRecordTypeId';
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DictionaryItem__c> scope){
        
        List<DictionaryItem__c> objectsToUpsert = new List<DictionaryItem__c>();
        List<DictionaryItem__c> objectsToDelete = new List<DictionaryItem__c>();
        Set<String> stdObjects = new Set<String>();
        
        for (DictionaryItemStandardObject__mdt so : [SELECT APIName__c
                                                     FROM DictionaryItemStandardObject__mdt                                                    ]) {
                                                         stdObjects.add(so.APIName__c);
                                                     }
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        List<String> objectNames = new List<String>();
        
        if (!Test.isRunningTest()) {
        	objectNames = new List<String>(globalDescribe.keySet());
        } else {
            objectNames.add('Account');
        }
        
        List<Schema.DescribeSObjectResult> objectDescribeResultList = Schema.describeSObjects(objectNames);
        
        for (Schema.DescribeSObjectResult sr : objectDescribeResultList) {
            
            if (stdObjects.contains(sr.getName()) || sr.isCustom()) {
                schemaObjects.add(sr.getName());
                objectsToUpsert.add(new DictionaryItem__c(RecordTypeId = objectRecordTypeId,
                                                          APIName__c = sr.getName(),
                                                          Label__c = sr.getLabel(),
                                                          PluralLabel__c = sr.getLabelPlural(),
                                                          KeyPrefix__c = sr.getKeyPrefix(),
                                                          Custom__c = sr.isCustom(),
                                                          MetadataIdentifier__c = 'Object:' + sr.getName()
                                                         ));
            }
            
        }
        
        upsert objectsToUpsert MetadataIdentifier__c;
        
        for (DictionaryItem__c di : scope) {
            if (!schemaObjects.contains(di.APIName__c)) objectsToDelete.add(di);
        }
        
        delete objectsToDelete;
        
    }  
    
    global void finish(Database.BatchableContext BC){

        Id batchJobId = Database.executeBatch(new DictionaryItemFieldBatch(),10);
        
    }
    
}