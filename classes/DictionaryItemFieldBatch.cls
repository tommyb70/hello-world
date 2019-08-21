global class DictionaryItemFieldBatch implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global final Id objectRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
    global final Id PVRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Picklist Value').getRecordTypeId();
    global final Id fieldRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
    global final Id RTRecordTypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Record Type').getRecordTypeId();    
    global final String query;
    global Set<Id> doNotDeleteIds = new Set<Id>();
    
    global DictionaryItemFieldBatch(){
        query='SELECT Id, APIName__c, MetadataIdentifier__c FROM DictionaryItem__c WHERE RecordTypeId =: objectRecordTypeId';
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC, List<DictionaryItem__c> scope){
        
        Map<String,Id> objectNameMap = new Map<String,Id>();
        List<String> objectNameList = new List<String>();
        Set<Id> objectDictionaryItemIdSet = new Set<Id>();
        
        List<DictionaryItem__c> fields = new List<DictionaryItem__c>();
        List<DictionaryItem__c> pvs = new List<DictionaryItem__c>();
        List<DictionaryItem__c> RTs = new List<DictionaryItem__c>();        
        
        
        for (DictionaryItem__c s : scope) {
            objectNameMap.put(s.APIName__c, s.Id);
            objectNameList.add(s.APIName__c);
            objectDictionaryItemIdSet.add(s.Id);  
            
        }
        
        List<Schema.DescribeSObjectResult> objectDescribeResultList = Schema.describeSObjects(objectNameList);
        
        for (Schema.DescribeSObjectResult sr : objectDescribeResultList) {            
           
            
            DictionaryItem__c objectMDIRef = new DictionaryItem__c(MetadataIdentifier__c = 'Object:' + sr.getName());
            
            Map<String,Schema.RecordTypeInfo> recordTypeMap = sr.getRecordTypeInfosByName();
            for (Schema.RecordTypeInfo r : recordTypeMap.values()) {
                String RTMDI = 'Record Type:' + sr.getName() + '.' + r.getName();
                DictionaryItem__c newRT = new  DictionaryItem__c(RecordTypeId = RTRecordTypeId,
                                                                 Label__c = r.getName(),
                                                                 APIName__c = r.getDeveloperName(),
                                                                 MetadataIdentifier__c = RTMDI);
                newRT.ParentDictionaryItem__r = objectMDIRef; 
                RTs.add(newRT);
           }
            
            String objectAPIName = sr.getName(); 
            Map<String,Schema.SObjectField> fieldMap = sr.fields.getMap();
            
            for (String fieldName : fieldMap.keySet()) {
                
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fd = field.getDescribe();
                
                List<String> fieldPicklistValuesList = new List<String>();
                
                List<Schema.SObjectType> refToList = fd.getReferenceTo();
                String refTo;
                if (refToList.size() == 1) refTo = refToList[0].getDescribe().getName();
                
                String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                String fieldAPIName = fieldMap.get(fieldName).getDescribe().getName();
                String fielddataDisplayType;
                
                String calcFormula;
                if (fd.isCalculated()) calcFormula = fd.getCalculatedFormula();
                
                String FMDI = 'Field:' + sr.getName() + '.' + fd.getName();                
                DictionaryItem__c newField = new  DictionaryItem__c(RecordTypeId = fieldRecordTypeId,
                                                                    APIName__c = fieldAPIName,
                                                                    Label__c = fd.getLabel(),
                                                                    Custom__c = fd.isCustom(),
                                                                    HelpText__c = fd.getinlineHelpText(),
                                                                    ByteLength__c = fd.getByteLength(),
                                                                    IsCalculated__c = fd.isCalculated(),
                                                                    CalculatedFormula__c = calcFormula,
                                                                    ReferenceTo__c = refTo,
                                                                    Precision__c = fd.getPrecision(),
                                                                    Scale__c = fd.getScale(),
                                                                    CompoundFieldName__c = fd.compoundfieldname,
                                                                    MetadataIdentifier__c = FMDI,
                                                                    FieldType__c = fd.getType().name(),
                                                                    Digits__c = fd.digits
                                                                   );
                newField.ParentDictionaryItem__r = objectMDIRef;                 
                
                fields.add(newField);
                
                DictionaryItem__c fieldMDIRef = new DictionaryItem__c(MetadataIdentifier__c = FMDI);
                
                List<PicklistEntry> pickListEntryList = fd.getPicklistValues();
                
                for (PicklistEntry ple : pickListEntryList) {
                    
                    String PVMDI = 'Picklist Value:' + sr.getName() + '.' + fd.getName() + '.' + ple.getValue() + '.' + ple.getLabel();
                    Boolean active = TRUE;
                    if (!ple.isActive()) active = FALSE;
                    DictionaryItem__c newPVS = new DictionaryItem__c( RecordTypeId = PVRecordTypeId,
                                                                      Label__c = ple.getLabel(), 
                                                                      APIName__c = ple.getValue(), 
                                                                      IsActive__c = active,
                                                                      MetadataIdentifier__c = PVMDI);
                    newPVS.ParentDictionaryItem__r = fieldMDIRef;   
                    pvs.add(newPVS);
                }
                
            }
            
        }        
        
        upsert fields MetadataIdentifier__c;
        upsert pvs MetadataIdentifier__c;
        upsert RTs MetadataIdentifier__c;
        
        for (DictionaryItem__c f : fields) {
            doNotDeleteIds.add(f.Id);
        }
        
        for (DictionaryItem__c p : pvs) {
            doNotDeleteIds.add(p.Id);
        }
        
        for (DictionaryItem__c r : RTs) {
            doNotDeleteIds.add(r.Id);
        }
        
    }     
    
    global void finish(Database.BatchableContext BC){
        delete [SELECT Id FROM DictionaryItem__c WHERE (ParentDictionaryItem__c = null OR Id NOT IN :doNotDeleteIds)
                                                        AND RecordTypeId != :objectRecordTypeId];
    }
    
}