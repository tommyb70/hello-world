@isTest
public class WCMRelationshipAccountSyncBatchTest {
    
    @isTest static void test() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id; 
        
        List<Account> level1Firms = DataFactory.createTestFirms(2);
        level1Firms[0].WCMRelationshipFlag__c = FALSE;
        level1Firms[1].WCMRelationshipFlag__c = FALSE;
        level1Firms[0].Name = 'level1Firms[0]';
        level1Firms[1].Name = 'level1Firms[1]';
        insert level1Firms;   
        
        List<Account> level2Firms = DataFactory.createTestFirms(1);
        level2Firms[0].ParentId = level1Firms[0].Id;
        level2Firms[0].Name = 'level2Firms[0]';
        level2Firms[0].MARSAccountId__c = 'MARSACCTID1';        
        insert level2Firms;   
        
        List<Account> level3offices = DataFactory.createTestAccounts(4);
        level3offices[0].ParentId = level2Firms[0].Id; 
        level3offices[1].ParentId = level2Firms[0].Id;
        level3offices[2].ParentId = level1Firms[0].Id;
        level3offices[3].ParentId = level1Firms[1].Id;
        level3offices[0].Name = 'level3offices[0]'; 
        level3offices[1].Name = 'level3offices[1]'; 
        level3offices[2].Name = 'level3offices[2]'; 
        level3offices[3].Name = 'level3offices[3]'; 
        insert level3offices;   
        
        List<Account> level4offices = DataFactory.createTestAccounts(4);
        level4offices[0].ParentId = level3offices[0].Id;
        level4offices[1].ParentId = level3offices[0].Id;
        level4offices[2].ParentId = level3offices[1].Id;
        level4offices[3].ParentId = level3offices[2].Id;
        level4offices[0].Name = 'level4offices[0]'; 
        level4offices[1].Name = 'level4offices[1]'; 
        level4offices[2].Name = 'level4offices[2]'; 
        level4offices[3].Name = 'level4offices[3]'; 
        insert level4offices;   
        
        List<Account> level5offices = DataFactory.createTestAccounts(4);
        level5offices[0].ParentId = level4offices[0].Id;
        level5offices[1].ParentId = level4offices[0].Id;
        level5offices[2].ParentId = level4offices[1].Id;
        level5offices[3].ParentId = level4offices[1].Id;
        level5offices[0].Name = 'level5offices[0]'; 
        level5offices[1].Name = 'level5offices[1]'; 
        level5offices[2].Name = 'level5offices[2]'; 
        level5offices[3].Name = 'level5offices[3]'; 
        
        insert level5offices;        
        
        level1Firms[0].WCMRelationshipFlag__c = true;
        update level1Firms;
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new WCMRelationshipAccountSyncBatch());
        Test.stopTest();
        
        List<Account> checkTrue = [SELECT Id, Name, WCMRelationshipFlag__c FROM Account WHERE Id = :level3offices[0].Id];
        List<Account> checkFalse = [SELECT Id, Name, WCMRelationshipFlag__c FROM Account WHERE Id = :level3Offices[3].Id];
        
        system.assertEquals(checkTrue[0].WCMRelationshipFlag__c,TRUE,'WCM should be TRUE');
        system.assertEquals(checkFalse[0].WCMRelationshipFlag__c,FALSE,'WCM should be FALSE');
        
        }
        
    }