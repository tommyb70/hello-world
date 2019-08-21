public class CDRQualitativeDataSummaryExt {

    public Boolean dispStaging {get;set;}
    public Datetime effdt {get;set;}
    public String recType {get;set;}
    
    public final Id summaryId {get;set;}
    public List<CDRQualitativeData__c> cdrParent {get;set;}
    public List<CDRQualitativeData__c> cdrChild {get;set;}    
    public List<CDRQualitativeData__c> cdrAdditionalInfo {get;set;}
    public List<CDRQualitativeData__c> cdrBenchmark {get;set;}
    public List<CDRQualitativeData__c> cdrBenchmarkAdditionalInfo {get;set;}  
    public List<CDRQualitativeData__c> cdrContactAdditionalInfo {get;set;}
    public List<CDRQualitativeData__c> cdrContact {get;set;}
    public List<CDRQualitativeData__c> cdrProduct {get;set;}
    public List<CDRQualitativeData__c> cdrFirm {get;set;}
    public List<CDRQualitativeData__c> cdrFirmAdditionalInfo {get;set;}
    public List<CDRQualitativeData__c> cdrFirmChildFirm {get;set;}
    public List<CDRQualitativeData__c> cdrFirmContact {get;set;}
    public List<CDRQualitativeData__c> cdrFirmProduct {get;set;}
    public List<CDRQualitativeData__c> cdrProductAdditionalInfo {get;set;}
    public List<CDRQualitativeData__c> cdrProductBenchmark {get;set;}
    public List<CDRQualitativeData__c> cdrProductChildProduct {get;set;}
    public List<CDRQualitativeData__c> cdrProductContact {get;set;}
    public List<CDRQualitativeData__c> cdrChildFirmFirm {get;set;}
    public List<CDRQualitativeData__c> cdrChildProductProduct {get;set;}
    public List<CDRQualitativeData__c> cdrProductBenchmarkBenchmark {get;set;}
    
    public Datetime getEffdt() {
        if (effdt == null) effdt=datetime.now();
        return effdt;
    }
    
    public Boolean getDispStaging() {
        if (dispStaging == null) dispStaging=FALSE;
        return dispStaging;
    }
    
    public String getRecType() {
        if (recType == null) {
            List<Product2> prodRecType = [SELECT RecordType.Name FROM Product2 WHERE Id = :summaryId LIMIT 1];
            List<Account> acctRecType = [SELECT RecordType.Name FROM Account WHERE Id = :summaryId LIMIT 1];
            List<Contact> contRecType = [SELECT RecordType.Name FROM Contact WHERE Id = :summaryId LIMIT 1];
            List<AdditionalInfo__c> addlInfoRecType = [SELECT RecordType.Name FROM AdditionalInfo__c WHERE Id = :summaryId LIMIT 1];
            if (!prodRecType.isEmpty()) recType = prodRecType[0].RecordType.Name;
            if (!acctRecType.isEmpty()) recType = acctRecType[0].RecordType.Name;
            if (!contRecType.isEmpty()) recType = contRecType[0].RecordType.Name;
            if (!addlInfoRecType.isEmpty()) recType = addlInfoRecType[0].RecordType.Name;
        }
        return recType;
    }
    
    public CDRQualitativeDataSummaryExt(ApexPages.StandardController stdController) {
        this.summaryId = stdController.getId();
        this.effdt = getEffdt();
        this.dispStaging = getDispStaging();
        this.recType = getRecType();
        getQualitativeDataRecords();
    }

    public void getQualitativeDataRecords() {
        
        system.debug('dispStaging: ' + dispStaging);
        
        cdrParent = CDRQualitativeDataHelper.getCDRQualitativeDataParent(summaryId, effdt, dispStaging);
        cdrChild = CDRQualitativeDataHelper.getCDRQualitativeDataChild(summaryId, effdt, dispStaging);
        
        for (CDRQualitativeData__c c : cdrParent) {
            system.debug('parent: ' + c.Name);
        }

        for (CDRQualitativeData__c c : cdrChild) {
            system.debug('child: ' + c.Name);
        }
        
        cdrAdditionalInfo = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Additional Info');
        cdrBenchmark = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Benchmark');
        cdrBenchmarkAdditionalInfo = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Benchmark-Additional Info');
        cdrContact = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Contact');
        cdrContactAdditionalInfo = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Contact-Additional Info');
        cdrProduct = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Product');
        system.debug(cdrProduct);
        cdrFirm = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Firm');
        cdrFirmAdditionalInfo = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Firm-Additional Info');
        cdrFirmChildFirm = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Firm-Child Firm');
        cdrFirmContact = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Firm-Contact');
        cdrFirmProduct = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Firm-Product');
        cdrProductAdditionalInfo = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Product-Additional Info');
        cdrProductBenchmark = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Product-Benchmark');
        cdrProductChildProduct = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Product-Child Product');
        cdrProductContact = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrParent, 'Product-Contact');
        cdrChildFirmFirm = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrChild, 'Firm-Child Firm');
        cdrChildProductProduct = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrChild, 'Product-Child Product');
        cdrProductBenchmarkBenchmark = CDRQualitativeDataHelper.parseCDRListByRecordType(cdrChild, 'Product-Benchmark');

    }
    
}