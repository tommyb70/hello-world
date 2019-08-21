@isTest
public class AccountTriggerHandlerTest {
    
    static testmethod void AccountTriggerHandlerTest() {
        
        Id firmRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Firm').getRecordTypeId();
        Id officeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;
        
        List<Account> firms = DataFactory.createTestFirms(2);
        firms[0].Name = 'firms[0]';
        firms[0].WCMRelationshipFlag__c = TRUE;
        firms[0].Type = 'Firm';
        firms[0].FirmType__c = 'FIRMTYPE';
        firms[0].RecordTypeId = firmRecTypeId;
        firms[1].Name = 'firms[1]';
        firms[1].WCMRelationshipFlag__c = FALSE;
        firms[1].Type = 'Firm';
        firms[1].RecordTypeId = firmRecTypeId;        
        insert firms;   
        
        List<Account> homeoffices = DataFactory.createTestAccounts(2);
        homeoffices[0].Name = 'homeoffices[0]';
        homeoffices[0].RecordTypeId = officeRecTypeId;
        homeoffices[0].Type = 'Home';
        homeoffices[0].ParentId = firms[0].Id;
        homeoffices[1].Name = 'homeoffices[1]';
        homeoffices[1].RecordTypeId = officeRecTypeId;
        homeoffices[1].Type = 'Home';
        homeoffices[1].ParentId = firms[1].Id;
        insert homeoffices;
        
        homeoffices[0].MarsAccountId__c = 'MARS12345';
        homeoffices[1].MarsAccountId__c = 'MARS54321';
        update homeoffices;
        
        List<Account> asserts = [SELECT Id, Name, WCMRelationshipFlag__c, HomeOfficeId__c, FirmType__c FROM Account];
        
        for (Account a : asserts) {
            SWITCH ON a.Name {
                
                WHEN 'firms[0]' {
                    system.assertEquals(a.HomeOfficeId__c,'MARS12345','Set HomeOfficeId__c');    
                }                
                
                WHEN 'firms[1]' {
                    system.assertEquals(a.HomeOfficeId__c,'MARS54321','Set HomeOfficeId__c');
                }                
                
                WHEN 'homeoffices[0]' {
                    system.assertEquals(a.WCMRelationshipFlag__c, TRUE ,'Set WCMRelationshipFlag__c');
                    system.assertEquals(a.FirmType__c, 'FIRMTYPE','Set FirmType__c');
                }                
                
                WHEN 'homeoffices[1]' {
                    system.assertEquals(a.WCMRelationshipFlag__c, FALSE ,'Set WCMRelationshipFlag__c');
                }                
                
            }
            
        }
        
    }
    
}