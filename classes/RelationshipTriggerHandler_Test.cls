@isTest
private class RelationshipTriggerHandler_Test {

    static testMethod void RelationshipTriggerHandlerInsert() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

       // Profile p = [select id from profile where name='System Administrator']; 
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
                          
        System.runAs(u) {
            Account f = new account(MarsAccountId__c = '12', Name='test1');
            insert f;
            
            Account a = new account(MarsAccountId__c = '11', Name='test', Parent = f);
            insert a;
            
            // create test contacts
            contact ct = new contact(MarsRepID__c = '1111', FirstName = 'user1', LastName = 'test1', TranYTDPurchases__c = 100.0, TranPYPurchases__c = 200.0, Account = a,AccountId=a.Id);
            ct.RecordType = new RecordType( Name='Team' );
            insert ct;
            
            contact c = new contact(MarsRepID__c = '2222', FirstName = 'user', LastName = 'test', TranYTDPurchases__c = 10.0, TranPYPurchases__c = 50.0, Account = a,AccountId=a.Id);
            c.RecordType = new RecordType( Name='Rep/Contact' );
            insert c;
                        
            // create test relationships
            List<npe4__Relationship__c> rs = new List<npe4__Relationship__c>();
            npe4__Relationship__c r = new npe4__Relationship__c();
            r.TeamRepId__c='1';
            r.npe4__Type__c = 'Team Individual';
            r.npe4__Contact__r = new contact(MarsRepId__c = ct.MarsRepId__c);
            r.npe4__RelatedContact__r = new contact(MarsRepId__c = c.MarsRepId__c);
            rs.add(r);   
            insert rs;  
            
            npe4__Relationship__c rl = [Select Id,  ContactYTDPurchases__c from npe4__Relationship__c where teamrepId__c = '1' limit 1];
            system.assert(ct.TranYTDPurchases__c == rl.ContactYTDPurchases__c, 'successfull');        
        }   
    }    
}