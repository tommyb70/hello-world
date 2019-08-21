public class CDRQualitativeDataCompareExt {
    
    public final CDRQualitativeData__c cdr {get;set;}
    public List<SelectOption> CDRSelectOptions {get;set;}
    public CDRQualitativeData__c controlCDR {get; set;}
    public CDRQualitativeData__c compareCDR {get; set;}
    public Id compareCDRId {get;set;}
    public Boolean dispAllValues {get;set;}
    public List<CompareCDRItem> comparison {get;set;}
    
    public class CompareCDRItem {
        public String FieldName { get; set; }
        public String ControlValue {get;set;}
        public String CompareValue {get;set;}
        
        public CompareCDRItem(String iFieldName, String iControlValue, String iCompareValue) {
            FieldName = iFieldName;
            ControlValue = iControlValue;
            CompareValue = iCompareValue;
        }
    }
    
    public CDRQualitativeDataCompareExt(ApexPages.StandardController controller) {
        this.cdr = (CDRQualitativeData__c)controller.getRecord();
        this.controlCDR = queryAllCDRFields(cdr.Id);
        this.CDRSelectOptions = getCDRSelectOptions();
        this.dispAllValues = getdispAllValues();
    }
    
    public Boolean getdispAllValues() {
        if (dispAllValues == null) dispAllValues = FALSE;
        return dispAllValues;
    }
    
    public List<SelectOption> getCDRSelectOptions() {
        
        CDRQualitativeData__c cdrIds = [SELECT RecordTypeId, Id, Product__c, Account__c, Benchmark__c, Contact__c, AdditionalInfo__c, 
                                        ChildAccount__c, ChildProduct__c
                                        FROM CDRQualitativeData__c
                                        WHERE Id =:cdr.Id
                                        LIMIT 1];
        
        List<SelectOption> cdrSelOpts = new List<SelectOption>();
        cdrSelOpts.add(new SelectOption(cdr.Id,' -- None -- '));
        
        for (CDRQualitativeData__c c : [SELECT Id, Name FROM CDRQualitativeData__c 
                                        WHERE Account__c = :cdrIds.Account__c
                                        AND Benchmark__c = :cdrIds.Benchmark__c
                                        AND Contact__c = :cdrIds.Contact__c
                                        AND AdditionalInfo__c = :cdrIds.AdditionalInfo__c
                                        AND ChildAccount__c = :cdrIds.ChildAccount__c
                                        AND ChildProduct__c = :cdrIds.ChildProduct__c
                                        AND Product__c = :cdrIds.Product__c
                                        AND RecordTypeId = :cdrIds.RecordTypeId
                                        AND Id != :cdr.Id
                                        ORDER BY EffectiveDate__c DESC])  {
                                            cdrSelOpts.add(new SelectOption(c.Id,c.Name));
                                        }
        return cdrSelOpts;
    }
    
    public PageReference compare() {
        
        compareCDR = queryAllCDRFields(compareCDRId);
        
        Map<String,Object> controlCDRFieldMap = controlCDR.getPopulatedFieldsAsMap();
        Map<String,Object> compareCDRFieldMap = compareCDR.getPopulatedFieldsAsMap();
        
        Map<String,CompareCDRItem> compareMap = new Map<String,CompareCDRItem>();
        
        
        for (String f : controlCDRFieldMap.keySet()) {
            
                if (compareMap.containsKey(f)) {
                    CompareCDRItem t = compareMap.get(f);
                    t.ControlValue = String.valueOf(controlCDRFieldMap.get(f));
                    compareMap.put(f,t);
                } else {
                    CompareCDRItem n = new CompareCDRItem(f,String.valueOf(controlCDRFieldMap.get(f)),' ');
                    compareMap.put(f,n);
                }
            }

        for (String f : compareCDRFieldMap.keySet()) {
                if (compareMap.containsKey(f)) {
                    CompareCDRItem t = compareMap.get(f);
                    t.CompareValue = String.valueOf(compareCDRFieldMap.get(f));
                    compareMap.put(f,t);
                } else {
                    CompareCDRItem n = new CompareCDRItem(f,' ',String.valueOf(compareCDRFieldMap.get(f)));
                    compareMap.put(f,n);
                }
        }
       
        Set<String> excludedFieldSet = new Set<String>();
        excludedFieldSet.add('Id');
        excludedFieldSet.add('OwnerId');
        excludedFieldSet.add('RecordTypeId');
        excludedFieldSet.add('CreatedDate');
        excludedFieldSet.add('CreatedById');
        excludedFieldSet.add('LastModifiedDate');
        excludedFieldSet.add('LastModifiedById');
        excludedFieldSet.add('LastViewedDate');        
        excludedFieldSet.add('LastReferencedDate');
        excludedFieldSet.add('CaseSafeSFID__c');
		excludedFieldSet.add('NextStagingDate__c');        
        excludedFieldSet.add('NextPendingActivationDate__c');
        excludedFieldSet.add('HistoricalDate__c');
        excludedFieldSet.add('IsDeleted');
        excludedFieldSet.add('ParentKey__c');
        excludedFieldSet.add('SystemModstamp');
        excludedFieldSet.add('StagingDate__c');       
        excludedFieldSet.add('Contact__c');
        excludedFieldSet.add('Account__c');
        excludedFieldSet.add('Product__c');
        excludedFieldSet.add('AdditionalInfo__c');
        excludedFieldSet.add('Benchmark__c');
        excludedFieldSet.add('ChildProduct__c');
        excludedFieldSet.add('ChildFirm__c');
        excludedFieldSet.add('ProductSFID__c');
		excludedFieldSet.add('ContactSFID__c');  
        excludedFieldSet.add('AdditionalInfoSFID__c'); 
        
        String type='CDRQualitativeData__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType CDRSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = CDRSchema.getDescribe().fields.getMap();
        
        comparison = new List<CompareCDRItem>();
        
        for (CompareCDRItem ci : compareMap.values()) {

            if (!excludedFieldSet.contains(ci.FieldName)) {            
            ci.FieldName = fieldMap.get(ci.FieldName).getDescribe().getLabel();
            
            if (!dispAllValues && ci.ControlValue != ci.CompareValue) {
                comparison.add(ci); 
            }
            
            if (dispAllValues) comparison.add(ci);
            }
        }
        
        return null;
        
    }
    
    public CDRQualitativeData__c queryAllCDRFields(Id cdrId) {
        
        String query = 'SELECT ';
        Map<String, Schema.SObjectField> CDRFields = Schema.getGlobalDescribe().get('CDRQualitativeData__c').getDescribe().fields.getMap();
        
        for(String s : CDRFields.keySet()) {
            query += ' ' + s + ',';
        }
        
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }
        
        query += ' FROM CDRQualitativeData__c ';
        query += ' WHERE Id =: cdrId '; 
        
        List<CDRQualitativeData__c> CDRs = database.query(query);
        CDRQualitativeData__c CDR = CDRs[0];
        
        return CDR;
        
    }
    
    
}