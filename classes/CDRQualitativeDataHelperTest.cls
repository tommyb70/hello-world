@isTest
public class CDRQualitativeDataHelperTest {
    
    @testSetup
    static void testSetup() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     OverrideTriggerValidations__c = TRUE,
                                                     OverrideSetStatusOnCreate__c = TRUE);
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
        CDRMutualFunds[0].Status__c = 'Active';
        CDRMutualFunds[0].SortOrder__c = 10;
        CDRMutualFunds[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRMutualFunds);

        List<CDRQualitativeData__c> CDRAddlInfos = DataFactory.createCDRQualitativeData (1, 'Additional Info', addlInfos[0].Id, nullId);
        CDRAddlInfos[0].Status__c = 'Active';
        CDRAddlInfos[0].SortOrder__c = 20;
        CDRAddlInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRAddlInfos);
        
        List<CDRQualitativeData__c> CDRFirms = DataFactory.createCDRQualitativeData (1, 'Firm', firms[0].Id, nullId);
        CDRFirms[0].Status__c = 'Active';
        CDRFirms[0].SortOrder__c = 30;
        CDRFirms[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirms);

        List<CDRQualitativeData__c> CDRAccounts = DataFactory.createCDRQualitativeData (1, 'Firm', accounts[0].Id, nullId);
        CDRAccounts[0].Status__c = 'Active';
        CDRAccounts[0].SortOrder__c = 30;
        CDRAccounts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRAccounts);

        List<CDRQualitativeData__c> CDRFirmAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Firm-Additional Info', accounts[0].Id, addlInfos[0].Id);
        CDRFirmAdditionalInfos[0].Status__c = 'Active';
        CDRFirmAdditionalInfos[0].SortOrder__c = 40;
        CDRFirmAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRFirmContacts = DataFactory.createCDRQualitativeData (1, 'Firm-Contact', accounts[0].Id, contacts[0].Id);
        CDRFirmContacts[0].Status__c = 'Active';
        CDRFirmContacts[0].SortOrder__c = 50;
        CDRFirmContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmContacts);
        
        List<CDRQualitativeData__c> CDRFirmProducts = DataFactory.createCDRQualitativeData (1, 'Firm-Product', accounts[0].Id, products[0].Id);
        CDRFirmProducts[0].Status__c = 'Active';
        CDRFirmProducts[0].SortOrder__c = 60;
        CDRFirmProducts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmProducts);
        
        List<CDRQualitativeData__c> CDRBenchmarks = DataFactory.createCDRQualitativeData (1, 'Benchmark', products[2].Id, nullId);
        CDRBenchmarks[0].Status__c = 'Active';
        CDRBenchmarks[0].SortOrder__c = 70;
        CDRBenchmarks[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRBenchmarks);
        
        List<CDRQualitativeData__c> CDRContacts = DataFactory.createCDRQualitativeData (1, 'Contact', contacts[0].Id, nullId);
        CDRContacts[0].Status__c = 'Active';
        CDRContacts[0].SortOrder__c = 80;
        CDRContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRContacts);
        
        List<CDRQualitativeData__c> CDRContactAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Contact-Additional Info', contacts[0].Id, addlInfos[0].Id);
        CDRContactAdditionalInfos[0].Status__c = 'Active';
        CDRContactAdditionalInfos[0].SortOrder__c = 90;
        CDRContactAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRContactAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Product-Additional Info', products[0].Id, addlInfos[0].Id);
        CDRProductAdditionalInfos[0].Status__c = 'Active';
        CDRProductAdditionalInfos[0].SortOrder__c = 100;
        CDRProductAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductBenchmarks = DataFactory.createCDRQualitativeData (1, 'Product-Benchmark', products[0].Id, products[2].Id);
        CDRProductBenchmarks[0].Status__c = 'Active';
        CDRProductBenchmarks[0].SortOrder__c = 110;
        CDRProductBenchmarks[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductBenchmarks);
        
        List<CDRQualitativeData__c> CDRProductChildProducts = DataFactory.createCDRQualitativeData (1, 'Product-Child Product', products[0].Id, products[1].Id);
        CDRProductChildProducts[0].Status__c = 'Active';
        CDRProductChildProducts[0].SortOrder__c = 120;
        CDRProductChildProducts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductChildProducts);
        
        List<CDRQualitativeData__c> CDRProductContacts = DataFactory.createCDRQualitativeData (1, 'Product-Contact', products[0].Id, contacts[0].Id);
        CDRProductContacts[0].Status__c = 'Active';
        CDRProductContacts[0].SortOrder__c = 130;
        CDRProductContacts[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRProductContacts);
        
        List<CDRQualitativeData__c> CDRShareClasses = DataFactory.createCDRQualitativeData (1, 'Share Class', products[1].Id, nullId);
        CDRShareClasses[0].Status__c = 'Active';
        CDRShareClasses[0].SortOrder__c = 140;
        CDRShareClasses[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRShareClasses);
        
        List<CDRQualitativeData__c> CDRETFs = DataFactory.createCDRQualitativeData (1, 'ETF', products[3].Id, nullId);
        CDRETFs[0].Status__c = 'Active';
        CDRETFs[0].SortOrder__c = 150;
        CDRETFs[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRETFs);
        
        List<CDRQualitativeData__c> CDRFirmChildFirms = DataFactory.createCDRQualitativeData (1, 'Firm-Child Firm', firms[0].Id, accounts[0].Id);
        CDRFirmChildFirms[0].Status__c = 'Active';
        CDRFirmChildFirms[0].SortOrder__c = 160;
        CDRFirmChildFirms[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDRs.addAll(CDRFirmChildFirms);
        
        insert CDRs;
        
    }
    
    static testMethod void myTests() {
        
        List<Product2> products = [SELECT Id, Name FROM Product2];
        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Contact> contacts = [SELECT Id, Name FROM Contact];
        List<AdditionalInfo__c> addlInfos = [SELECT Id, Name FROM AdditionalInfo__c];
        
        List<CDRQualitativeData__c> prodCDR = CDRQualitativeDataHelper.getCDRQualitativeDataParent(products[0].Id, datetime.now(),FALSE);
        List<CDRQualitativeData__c> prodchildCDR = CDRQualitativeDataHelper.getCDRQualitativeDataChild(products[1].Id, datetime.now(),FALSE);
        List<CDRQualitativeData__c> prodCDRStaging = CDRQualitativeDataHelper.getCDRQualitativeDataParent(products[0].Id, datetime.now(),TRUE);
        List<CDRQualitativeData__c> prodchildCDRStaging = CDRQualitativeDataHelper.getCDRQualitativeDataChild(products[1].Id, datetime.now(),TRUE);
        
        List<CDRQualitativeData__c> parsedList = CDRQualitativeDataHelper.parseCDRListByRecordType(prodCDR,'Product');
        
        Set<Id> productIdSet = new Set<Id>();
        for (Product2 p : products) {
            if (p.Name == 'Mutual Fund') productIdSet.add(p.Id);
        }
        
        Date asOfDate = Date.Today();
        String status;

        Map<Id,List<CDRQualitativeData__c>> mapCDRProducts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Mutual Fund', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRProductChildProducts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Product-Child Product', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRProductAdditionalInfos = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Product-Additional Info', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRFirmProducts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Firm-Product', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRProductBenchmarks = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Product-Benchmark', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRProductContacts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',productIdSet,'Product-Contact', asOfDate, status); 
        
        Set<Id> childProductIdSet = new Set<Id>(); 
        Set<Id> addtionalInfoIdSet = new Set<Id>(); 
        Set<Id> firmIdSet = new Set<Id>(); 
        Set<Id> benchmarkIdSet = new Set<Id>(); 
        Set<Id> contactIdSet = new Set<Id>(); 
        
        for (Id productId : productIdSet) { 
            if (mapCDRProductChildProducts.containsKey(productId)) { 
                for (CDRQualitativeData__c c : mapCDRProductChildProducts.get(productId)) { 
                    childProductIdSet.add(c.ChildProduct__c); 
                } 
            }    
            
            if (mapCDRProductAdditionalInfos.containsKey(productId)) { 
                for (CDRQualitativeData__c c : mapCDRProductAdditionalInfos.get(productId)) { 
                    addtionalInfoIdSet.add(c.AdditionalInfo__c); 
                } 
            } 
            
            if (mapCDRFirmProducts.containsKey(productId)) { 
                for (CDRQualitativeData__c c : mapCDRFirmProducts.get(productId)) { 
                    firmIdSet.add(c.Account__c); 
                } 
            } 
            
            if (mapCDRProductBenchmarks.containsKey(productId)) { 
                for (CDRQualitativeData__c c : mapCDRProductBenchmarks.get(productId)) { 
                    benchmarkIdSet.add(c.Benchmark__c); 
                } 
            } 
            if (mapCDRProductContacts.containsKey(productId)) { 
                for (CDRQualitativeData__c c : mapCDRProductContacts.get(productId)) { 
                    contactIdSet.add(c.Contact__c); 
                } 
            } 
        } 
        
        //get all the CDRQ records where another parent is on the joiner records 
        Map<Id,List<CDRQualitativeData__c>> mapCDRShareClasses = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Product__c',childProductIdSet,'Share Class', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRAdditionalInfos = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('AdditionalInfo__c',addtionalInfoIdSet,'Additional Info', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRFirms = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Account__c',firmIdSet,'Firm', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRBenchmarks = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Benchmark__c',benchmarkIdSet,'Benchmark', asOfDate, status); 
        Map<Id,List<CDRQualitativeData__c>> mapCDRContacts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('Contact__c',contactIdSet,'Contact', asOfDate, status);         
        Map<Id,List<CDRQualitativeData__c>> mapCDRChildProductProducts = 
            CDRQualitativeDataHelper.getCDRQualitativeDataMapByParentIds('ChildProduct__c',childProductIdSet,'Product-Child Product', asOfDate, status);

        
        
        String queryTest = CDRQualitativeDataHelper.getCDRStatusQueryStatement(null,'All');
        
    }
    
}