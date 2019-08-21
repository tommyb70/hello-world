@isTest
public class CDRRollbackStatusExtTest {
    
    @testSetup static void setupTestData() { 
      DataFactory.CreateNGAMCustomSettings(); 
    }
    
        static testMethod void myTests() {
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     OverrideTriggerValidations__c = TRUE,
                                                     OverrideSetStatusOnCreate__c = TRUE);
        insert settings;
        
        Id nullId;
        
        List<Product2> products = DataFactory.createProduct2(6,'CDR Test');
        products[0].Name = 'Product 0';
        products[1].Name = 'Product 1';
        products[2].Name = 'Product 2';
        products[3].Name = 'Product 3';
        products[4].Name = 'Product 4';
        products[5].Name = 'Product 5';        
        insert products;
        
        List<CDRQualitativeData__c> cdrs = new List<CDRQualitativeData__c>();
        
        List<CDRQualitativeData__c> CDR1 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[0].Id, nullId);
        CDR1[0].Status__c = 'Draft';
        CDR1[0].SortOrder__c = 10;
        CDR1[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR1[0]);
        
        List<CDRQualitativeData__c> CDR2 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[1].Id, nullId);
        CDR2[0].Status__c = 'Staging';
        CDR2[0].SortOrder__c = 20;
        CDR2[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR2[0]);
        
        List<CDRQualitativeData__c> CDR3 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[2].Id, nullId);
        CDR3[0].Status__c = 'Historical';
        CDR3[0].SortOrder__c = 30;
        CDR3[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR3[0]);
        
        List<CDRQualitativeData__c> CDR4 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[3].Id, nullId);
        CDR4[0].Status__c = 'Staging';
        CDR4[0].SortOrder__c = 40;
        CDR4[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR4[0]);

        List<CDRQualitativeData__c> CDR5 = DataFactory.createCDRQualitativeData (1, 'Mutual Fund', products[4].Id, nullId);
        CDR5[0].Status__c = 'Inactive';
        CDR5[0].SortOrder__c = 50;
        CDR5[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        cdrs.add(CDR5[0]);
        
        List<CDRQualitativeData__c> CDR6 = DataFactory.createCDRQualitativeData (2, 'Mutual Fund', products[5].Id, nullId);
        CDR6[0].SortOrder__c = 60;
        CDR6[0].Status__c = 'Historical';
        CDR6[0].EffectiveDate__c = datetime.newInstance(1977,1,1);
        CDR6[1].SortOrder__c = 61;
        CDR6[1].Status__c = 'Historical';
        CDR6[1].EffectiveDate__c = datetime.newInstance(1976,1,1);
        cdrs.addAll(CDR6);
        Test.startTest();
        insert cdrs;        
        
       
        Test.setCurrentPage(Page.CDRRollbackStatus);
        CDRRollbackStatusExt CDR10 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR1[0]));
        
        CDR10.autoRun();
        CDR10.cancelChange();
        CDR10.autoRun();
        try
        {
            CDR10.changeStatus();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Records in') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        CDRRollbackStatusExt CDR20 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR2[0]));
        CDR20.autoRun();
        CDR20.changeStatus();
        CDR20.frameErrorMessage('errorNew');
        
        CDRRollbackStatusExt CDR30 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR3[0]));
        CDR30.autoRun();
        CDR30.changeStatus();
        
         Test.stopTest();
        
        
        CDRRollbackStatusExt CDR50 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR5[0]));
        CDR50.autoRun();
        CDR50.changeStatus();
        
        CDRRollbackStatusExt CDR60 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR6[1]));
        CDR60.autoRun();        
        try
        {
            CDR60.changeStatus();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You can only rollback the most recent Historical record') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        //Profile p = [select id from profile where (name = 'NGAM Integration') and UserType = 'Standard' LIMIT 1]; 
             NGAMSettings__c ngamSettings = [select id,ProfileIntegration__c from NGAMSettings__c limit 1]; 

            string p = Util.getCustomSettingProfileId(ngamSettings.ProfileIntegration__c); 
            User u = new User(alias = 'standt', email='SFDCuser@ngam.natixis.com', 
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = p, 
                           timezonesidkey='America/Los_Angeles', username='SFDCuser@ngam.natixis.com',UserID__c='SFDCuser');
        
        System.runAs(u) {
            
            CDRRollbackStatusExt CDR40 = new CDRRollbackStatusExt(new ApexPages.StandardController(CDR4[0]));
            CDR40.autoRun();        
            try
            {
                CDR40.changeStatus();
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Only the Owner or a System Administrator') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
           
        }
        
       
    }
    
}