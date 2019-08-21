@istest
public class ContactTriggerHandlerTest {

    // Could not write coverage for Vestmark Email change due to issues with setting up community user records
    
    static testmethod void test() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        Id ECrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        Id CRrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Rep/Contact').getRecordTypeId();    
        
        DataFactory.insertEstatementCommunityCustomSettings();
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        
        List<Account> a = DataFactory.createTestAccounts(1);
        insert a;
        
        List<Account> f = DataFactory.createTestFirms(3);
        f[0].Name = myCustomSetting.EndClientCommunityAccountName__c;
        f[1].Name = 'ParentParentFirm-MS';
        f[2].Name = 'ParentFirm-AA';
        insert f;
        
        Account LG = new Account(Name='ParentFirm-LG', ParentId = f[1].Id);
        insert LG;
        Account LGoffice = new Account(Name='Office-LG', ParentId = LG.Id);
        insert LGoffice;
        Account AAoffice = new Account(Name='Office-AA', ParentId = f[2].Id);
        insert AAoffice;
        
        List<Contact> contacts = DataFactory.createTestContacts(10, a, FALSE);
        for (Contact c : contacts) {
            c.RecordTypeId = CRrecordTypeId; 
        }
        //Vestmark Email
        contacts[0].RecordTypeId = ECrecordTypeId;
        contacts[0].VestmarkEmail__c = 'test1@foo.com';
        contacts[0].AccountId = null;
        
        //Firm Name Text
        contacts[1].AccountId = LGoffice.Id;
        contacts[1].LastName = 'Test-MS';
        contacts[2].AccountId = AAoffice.Id;
        contacts[2].LastName = 'Test-AA';
        contacts[9].HasOptedOutOfEmail = TRUE;
        insert contacts;
        
        List<Contact> contactCheck = [SELECT LastName, FirmNameText__c from Contact];
        List<Account> accountCheck = [SELECT Id, Name, PrivateWealth__c FROM Account];
        
        for (Contact c : contactCheck) {
            if (c.LastName == 'Test-MS') system.assertEquals(c.FirmNameText__c,'ParentParentFirm-MS');
            if (c.LastName == 'Test-AA') system.assertEquals(c.FirmNameText__c,'ParentFirm-AA');
        }
        
        contacts[0].VestmarkEmail__c = 'test2@foo.com';
        contacts[2].AccountId = LGoffice.Id;
        contacts[1].AccountId = AAoffice.Id;
        
        //Email Preferences
        //No Emails
        contacts[3].SnoozeEmails__c = TRUE;
        contacts[3].HasOptedOutOfEmail = TRUE;
        contacts[3].Email = '';
        contacts[3].pi__pardot_hard_bounced__c = TRUE;
        //All Emails
        contacts[4].Email = 'foo@foo.com';
        //Mixed Opt-in and Opt-out
        contacts[5].Email = 'foo@foo.com';
        contacts[5].PardotPrefCenterOptOut1__c = TRUE;
        contacts[6].Email = 'foo@foo.com';
        contacts[6].PardotPrefCenterOptOut2__c = TRUE;
        contacts[7].Email = 'foo@foo.com';
        contacts[7].PardotPrefCenterOptOut3__c = TRUE;
        contacts[8].Email = 'foo@foo.com';
        contacts[8].PardotPrefCenterOptOut4__c = TRUE;
        contacts[9].Email = 'foo@foo.com';
        contacts[9].InitiateEmailOptIn__c = TRUE;
        

        update contacts;

        List<Contact> contactCheck2 = [SELECT LastName, FirmNameText__c from Contact];
        for (Contact c : contactCheck2) {
            if (c.LastName == 'Test-MS') system.assertEquals(c.FirmNameText__c,'ParentFirm-AA');
            if (c.LastName == 'Test-AA') system.assertEquals(c.FirmNameText__c,'ParentParentFirm-MS');
        }
        
    }
    
}