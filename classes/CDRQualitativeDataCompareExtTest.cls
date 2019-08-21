@istest
public class CDRQualitativeDataCompareExtTest {
    
    static testMethod void myTests() {
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     OverrideTriggerValidations__c = TRUE,
                                                     OverrideSetStatusOnCreate__c = TRUE);
        insert settings;
        
        Id nullId;
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0';
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>();
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId);
        CDR1[0].Status__c = 'Draft';
        CDR1[0].SortOrder__c = 10;
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR1[0]);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId);
        CDR2[0].Status__c = 'Staging';
        CDR2[0].SortOrder__c = 20;
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,2);
        cdrs.add(CDR2[0]);
        insert cdrs;        
        
        Test.startTest();
        Test.setCurrentPage(Page.CDRQualitativeDataCompare);
        CDRQualitativeDataCompareExt CDRSummary = new CDRQualitativeDataCompareExt(new ApexPages.StandardController(CDR1[0]));
        CDRSummary.compareCDRId = cdrs[1].Id;
        CDRSummary.dispAllValues = TRUE;
        
        Test.stopTest();
        
    }
    
    
    
    
    
    
}