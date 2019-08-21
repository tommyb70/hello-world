@isTest
public class TableauVFTest {
    
    @testSetup
    static void testSetup() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        NGAMSettings__c settings = new NGAMSettings__c(Name = 'NGAM_ALL',
                                                       TableauQADomain__c = 'vizbiqa.ngam.natixis.com',
                                                       TableauProductionDomain__c = 'vizbi.ngam.natixis.com');
        insert settings;
        
    }
    
    @isTest
    static void contactTest() {
        
        List<Account> a = DataFactory.createTestAccounts(1);
        insert a;
        
        List<Contact> c = DataFactory.createTestContacts(1, a, FALSE);
        insert c;
        
        Test.startTest();
        Test.setCurrentPage(Page.TableauContactAdvisorClientProfile);
        TableauVFExtension tvfe = new TableauVFExtension(new ApexPages.StandardController(c[0]));
        Test.stopTest();
        
    }

    @isTest
    static void tabTest() {
        
        Test.startTest();
        Test.setCurrentPage(Page.TableauTabAllTrades);
        TableauVFController tvfe = new TableauVFController();
        tvfe.gettableauDomain();
        Test.stopTest();
        
    }    
    
}