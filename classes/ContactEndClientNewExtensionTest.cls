@isTest
public class ContactEndClientNewExtensionTest {
    
    static testMethod void ContactEndClientNewTest() 
    
    {
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        User ecu = [SELECT Id from User WHERE Username LIKE 'portalnatixis@ngam.natixis.com%' LIMIT 1];
        
        ExternalCommunitySettings__c settings = new ExternalCommunitySettings__c(name = 'EstatementCommunity',
                                                                                 EndClientCommunityAccountName__c = 'eStatementFirmName',
                                                                                 PotalUserName__c = 'portalnatixis@ngam.natixis.com',
                                                                                 AccountPrefix__c = 'EstatementCommunity',
                                                                                 EndClientOwnerId__c = ecu.Id);
        insert settings;
        
        List<Account> firms = DataFactory.createTestFirms(1);
        firms[0].Name = 'eStatementFirmName';
        insert firms;
        
        Id endClientRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        Contact objContact = new Contact(FirstName = 'Test', LastName='Test', RecordTypeId = endClientRecordTypeId, Email='foo@foo.com');
        insert objContact;
        
        Test.startTest();
        Test.setCurrentPage(Page.ContactEndClientNew);
        ApexPages.currentPage().getParameters().put('FirstName', 'EC First Name');
        ApexPages.currentPage().getParameters().put('LastName', 'EC Last Name');
        ApexPages.StandardController stdContact = new ApexPages.StandardController(objContact);
        ContactEndClientNewExtension controller = new ContactEndClientNewExtension(stdContact);
        controller.SaveEndClient();
        PageReference n = controller.nextPage();        
        Test.stopTest();    
    }    
    
    
}