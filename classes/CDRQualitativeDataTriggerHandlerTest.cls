@isTest
public class CDRQualitativeDataTriggerHandlerTest {
    
    @testSetup
    static void testSetup() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     OverrideTriggerValidations__c = FALSE,
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
        accounts[0].Name = 'Firm';
        accounts[1].Name = 'ParentFirm';
        insert accounts;
        
        List<Contact> contacts = DataFactory.createTestContacts(2,accounts,FALSE);
        insert contacts;
        
        List<AdditionalInfo__c> addlInfos = new List<AdditionalInfo__c>();
        AdditionalInfo__c addlInfo = new AdditionalInfo__c(Name='Test Addl Info');
        AdditionalInfo__c addlInfo1 = new AdditionalInfo__c(Name='Test Addl Info');
        addlInfos.add(addlInfo);
        addlInfos.add(addlInfo1);
        insert addlInfos;

        //Validating isInsert checks
        List<CDRQualitativeData__c> preCheckDupeDraft = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[0].Id, nullId);
        preCheckDupeDraft[0].SortOrder__c = 0;
        preCheckDupeDraft[0].Status__c = 'Draft';
        preCheckDupeDraft[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        preCheckDupeDraft[1].Status__c = 'Draft';
        preCheckDupeDraft[1].SortOrder__c = 0;
        preCheckDupeDraft[1].EffectiveDate__c = datetime.newInstance(1978,1,1);
        
        try
        {
            insert preCheckDupeDraft;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is another Draft record already; please coordinate updates') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        List<CDRQualitativeData__c> preCheckPastActive = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[0].Id, nullId);
        preCheckPastActive[0].SortOrder__c = 0;
        preCheckPastActive[0].Status__c = 'Active';
        preCheckPastActive[0].EffectiveDate__c = datetime.newInstance(2010,1,1);
        preCheckPastActive[1].Status__c = 'Draft';
        preCheckPastActive[1].SortOrder__c = 0;
        preCheckPastActive[1].EffectiveDate__c = datetime.newInstance(2008,1,1);
        
        try
        {
            insert preCheckPastActive;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }         
        
        List<CDRQualitativeData__c> preCheckSameEffdt = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[0].Id, nullId);
        preCheckSameEffdt[0].SortOrder__c = 0;
        preCheckSameEffdt[0].Status__c = 'Active';
        preCheckSameEffdt[0].EffectiveDate__c = datetime.newInstance(2009,1,1);
        preCheckSameEffdt[1].Status__c = 'Active';
        preCheckSameEffdt[1].SortOrder__c = 0;
        preCheckSameEffdt[1].EffectiveDate__c = datetime.newInstance(2009,1,1);
        
        try
        {
            insert preCheckSameEffdt;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is another row with the exact same Effective Date; please change the Effective Date on this record') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 

        settings.OverrideTriggerValidations__c = TRUE;
        update settings;

        List<CDRQualitativeData__c> CDRs = new List<CDRQualitativeData__c>();
        
        List<CDRQualitativeData__c> CDRMutualFunds = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[0].Id, nullId);
        CDRMutualFunds[0].SortOrder__c = 10;
        CDRMutualFunds[0].Status__c = 'Active';
        CDRMutualFunds[0].ProductLegalName__c = 'CDRMutualFund0';
        CDRMutualFunds[0].EffectiveDate__c = datetime.newInstance(2010,1,1);
        CDRMutualFunds[1].SortOrder__c = 11;
        CDRMutualFunds[1].Status__c = 'Draft';
        CDRMutualFunds[1].EffectiveDate__c = datetime.newInstance(2011,1,1);
        CDRs.addAll(CDRMutualFunds);
        
        settings.OverrideSetStatusOnCreate__c = FALSE;
        update settings;
        
        List<CDRQualitativeData__c> CDRAddlInfos = DataFactory.createCDRQualitativeData (2, 'Additional Info', addlInfos[0].Id, nullId);
        CDRAddlInfos[0].SortOrder__c = 20;
        CDRAddlInfos[0].EffectiveDate__c = datetime.newInstance(2020,1,1);
        CDRAddlInfos[1].SortOrder__c = 21;
        CDRAddlInfos[1].EffectiveDate__c = datetime.newInstance(2021,1,1);
        CDRs.addAll(CDRAddlInfos);
        
        List<CDRQualitativeData__c> CDRAccounts = DataFactory.createCDRQualitativeData (2, 'Firm', accounts[0].Id, nullId);
        CDRAccounts[0].SortOrder__c = 70;
        CDRAccounts[0].EffectiveDate__c = datetime.newInstance(2070,1,1);
        CDRAccounts[0].FirmLegalName__c = 'CDRAccounts0';
        CDRAccounts[1].SortOrder__c = 71;
        CDRAccounts[1].EffectiveDate__c = datetime.newInstance(2071,1,1);
        CDRs.addAll(CDRAccounts);
        
        List<CDRQualitativeData__c> CDRFirmAdditionalInfos = DataFactory.createCDRQualitativeData (2, 'Firm-Additional Info', accounts[0].Id, addlInfos[0].Id);
        CDRFirmAdditionalInfos[0].SortOrder__c = 80;
        CDRFirmAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(2080,1,1);
        CDRFirmAdditionalInfos[1].SortOrder__c = 81;
        CDRFirmAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(2081,1,1);
        CDRs.addAll(CDRFirmAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRFirmContacts = DataFactory.createCDRQualitativeData (2, 'Firm-Contact', accounts[0].Id, contacts[0].Id);
        CDRFirmContacts[0].SortOrder__c = 90;
        CDRFirmContacts[0].EffectiveDate__c = datetime.newInstance(2090,1,1);
        CDRFirmContacts[1].SortOrder__c = 91;
        CDRFirmContacts[1].EffectiveDate__c = datetime.newInstance(2091,1,1);
        CDRs.addAll(CDRFirmContacts);
        
        List<CDRQualitativeData__c> CDRFirmProducts = DataFactory.createCDRQualitativeData (1, 'Firm-Product', accounts[0].Id, products[0].Id);
        CDRFirmProducts[0].SortOrder__c = 100;
        CDRFirmProducts[0].EffectiveDate__c = datetime.newInstance(2100,1,1);
        CDRs.addAll(CDRFirmProducts);
        
        List<CDRQualitativeData__c> CDRBenchmarks = DataFactory.createCDRQualitativeData (2, 'Benchmark', products[2].Id, nullId);
        CDRBenchmarks[0].SortOrder__c = 110;
        CDRBenchmarks[0].EffectiveDate__c = datetime.newInstance(2110,1,1);
        CDRBenchmarks[1].SortOrder__c = 111;
        CDRBenchmarks[1].EffectiveDate__c = datetime.newInstance(2111,1,1);
        CDRs.addAll(CDRBenchmarks);
        
        List<CDRQualitativeData__c> CDRContacts = DataFactory.createCDRQualitativeData (5, 'Contact', contacts[0].Id, nullId);
        CDRContacts[0].SortOrder__c = 120;
        CDRContacts[0].EffectiveDate__c = datetime.newInstance(2120,1,1);
        CDRContacts[1].SortOrder__c = 121;
        CDRContacts[1].EffectiveDate__c = datetime.newInstance(2121,1,1);
        CDRContacts[2].SortOrder__c = 122;
        CDRContacts[2].EffectiveDate__c = datetime.newInstance(2122,1,1);
        CDRContacts[3].SortOrder__c = 123;
        CDRContacts[3].EffectiveDate__c = datetime.newInstance(2123,1,1);
        CDRContacts[4].SortOrder__c = 124;
        CDRContacts[4].EffectiveDate__c = datetime.newInstance(2124,1,1);
        CDRs.addAll(CDRContacts);
        
        List<CDRQualitativeData__c> CDRContactAdditionalInfos = DataFactory.createCDRQualitativeData (4, 'Contact-Additional Info', contacts[0].Id, addlInfos[0].Id);
        CDRContactAdditionalInfos[0].SortOrder__c = 130;
        CDRContactAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(2130,1,1);
        CDRContactAdditionalInfos[1].SortOrder__c = 131;
        CDRContactAdditionalInfos[1].EffectiveDate__c = datetime.newInstance(2131,1,1);
        CDRContactAdditionalInfos[2].SortOrder__c = 132;
        CDRContactAdditionalInfos[2].EffectiveDate__c = datetime.newInstance(2132,1,1);
        CDRContactAdditionalInfos[3].SortOrder__c = 133;
        CDRContactAdditionalInfos[3].EffectiveDate__c = datetime.newInstance(2133,1,1);
        CDRs.addAll(CDRContactAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductAdditionalInfos = DataFactory.createCDRQualitativeData (1, 'Product-Additional Info', products[0].Id, addlInfos[0].Id);
        CDRProductAdditionalInfos[0].SortOrder__c = 140;
        CDRProductAdditionalInfos[0].EffectiveDate__c = datetime.newInstance(2140,1,1);
        CDRs.addAll(CDRProductAdditionalInfos);
        
        List<CDRQualitativeData__c> CDRProductBenchmarks = DataFactory.createCDRQualitativeData (4, 'Product-Benchmark', products[0].Id, products[2].Id);
        CDRProductBenchmarks[0].SortOrder__c = 150;
        CDRProductBenchmarks[0].EffectiveDate__c = datetime.newInstance(2150,1,1);
        CDRProductBenchmarks[1].SortOrder__c = 151;
        CDRProductBenchmarks[1].EffectiveDate__c = datetime.newInstance(2151,1,1);
        CDRProductBenchmarks[2].SortOrder__c = 152;
        CDRProductBenchmarks[2].EffectiveDate__c = datetime.newInstance(2152,1,1);
        CDRProductBenchmarks[3].SortOrder__c = 152;
        CDRProductBenchmarks[3].EffectiveDate__c = datetime.newInstance(2153,1,1);
        CDRs.addAll(CDRProductBenchmarks);
        
        List<CDRQualitativeData__c> CDRProductChildProducts = DataFactory.createCDRQualitativeData (1, 'Product-Child Product', products[0].Id, products[1].Id);
        CDRProductChildProducts[0].SortOrder__c = 160;
        CDRProductChildProducts[0].EffectiveDate__c = datetime.newInstance(2160,1,1);
        CDRs.addAll(CDRProductChildProducts);
        
        List<CDRQualitativeData__c> CDRProductContacts = DataFactory.createCDRQualitativeData (1, 'Product-Contact', products[0].Id, contacts[0].Id);
        CDRProductContacts[0].SortOrder__c = 170;
        CDRProductContacts[0].EffectiveDate__c = datetime.newInstance(2170,1,1);
        CDRs.addAll(CDRProductContacts);
        
        List<CDRQualitativeData__c> CDRShareClasses = DataFactory.createCDRQualitativeData (2, 'Share Class', products[1].Id, nullId);
        CDRShareClasses[0].SortOrder__c = 180;
        CDRShareClasses[0].EffectiveDate__c = datetime.newInstance(2180,1,1);
        CDRShareClasses[1].SortOrder__c = 181;
        CDRShareClasses[1].EffectiveDate__c = datetime.newInstance(2181,1,1);
        CDRs.addAll(CDRShareClasses);
        
        List<CDRQualitativeData__c> CDRETFs = DataFactory.createCDRQualitativeData (4, 'ETF', products[3].Id, nullId);
        CDRETFs[0].SortOrder__c = 190;
        CDRETFs[0].EffectiveDate__c = datetime.newInstance(2190,1,1);
        CDRETFs[1].SortOrder__c = 191;
        CDRETFs[1].EffectiveDate__c = datetime.newInstance(2191,1,1);
        CDRETFs[2].SortOrder__c = 192;
        CDRETFs[2].EffectiveDate__c = datetime.newInstance(2192,1,1);
        CDRETFs[3].SortOrder__c = 193;
        CDRETFs[3].EffectiveDate__c = datetime.newInstance(2193,1,1);
        CDRs.addAll(CDRETFs);
        
        List<CDRQualitativeData__c> CDRFirmChildFirms = DataFactory.createCDRQualitativeData (200, 'Firm-Child Firm', accounts[0].Id, accounts[1].Id);
        CDRFirmChildFirms[0].SortOrder__c = 210;
        CDRFirmChildFirms[0].EffectiveDate__c = datetime.newInstance(2210,1,1);
        CDRs.addAll(CDRFirmChildFirms);
        
        insert CDRs;
        
        settings.OverrideSetStatusOnCreate__c = FALSE;
        update settings;
        
        List<CDRQualitativeData__c> cdrToUpdate = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c c : CDRs) {
            
            if (c.SortOrder__c == 10) {
                cdrToUpdate.add(c);
            }
            if (c.SortOrder__c == 11) {
                c.Status__c = 'Staging';
                cdrToUpdate.add(c);
            }
         
            if (c.SortOrder__c == 20) {
                c.Status__c = 'Active';
                cdrToUpdate.add(c);
            }

            if (c.SortOrder__c == 70) {
                c.Status__c = 'Active';
                c.NextStagingDate__c = datetime.newInstance(2033,1,1);
                cdrToUpdate.add(c);
            }
            if (c.SortOrder__c == 71) {
                c.Status__c = 'Staging';
                cdrToUpdate.add(c);
            }
            if (c.SortOrder__c == 80) {
                c.Status__c = 'Staging';
                cdrToUpdate.add(c);
            }
            if (c.SortOrder__c == 90) {
                c.Status__c = 'Pending Activation';
                c.EffectiveDate__c = datetime.newInstance(2035, 1, 1);
                cdrToUpdate.add(c);
            }
            if (c.SortOrder__c == 91) {
                c.Status__c = 'Staging'; 
                c.EffectiveDate__c = datetime.newInstance(2036, 1, 1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 110) {
                c.Status__c = 'Active'; 
                cdrToUpdate.add(c);
            }            
            
            if (c.SortOrder__c == 120) {
                c.Status__c = 'Active'; 
                c.EffectiveDate__c = datetime.newInstance(2004,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 121) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2003,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 122) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2002,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 123) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2001,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 124) {
                c.Status__c = 'Staging'; 
                c.EffectiveDate__c = datetime.newInstance(2001,1,2);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 151) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2003,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 152) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2002,1,1);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 153) {
                c.Status__c = 'Historical'; 
                c.EffectiveDate__c = datetime.newInstance(2001,1,1);
                cdrToUpdate.add(c);
            }            
            
            if (c.SortOrder__c == 154) {
                c.Status__c = 'Inactive'; 
                c.EffectiveDate__c = datetime.newInstance(2001,1,2);
                cdrToUpdate.add(c);
            }
            
            if (c.SortOrder__c == 180) {
                c.Status__c = 'Active';
                c.NextPendingActivationDate__c = datetime.newInstance(2030,1,1);
                cdrToUpdate.add(c);
            }

            if (c.SortOrder__c == 190) {
                c.Status__c = 'Inactive';
                c.NextPendingActivationDate__c = datetime.newInstance(2031,1,1);
                c.NextStagingDate__c = datetime.newInstance(2032,1,1);
                cdrToUpdate.add(c);
            }
            
        }
        
        update cdrToUpdate;
        
    }
    
    static testMethod void myTests() {

        Id nullId;        
        Test.startTest();
        List<CDRQualitativeData__c> CDRs = [SELECT Id, RecordType.Name, SortOrder__c, Status__c
                                            FROM CDRQualitativeData__c
                                            WHERE SortOrder__c != 0];
        
        List<CDRQualitativeData__c> cdrToUpdate = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c c : CDRs) {
        // because of this action, 20 should have a NextStagingDate
            if (c.SortOrder__c == 21) {
                c.Status__c = 'Staging';
                c.EffectiveDate__c = datetime.newInstance(2034,1,1);
                cdrToUpdate.add(c);
            }
        // because of this action, 70 should not a NextStagingDate
            if (c.SortOrder__c == 71) {
                c.Status__c = 'Draft';
                cdrToUpdate.add(c);
            }
        // because of this action, 10 should now be in historical
            if (c.SortOrder__c == 11) {
                c.Status__c = 'Active';
                cdrToUpdate.add(c);
            }
        // because of this action, 80 should now be in draft        
            if (c.SortOrder__c == 81) {
                c.Status__c = 'Staging';
                cdrToUpdate.add(c);
            }
        // because of this action, 90 should now be in inactive        
            if (c.SortOrder__c == 91) {
                c.Status__c = 'Pending Activation';
                cdrToUpdate.add(c);
            }

        // because of this action, 110 should now have a NextPendingActivationDate
            if (c.SortOrder__c == 111) {
                c.Status__c = 'Pending Activation';
                c.EffectiveDate__c = datetime.newInstance(2030,1,1);
                cdrToUpdate.add(c);
            }            
            
        // because of this action, the 120's should have their historical dates set correctly
            if (c.SortOrder__c == 124) {
                c.Status__c = 'Pending Activation';
                cdrToUpdate.add(c);
            }            

        // because of this action, the 150's should have their historical dates set correctly
            if (c.SortOrder__c == 153) {
                c.Status__c = 'Historical';
                cdrToUpdate.add(c);
            }            

        // because of this action, 190 should now have a null NextPendingActivationDate and NextStagingDate (rollback)
            if (c.SortOrder__c == 190) {
                c.Status__c = 'Active';
                cdrToUpdate.add(c);
            }            
            
        }        
        update cdrToUpdate;
        
        // Validation Checks
        CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
        settings.OverrideTriggerValidations__c = FALSE;
        update settings; 
        
        // Try to insert a draft record where one already exists - one at a time
        Account acct = [SELECT Id from Account WHERE Name = 'Firm' LIMIT 1];
        Product2 prod = [SELECT Id from Product2 WHERE Name = 'Mutual Fund' LIMIT 1];
        
        List<CDRQualitativeData__c> CDRFirmProducts = DataFactory.createCDRQualitativeData (1, 'Firm-Product', acct.Id, prod.Id);
        CDRFirmProducts[0].SortOrder__c = 101;
        CDRFirmProducts[0].EffectiveDate__c = datetime.newInstance(2100,1,2);

        try
        {
            insert CDRFirmProducts[0];
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is another Draft record already; please coordinate updates') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        // Try to insert a draft record where one already exists - multiple inserts
        List<CDRQualitativeData__c> CDRFirmProducts2 = DataFactory.createCDRQualitativeData (2, 'Firm-Product', acct.Id, prod.Id);
        CDRFirmProducts2[0].SortOrder__c = 103;
        CDRFirmProducts2[0].EffectiveDate__c = datetime.newInstance(2103,1,2);
        CDRFirmProducts2[1].SortOrder__c = 104;
        CDRFirmProducts2[1].EffectiveDate__c = datetime.newInstance(2104,1,3);
        try
        {
            insert CDRFirmProducts2;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is another Draft record already; please coordinate updates') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        // Try to insert a draft record where an active record has a greater effective date
        List<CDRQualitativeData__c> CDRMutualFunds = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', prod.Id, nullId);
        CDRMutualFunds[0].SortOrder__c = 12;
        CDRMutualFunds[0].EffectiveDate__c = datetime.newInstance(2000,1,1);
        try
        {
            insert CDRMutualFunds[0];
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 

        // Try to insert a record where there is already one with that effective date
        CDRMutualFunds[0].EffectiveDate__c = datetime.newInstance(2011,1,1);
        try
        {
            insert CDRMutualFunds[0];
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is another row with the exact same Effective Date; please change the Effective Date on this record') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stopTest();
        
        for (CDRQualitativeData__c check : [SELECT Id, SortOrder__c, Status__c, NextStagingDate__c, NextPendingActivationDate__c, HistoricalDate__c
                                            FROM CDRQualitativeData__c
                                            WHERE SortOrder__c != 0]) {
                                                
                                                if (check.SortOrder__c == 10) system.assertequals('Historical', check.Status__c);
                                                if (check.SortOrder__c == 20) system.assertequals(datetime.newInstance(2034,1,1), check.NextStagingDate__c);
                                                if (check.SortOrder__c == 70) system.assertequals(null, check.NextStagingDate__c);
                                                if (check.SortOrder__c == 80) system.assertequals('Draft', check.Status__c);                                                
                                                if (check.SortOrder__c == 90) system.assertequals('Inactive', check.Status__c);   
                                                if (check.SortOrder__c == 110) system.assertequals(datetime.newInstance(2030,1,1), check.NextPendingActivationDate__c);
                                                if (check.SortOrder__c == 180) system.assertequals(null, check.NextPendingActivationDate__c);
                                                if (check.SortOrder__c == 190) system.assertequals(null, check.NextPendingActivationDate__c);
                                                if (check.SortOrder__c == 190) system.assertequals(null, check.NextStagingDate__c);
                                                
                                            }
        
    }
    
}