@isTest
public class CDRQualitativeDataSearchExtTest {
   
   
    @testSetup static void setupTestData() { 
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

     
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                OverrideTriggerValidations__c = FALSE, 
                                                OverrideSetStatusOnCreate__c = TRUE); 
        insert settings; 
        
        Id nullId; 
        
        Date ppAsOfDate = Date.today(); 
        List<ProductPerformance__c> ppToInsert = new List<ProductPerformance__c>(); 
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate)); 
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate)); 
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate));
        ppToInsert.add(new ProductPerformance__c(AsOfDate__c = ppAsOfDate));
        insert ppToInsert; 
         
        List<Product2> products = DataFactory.createProduct2(4,'CDR Test'); 
        products[0].Name = 'Mutual Fund'; 
        products[0].MaxExternalProductPerformance__c  = ppToInsert[0].Id;
        products[1].Name = 'Share Class'; 
        products[1].MaxExternalProductPerformance__c  = ppToInsert[1].Id;
        products[2].Name = 'Benchmark'; 
        products[2].MaxExternalProductPerformance__c  = ppToInsert[2].Id;
        products[3].Name = 'ETF'; 
        products[3].MaxExternalProductPerformance__c  = ppToInsert[0].Id;
        insert products; 
        
        ppToInsert[0].Product__c = products[0].Id;
        ppToInsert[1].Product__c = products[0].Id;
        ppToInsert[2].Product__c = products[2].Id;
        ppToInsert[3].Product__c = products[0].Id;
        update ppToInsert;
        
        List<Account> firms = DataFactory.createTestFirms(1); 
        insert firms; 
        
        List<Account> accounts = DataFactory.createTestAccountswithFirms(2,firms); 
        accounts[0].Name = 'Firm'; 
        accounts[1].Name = 'ParentFirm'; 
        insert accounts; 
        
        List<Contact> contacts = DataFactory.createTestContacts(2,accounts,FALSE); 
        contacts[0].Lastname = 'Main con';
        insert contacts; 
        
        ContentVersion contentVersion = new ContentVersion(Title = 'CDR Test',
                                                          PathOnClient = 'test.jpg',
                                                          VersionData = Blob.valueOf('Test Content'),
                                                          IsMajorVersion = true);
        insert contentVersion;  
          
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = contacts[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<AdditionalInfo__c> addlInfos = new List<AdditionalInfo__c>(); 
        AdditionalInfo__c addlInfo = new AdditionalInfo__c(Name='Test Addl Info'); 
        AdditionalInfo__c addlInfo1 = new AdditionalInfo__c(Name='Test Addl Info'); 
        addlInfos.add(addlInfo); 
        addlInfos.add(addlInfo1); 
        insert addlInfos;
        
        List<CDRQualitativeData__c> CDRs = new List<CDRQualitativeData__c>(); 
        List<CDRQualitativeData__c> CDRProducts = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[0].Id, products[0].Id); 
        CDRProducts[0].SortOrder__c = 20; 
        CDRProducts[0].Status__c = 'Active'; 
        CDRProducts[0].EffectiveDate__c = Date.today().adddays(-30); 
        CDRProducts[0].ProductLegalName__c = 'TEST';
        CDRProducts[1].SortOrder__c = 21; 
        CDRProducts[1].Status__c = 'Active';
        CDRProducts[1].EffectiveDate__c = Date.today().adddays(-29); 
        CDRProducts[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRProducts); 
                        
        List<CDRQualitativeData__c> CDRProductChildProducts = DataFactory.createCDRQualitativeData (2, 'Product-Child Product', products[0].Id, products[1].Id); 
        CDRProductChildProducts[0].SortOrder__c = 20; 
        CDRProductChildProducts[0].Status__c = 'Active'; 
        CDRProductChildProducts[0].EffectiveDate__c = Date.today().adddays(-28); 
        CDRProductChildProducts[0].ProductLegalName__c = 'TEST';
        CDRProductChildProducts[1].SortOrder__c = 21; 
        CDRProductChildProducts[1].Status__c = 'Active';
        CDRProductChildProducts[1].EffectiveDate__c = Date.today().adddays(-27);  
        CDRProductChildProducts[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRProductChildProducts); 
                
        List<CDRQualitativeData__c> CDRProductAdditionalInfos = DataFactory.createCDRQualitativeData (2, 'Product-Additional Info', products[0].Id, addlInfos[0].Id); 
        CDRProductAdditionalInfos[0].SortOrder__c = 20; 
        CDRProductAdditionalInfos[0].Status__c = 'Active'; 
        CDRProductAdditionalInfos[0].EffectiveDate__c = Date.today().adddays(-26);  
        CDRProductAdditionalInfos[0].ProductLegalName__c = 'TEST';
        CDRProductAdditionalInfos[1].SortOrder__c = 21; 
        CDRProductAdditionalInfos[1].Status__c = 'Active';
        CDRProductAdditionalInfos[1].EffectiveDate__c =Date.today().adddays(-25); 
        CDRProductAdditionalInfos[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRProductAdditionalInfos); 
        
        List<CDRQualitativeData__c> CDRFirmProducts = DataFactory.createCDRQualitativeData (2, 'Firm-Product', accounts[0].Id, products[0].Id); 
        CDRFirmProducts[0].SortOrder__c = 20; 
        CDRFirmProducts[0].Status__c = 'Active'; 
        CDRFirmProducts[0].EffectiveDate__c = Date.today().adddays(-24); 
        CDRFirmProducts[0].ProductLegalName__c = 'TEST';
        CDRFirmProducts[1].SortOrder__c = 21; 
        CDRFirmProducts[1].Status__c = 'Active';
        CDRFirmProducts[1].EffectiveDate__c =Date.today().adddays(-23);  
        CDRFirmProducts[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRFirmProducts); 
        
        List<CDRQualitativeData__c> CDRProductBenchmarks = DataFactory.createCDRQualitativeData (2, 'Product-Benchmark', products[0].Id, products[2].Id); 
        CDRProductBenchmarks[0].SortOrder__c = 20; 
        CDRProductBenchmarks[0].Status__c = 'Active'; 
        CDRProductBenchmarks[0].EffectiveDate__c = Date.today().adddays(-22);  
        CDRProductBenchmarks[0].ProductLegalName__c = 'TEST';
        CDRProductBenchmarks[1].SortOrder__c = 21; 
        CDRProductBenchmarks[1].Status__c = 'Active';
        CDRProductBenchmarks[1].EffectiveDate__c = Date.today().adddays(-21); 
        CDRProductBenchmarks[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRProductBenchmarks); 
        
        List<CDRQualitativeData__c> CDRProductContacts = DataFactory.createCDRQualitativeData (2, 'Product-Contact', products[0].Id, contacts[0].Id); 
        CDRProductContacts[0].SortOrder__c = 20; 
        CDRProductContacts[0].Status__c = 'Active'; 
        CDRProductContacts[0].EffectiveDate__c = Date.today().adddays(-20);  
        CDRProductContacts[0].ProductLegalName__c = 'TEST';
        CDRProductContacts[1].SortOrder__c = 21; 
        CDRProductContacts[1].Status__c = 'Active';
        CDRProductContacts[1].EffectiveDate__c = Date.today().adddays(-19); 
        CDRProductContacts[1].ProductLegalName__c = 'TEST';
        CDRs.addAll(CDRProductContacts); 
        
        List<CDRQualitativeData__c> CDRShareClasses = DataFactory.createCDRQualitativeData (2, 'Share Class', products[1].Id, nullId); 
        CDRShareClasses[0].SortOrder__c = 180; 
        CDRShareClasses[0].EffectiveDate__c =Date.today().adddays(-18); 
        CDRShareClasses[0].Status__c = 'Active';
        CDRShareClasses[1].SortOrder__c = 181; 
        CDRShareClasses[1].EffectiveDate__c = Date.today().adddays(-17);  
        CDRShareClasses[1].Status__c = 'Active';
        CDRs.addAll(CDRShareClasses); 
        
        List<CDRQualitativeData__c> CDRBenchmarks = DataFactory.createCDRQualitativeData (2, 'Benchmark', products[2].Id, nullId); 
        CDRBenchmarks[0].SortOrder__c = 110; 
        CDRBenchmarks[0].EffectiveDate__c =  Date.today().adddays(-16);  
        CDRBenchmarks[0].Status__c = 'Active';
        CDRBenchmarks[1].SortOrder__c = 111; 
        CDRBenchmarks[1].EffectiveDate__c = Date.today().adddays(-15);  
        CDRBenchmarks[1].Status__c = 'Active';
        CDRs.addAll(CDRBenchmarks); 
        
        List<CDRQualitativeData__c> CDRShareClass = DataFactory.createCDRQualitativeData (2, 'Share Class', products[0].Id, nullId); 
        CDRShareClass[0].SortOrder__c = 110; 
        CDRShareClass[0].EffectiveDate__c =  Date.today().adddays(-16);  
        CDRShareClass[0].Status__c = 'Active';
        CDRShareClass[1].SortOrder__c = 111; 
        CDRShareClass[1].EffectiveDate__c = Date.today().adddays(-15);  
        CDRShareClass[1].Status__c = 'Active';
        CDRs.addAll(CDRShareClass); 
                        
        List<CDRQualitativeData__c> CDRAddlInfos = DataFactory.createCDRQualitativeData (2, 'Additional Info', addlInfos[0].Id, nullId); 
        CDRAddlInfos[0].SortOrder__c = 20; 
        CDRAddlInfos[0].Status__c = 'Active'; 
        CDRAddlInfos[0].EffectiveDate__c =  Date.today().adddays(-14); 
        CDRAddlInfos[1].SortOrder__c = 21; 
        CDRAddlInfos[1].Status__c = 'Active';
        CDRAddlInfos[1].EffectiveDate__c = Date.today().adddays(-13); 
        CDRs.addAll(CDRAddlInfos); 
        
        List<CDRQualitativeData__c> CDRConAddlInfos = DataFactory.createCDRQualitativeData (2, 'Contact-Additional Info', contacts[0].Id,addlInfos[0].Id); 
        CDRConAddlInfos[0].SortOrder__c = 20; 
        CDRConAddlInfos[0].Status__c = 'Active'; 
        CDRConAddlInfos[0].EffectiveDate__c =  Date.today().adddays(-14); 
        CDRConAddlInfos[1].SortOrder__c = 21; 
        CDRConAddlInfos[1].Status__c = 'Active';
        CDRConAddlInfos[1].EffectiveDate__c = Date.today().adddays(-13); 
        CDRs.addAll(CDRConAddlInfos); 
        
        List<CDRQualitativeData__c> CDRBenAddlInfos = DataFactory.createCDRQualitativeData (2, 'Benchmark-Additional Info', products[2].Id,addlInfos[0].Id); 
        CDRBenAddlInfos[0].SortOrder__c = 20; 
        CDRBenAddlInfos[0].Status__c = 'Active'; 
        CDRBenAddlInfos[0].EffectiveDate__c =  Date.today().adddays(-14); 
        CDRBenAddlInfos[1].SortOrder__c = 21; 
        CDRBenAddlInfos[1].Status__c = 'Active';
        CDRBenAddlInfos[1].EffectiveDate__c = Date.today().adddays(-13); 
        CDRs.addAll(CDRBenAddlInfos); 
                
        List<CDRQualitativeData__c> CDRAccounts = DataFactory.createCDRQualitativeData (2, 'Firm', accounts[0].Id, nullId); 
        CDRAccounts[0].SortOrder__c = 70; 
        CDRAccounts[0].EffectiveDate__c =  Date.today().adddays(-12); 
        CDRAccounts[0].Status__c = 'Active';
        CDRAccounts[0].FirmLegalName__c = 'CDRAccounts0'; 
        CDRAccounts[1].SortOrder__c = 71; 
        CDRAccounts[1].Status__c = 'Active';
        CDRAccounts[1].EffectiveDate__c =  Date.today().adddays(-11); 
        CDRs.addAll(CDRAccounts); 
        
        List<CDRQualitativeData__c> CDRAccountChildAccounts = DataFactory.createCDRQualitativeData (2, 'Firm-Child Firm', accounts[0].Id, accounts[1].Id); 
        CDRAccountChildAccounts[0].SortOrder__c = 70; 
        CDRAccountChildAccounts[0].EffectiveDate__c =  Date.today().adddays(-40); 
        CDRAccountChildAccounts[0].Status__c = 'Active';
        CDRAccountChildAccounts[0].FirmLegalName__c = 'CDRAccountChildAccounts0'; 
        CDRAccountChildAccounts[1].SortOrder__c = 71; 
        CDRAccountChildAccounts[1].Status__c = 'Active';
        CDRAccountChildAccounts[1].EffectiveDate__c =  Date.today().adddays(-39); 
        CDRs.addAll(CDRAccountChildAccounts); 
                
        List<CDRQualitativeData__c> CDRAccountAdditionalInfos = DataFactory.createCDRQualitativeData (2, 'Firm-Additional Info', accounts[0].Id, addlInfos[0].Id); 
        CDRAccountAdditionalInfos[0].SortOrder__c = 70; 
        CDRAccountAdditionalInfos[0].EffectiveDate__c =  Date.today().adddays(-38); 
        CDRAccountAdditionalInfos[0].Status__c = 'Active';
        CDRAccountAdditionalInfos[0].FirmLegalName__c = 'CDRAccountAdditionalInfos0'; 
        CDRAccountAdditionalInfos[1].SortOrder__c = 71; 
        CDRAccountAdditionalInfos[1].Status__c = 'Active';
        CDRAccountAdditionalInfos[1].EffectiveDate__c =  Date.today().adddays(-37); 
        CDRs.addAll(CDRAccountAdditionalInfos); 
        
        List<CDRQualitativeData__c> CDRAccountContacts = DataFactory.createCDRQualitativeData (2, 'Firm-Contact', accounts[0].Id, contacts[0].Id); 
        CDRAccountContacts[0].SortOrder__c = 70; 
        CDRAccountContacts[0].EffectiveDate__c =  Date.today().adddays(-36); 
        CDRAccountContacts[0].Status__c = 'Active';
        CDRAccountContacts[0].FirmLegalName__c = 'CDRAccountContacts0'; 
        CDRAccountAdditionalInfos[1].SortOrder__c = 71; 
        CDRAccountContacts[1].Status__c = 'Active';
        CDRAccountContacts[1].EffectiveDate__c =  Date.today().adddays(-35); 
        CDRs.addAll(CDRAccountContacts); 
        
        List<CDRQualitativeData__c> CDRContacts = DataFactory.createCDRQualitativeData (5, 'Contact', contacts[0].Id, nullId); 
        CDRContacts[0].SortOrder__c = 120; 
        CDRContacts[0].EffectiveDate__c = Date.today().adddays(-10); 
        CDRContacts[0].Status__c = 'Active';
        CDRContacts[1].SortOrder__c = 121; 
        CDRContacts[1].EffectiveDate__c = Date.today().adddays(-9); 
        CDRContacts[1].Status__c = 'Active';
        CDRContacts[2].SortOrder__c = 122; 
        CDRContacts[2].Status__c = 'Active';
        CDRContacts[2].EffectiveDate__c = Date.today().adddays(-8); 
        CDRContacts[3].SortOrder__c = 123; 
        CDRContacts[3].Status__c = 'Active';
        CDRContacts[3].EffectiveDate__c = Date.today().adddays(-7); 
        CDRContacts[4].SortOrder__c = 124; 
        CDRContacts[4].Status__c = 'Active';
        CDRContacts[4].EffectiveDate__c = Date.today().adddays(-6); 
        CDRs.addAll(CDRContacts);
        
        insert CDRs;        
    }
    
    static testMethod void myTests() {
         CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
         CDR.CDRData = new CDRQualitativeData__c();
         CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('Benchmark-Additional Info').getRecordTypeId(); 
         CDR.AdditionalInfoOptionsSelection = 'All';
         CDR.BenchmarkOptionsSelection = 'All';
         CDR.contactOptionsSelection = 'All';
         CDR.firmOptionsSelection = 'All';
         CDR.ChildAccountOptionsSelection = 'All';
         CDR.productOptionsSelection = 'All';
         CDR.ChildProductOptionsSelection = 'All';
         CDR.recordStatusChange();
         CDR.getStatusunSelectedValues();
         CDR.getStatusSelectedValues();
         CDR.StatusSelectclick();
         CDR.StatusunSelectclick();
         CDR.StatusRightvalues = new set<String>();
         CDR.StatusRightvalues.add('Staging');
         CDR.StatusLeftSelected = new List<String>();
         CDR.StatusLeftSelected.add('Staging');
         CDR.Search();               
    }
    
     static testMethod void myTestsMethodThree() {            
            CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
            CDR.CDRData = new CDRQualitativeData__c();
            CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('Firm-Additional Info').getRecordTypeId(); 
            CDR.AdditionalInfoOptionsSelection = 'All';
            CDR.BenchmarkOptionsSelection = 'All';
            CDR.contactOptionsSelection = 'All';
            CDR.firmOptionsSelection = 'All';
            CDR.ChildAccountOptionsSelection = 'All';
            CDR.productOptionsSelection = 'All';
            CDR.ChildProductOptionsSelection = 'All';
            CDR.recordStatusChange();
            CDR.getStatusunSelectedValues();
            CDR.getStatusSelectedValues();
            CDR.StatusSelectclick();
            CDR.StatusunSelectclick();
            CDR.StatusRightvalues = new set<String>();
            CDR.StatusRightvalues.add('Staging');
            CDR.StatusRightSelected = new List<String>();
            CDR.StatusRightSelected.add('Staging');
            CDR.Search();               
        }
    
        static testMethod void myTestsMethodFour() {            
            CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
            CDR.CDRData = new CDRQualitativeData__c();
            CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('Product-Contact').getRecordTypeId(); 
            CDR.AdditionalInfoOptionsSelection = 'All';
            CDR.BenchmarkOptionsSelection = 'All';
            CDR.contactOptionsSelection = 'All';
            CDR.firmOptionsSelection = 'All';
            CDR.ChildAccountOptionsSelection = 'All';
            CDR.productOptionsSelection = 'All';
            CDR.ChildProductOptionsSelection = 'All';
            CDR.recordStatusChange();
            CDR.getStatusunSelectedValues();
            CDR.getStatusSelectedValues();
            CDR.StatusSelectclick();
            CDR.StatusunSelectclick();
            CDR.StatusRightvalues = new set<String>();
            CDR.StatusRightvalues.add('Staging');
            CDR.StatusRightSelected = new List<String>();
            CDR.StatusRightSelected.add('Staging');
            CDR.Search();               
        }
        
        static testMethod void myTestsMethodFive() {           
            CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
            CDR.CDRData = new CDRQualitativeData__c();
            CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('ETF').getRecordTypeId(); 
            CDR.AdditionalInfoOptionsSelection = 'All';
            CDR.BenchmarkOptionsSelection = 'All';
            CDR.contactOptionsSelection = 'All';
            CDR.firmOptionsSelection = 'All';
            CDR.ChildAccountOptionsSelection = 'All';
            CDR.productOptionsSelection = 'All';
            CDR.ChildProductOptionsSelection = 'All';
            CDR.recordStatusChange();
            CDR.getStatusunSelectedValues();
            CDR.getStatusSelectedValues();
            CDR.StatusSelectclick();
            CDR.StatusunSelectclick();
            CDR.StatusRightvalues = new set<String>();
            CDR.StatusRightvalues.add('Staging');
            CDR.StatusRightSelected = new List<String>();
            CDR.StatusRightSelected.add('Staging');
            CDR.Search();               
        }
        
        static testMethod void myTestsMethodSix() {            
            CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
            CDR.CDRData = new CDRQualitativeData__c();
            CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('Firm-Child Firm').getRecordTypeId(); 
            CDR.AdditionalInfoOptionsSelection = 'All';
            CDR.BenchmarkOptionsSelection = 'All';
            CDR.contactOptionsSelection = 'All';
            CDR.firmOptionsSelection = 'All';
            CDR.ChildAccountOptionsSelection = 'All';
            CDR.productOptionsSelection = 'All';
            CDR.ChildProductOptionsSelection = 'All';
            CDR.recordStatusChange();
            CDR.getStatusunSelectedValues();
            CDR.getStatusSelectedValues();
            CDR.StatusSelectclick();
            CDR.StatusunSelectclick();
            CDR.StatusRightvalues = new set<String>();
            CDR.StatusRightvalues.add('Staging');
            CDR.StatusRightSelected = new List<String>();
            CDR.StatusRightSelected.add('Staging');
            CDR.Search();               
        }
        
        static testMethod void myTestsMethodSeven() {            
            CDRQualitativeDataSearchExt CDR = new CDRQualitativeDataSearchExt();
            CDR.CDRData = new CDRQualitativeData__c();
            CDR.CDRData.RecordtypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get('Product-Child Product').getRecordTypeId(); 
            CDR.AdditionalInfoOptionsSelection = 'All';
            CDR.BenchmarkOptionsSelection = 'All';
            CDR.contactOptionsSelection = 'All';
            CDR.firmOptionsSelection = 'All';
            CDR.ChildAccountOptionsSelection = 'All';
            CDR.productOptionsSelection = 'All';
            CDR.ChildProductOptionsSelection = 'All';
            CDR.recordStatusChange();
            CDR.getStatusunSelectedValues();
            CDR.getStatusSelectedValues();
            CDR.StatusSelectclick();
            CDR.StatusunSelectclick();
            CDR.StatusRightvalues = new set<String>();
            CDR.StatusRightvalues.add('Staging');
            CDR.StatusRightSelected = new List<String>();
            CDR.StatusRightSelected.add('Staging');
            CDR.Search();
        }    
}