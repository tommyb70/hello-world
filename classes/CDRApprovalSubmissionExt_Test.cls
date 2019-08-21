@isTest 
public class CDRApprovalSubmissionExt_Test{ 

    @testSetup static void setupTestData() { 
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
        OverrideTriggerValidations__c = TRUE, 
        OverrideSetStatusOnCreate__c = TRUE); 
        insert settings;
    }
    static testMethod void myTests() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Draft'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        insert CDR1;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
        
    }
    
    static testMethod void StagingActivePastTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Staging'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Active'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
           
    }        
    
    static testMethod void StagingPAPastTest() { 
        
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Staging'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Pending Activation'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
        
    }
        
    static testMethod void StagingPATest() { 
        
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Staging'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Pending Activation'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
                    
    
    }
    
    
    static testMethod void StageDraftTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Draft'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Staging'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
                
    
    }
        
    static testMethod void StagingDraftPastTest() { 
        
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Staging'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Draft'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
        
    }
       
    static testMethod void StagingDraftTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Staging'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR1);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR2[0].Status__c = 'Draft'; 
        CDR2[0].SortOrder__c = 10; 
        CDR2[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR2);
        
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
            
    }
    
    
    static testMethod void PendingActivationTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Pending Activation'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR1);
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
        
    }
    
    static testMethod void ActiveTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Active'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR1);
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
    }
    
    static testMethod void HistoricalTest() { 
    
        Id nullId; 
        
        List<Product2> products = DataFactory.createProduct2(1,'CDR Test');
        products[0].Name = 'Product 0'; 
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>(); 
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId); 
        CDR1[0].Status__c = 'Historical'; 
        CDR1[0].SortOrder__c = 10; 
        CDR1[0].EffectiveDate__c = system.today().adddays(10);
        cdrs.addall(CDR1);
        insert cdrs;
        
        Test.startTest(); 
        Test.setCurrentPage(Page.CDRApprovalSubmission); 
        CDRApprovalSubmissionExt CDR10 = new CDRApprovalSubmissionExt (new ApexPages.StandardController(CDR1[0])); 
        CDR10.autoRun();
        
    }

}