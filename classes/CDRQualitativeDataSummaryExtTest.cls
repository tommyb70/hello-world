@isTest
public class CDRQualitativeDataSummaryExtTest {
    
    @testSetup
    static void testSetup() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     OverrideTriggerValidations__c = TRUE);
        insert settings;
        
        Id nullId;
        
        List<Product2> products = DataFactory.createProduct2(4,'CDR Test');
        products[0].Name = 'Mutual Fund';
        products[1].Name = 'Share Class';
        products[2].Name = 'Benchmark';
        products[3].Name = 'ETF';
        insert products;
        
        List<Account> firms = DataFactory.createTestFirms(1);
        insert firms;
        
        List<Account> accounts = DataFactory.createTestAccountswithFirms(2,firms);
        insert accounts;
        
        List<Contact> contacts = DataFactory.createTestContacts(1,accounts,FALSE);
        insert contacts;
        
        List<AdditionalInfo__c> addlInfos = new List<AdditionalInfo__c>();
        AdditionalInfo__c addlInfo = new AdditionalInfo__c(Name='Test Addl Info');
        addlInfos.add(addlInfo);
        insert addlInfos;
        
        List<CDRQualitativeData__c> CDRs = new List<CDRQualitativeData__c>();
        
        List<CDRQualitativeData__c> CDRMutualFunds = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId);
        CDRMutualFunds[0].SortOrder__c = 10;
        CDRMutualFunds[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRMutualFunds);
        
        List<CDRQualitativeData__c> CDRAddlInfos = DataFactory.createCDRQualitativeData (1, 'Additional Info', addlInfos[0].Id, nullId);
        CDRAddlInfos[0].SortOrder__c = 20;
        CDRAddlInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRAddlInfos);
        
        List<CDRQualitativeData__c> CDRAccounts = DataFactory.createCDRQualitativeData (1, 'Firm', accounts[0].Id, nullId);
        CDRAccounts[0].SortOrder__c = 30;
        CDRAccounts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRAccounts);
        
        List<CDRQualitativeData__c> CDRFirmAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Firm-Additional Info', accounts[0].Id, addlInfos[0].Id);
        CDRFirmAdditionalInfos[0].SortOrder__c = 40;
        CDRFirmAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRFirmContacts = DataFactory.createCDRQualitativeData (1, 'Firm-Contact', accounts[0].Id, contacts[0].Id);
        CDRFirmContacts[0].SortOrder__c = 50;
        CDRFirmContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmContacts);
        
        List<CDRQualitativeData__c> CDRFirmProducts = DataFactory.createCDRQualitativeData (1, 'Firm-Product', accounts[0].Id, products[0].Id);
        CDRFirmProducts[0].SortOrder__c = 60;
        CDRFirmProducts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmProducts);
        
        List<CDRQualitativeData__c> CDRBenchmarks = DataFactory.createCDRQualitativeData (1, 'Benchmark', products[2].Id, nullId);
        CDRBenchmarks[0].SortOrder__c = 70;
        CDRBenchmarks[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRBenchmarks);
        
        List<CDRQualitativeData__c> CDRContacts = DataFactory.createCDRQualitativeData (1, 'Contact', contacts[0].Id, nullId);
        CDRContacts[0].SortOrder__c = 80;
        CDRContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRContacts);
        
        List<CDRQualitativeData__c> CDRContactAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Contact-Additional Info', contacts[0].Id, addlInfos[0].Id);
        CDRContactAdditionalInfos[0].SortOrder__c = 90;
        CDRContactAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRContactAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Product-Additional Info', products[0].Id, addlInfos[0].Id);
        CDRProductAdditionalInfos[0].SortOrder__c = 100;
        CDRProductAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductBenchmarks = DataFactory.createCDRQualitativeData (1, 'Product-Benchmark', products[0].Id, products[2].Id);
        CDRProductBenchmarks[0].SortOrder__c = 110;
        CDRProductBenchmarks[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductBenchmarks);
        
        List<CDRQualitativeData__c> CDRProductChildProducts = DataFactory.createCDRQualitativeData (1, 'Product-Child Product', products[0].Id, products[1].Id);
        CDRProductChildProducts[0].SortOrder__c = 120;
        CDRProductChildProducts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductChildProducts);
        
        List<CDRQualitativeData__c> CDRProductContacts = DataFactory.createCDRQualitativeData (1, 'Product-Contact', products[0].Id, contacts[0].Id);
        CDRProductContacts[0].SortOrder__c = 130;
        CDRProductContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductContacts);
        
        List<CDRQualitativeData__c> CDRShareClasses = DataFactory.createCDRQualitativeData (1, 'Share Class', products[1].Id, nullId);
        CDRShareClasses[0].SortOrder__c = 140;
        CDRShareClasses[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRShareClasses);
        
        List<CDRQualitativeData__c> CDRETFs = DataFactory.createCDRQualitativeData (1, 'ETF', products[3].Id, nullId);
        CDRETFs[0].SortOrder__c = 150;
        CDRETFs[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRETFs);
        
        List<CDRQualitativeData__c> CDRFirmChildFirms = DataFactory.createCDRQualitativeData (1, 'Firm-Child Firm', accounts[0].Id, accounts[1].Id);
        CDRFirmChildFirms[0].SortOrder__c = 160;
        CDRFirmChildFirms[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        
        CDRs.addAll(CDRFirmChildFirms);
        
        insert CDRs;
        
        List<CDRQualitativeData__c> cdrToUpdate = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c c : CDRs) {
                c.Status__c = 'Active';
                cdrToUpdate.add(c);
        }
        
        update cdrToUpdate; 
        
    }
    
    static testMethod void myTests() {
        
        List<Product2> products = [SELECT Id, Name FROM Product2];
        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Contact> contacts = [SELECT Id, Name FROM Contact];
        List<AdditionalInfo__c> addlInfos = [SELECT Id, Name FROM AdditionalInfo__c];
        
        Test.setCurrentPage(Page.CDRQualitativeDataSummaryAccount);
        CDRQualitativeDataSummaryExt controller1 = new CDRQualitativeDataSummaryExt(new ApexPages.StandardController(products[0]));
        controller1.effdt = Datetime.newInstance(2017,11,6);
        controller1.dispStaging = TRUE;
        controller1.getQualitativeDataRecords();
    }
    
}