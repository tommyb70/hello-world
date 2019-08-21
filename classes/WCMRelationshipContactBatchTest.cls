@isTest
public class WCMRelationshipContactBatchTest {
    
    @isTest static void test() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id; 
        
        List<Account> accts1 = DataFactory.createTestAccounts(1);
        accts1[0].WCMRelationshipFlag__c = FALSE;
        insert accts1;
        
        List<Account> accts2 = DataFactory.createTestAccounts(1);
        accts2[0].WCMRelationshipFlag__c = FALSE;
        insert accts2;        
        
        List<Contact> contacts1 = DataFactory.createTestContacts(2, accts1, False);
        insert contacts1;
        List<Contact> contacts2 = DataFactory.createTestContacts(2, accts2, False);
        insert contacts2;
        
        accts1[0].WCMRelationshipFlag__c = TRUE;
        update accts1;
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new WCMRelationshipContactSyncBatch());
        Test.stopTest();
        
        List<Contact> checkTrue = [SELECT Id, Name, WCMRelationshipFlag__c FROM Contact WHERE Id = :contacts1[0].Id];
        List<Contact> checkFalse = [SELECT Id, Name, WCMRelationshipFlag__c FROM Contact WHERE Id = :contacts2[0].Id];
        
        system.assertEquals(checkTrue[0].WCMRelationshipFlag__c,TRUE,'WCM should be TRUE');
        system.assertEquals(checkFalse[0].WCMRelationshipFlag__c,FALSE,'WCM should be FALSE');
        
        
        }
        
    }