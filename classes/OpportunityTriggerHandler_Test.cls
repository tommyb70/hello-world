@isTest
private class OpportunityTriggerHandler_Test {
    static testMethod void ValidateAll() {
    
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
        //insert u;
        System.runAs(u) 
        {
            List<Territory__c> territories = new List<Territory__c>();
            territories.add(new Territory__c(Name='Test',TerritoryName__c='Test',RoleID__c = '',GroupID__c = '',TerritoryType__c='Territory'));
            territories.add(new Territory__c(Name='Test2',TerritoryName__c='Test2',RoleID__c = '',GroupID__c = '',TerritoryType__c='Region'));
            territories.add(new Territory__c(Name='Test2',TerritoryName__c='Test3',RoleID__c = '',GroupID__c = '',TerritoryType__c='Company'));            
            insert territories;
            
            List<UserRole> userRoles = new List<UserRole>();
            UserRole ur1 = new UserRole(Name = territories[0].Name, DeveloperName = territories[0].Id, 
                                       CaseAccessForAccountOwner = 'Read', OpportunityAccessForAccountOwner = 'Read',
                                       ContactAccessForAccountOwner = 'Read');
            UserRoles.add(ur1);
            UserRole ur2 = new UserRole(Name = territories[1].Name, DeveloperName = territories[1].Id, 
                                       CaseAccessForAccountOwner = 'Read', OpportunityAccessForAccountOwner = 'Read',
                                       ContactAccessForAccountOwner = 'Read');
            userRoles.add(ur2);
            UserRole ur3 = new UserRole(Name = territories[1].Name, DeveloperName = territories[2].Id, 
                                       CaseAccessForAccountOwner = 'Read', OpportunityAccessForAccountOwner = 'Read',
                                       ContactAccessForAccountOwner = 'Read');
            userRoles.add(ur3);
            insert userRoles;

            Map<Id,Id> territoryGroupMap = new Map<Id,Id>();
            
            Group userGroup1=[SELECT Id FROM Group 
                              WHERE RelatedId = :userRoles[0].Id 
                              AND Type = 'RoleAndSubordinates'];
            
            Group userGroup2=[SELECT Id FROM Group 
                              WHERE RelatedId = :userRoles[1].Id 
                              AND Type = 'RoleAndSubordinates'];
            
            Group userGroup3=[SELECT Id FROM Group 
                              WHERE RelatedId = :userRoles[2].Id 
                              AND Type = 'RoleAndSubordinates'];

			List<Territory__Share> territoryShares = new List<Territory__Share>();          
            territoryShares.add(new Territory__Share(AccessLevel='Read',UserOrGroupId=userGroup1.Id,ParentId=territories[0].Id));
            territoryShares.add(new Territory__Share(AccessLevel='Read',UserOrGroupId=userGroup2.Id,ParentId=territories[1].Id));
            territoryShares.add(new Territory__Share(AccessLevel='Read',UserOrGroupId=userGroup3.Id,ParentId=territories[2].Id));
            insert territoryShares;   
            
            territories[0].RoleID__c = userRoles[0].Id;
            territories[0].RoleGroupId__c = userGroup1.id;
            territories[1].RoleID__c = userRoles[1].Id;
            territories[1].RoleGroupId__c = userGroup2.id;    
            territories[2].RoleID__c = userRoles[2].Id;
            territories[2].RoleGroupId__c = userGroup3.id;    
            update territories;
            
            u.ActivityTerritoryId__c = territories[0].id;
            u.ActivityTerritoryParentId__c = territories[1].id;
            u.ActivityTerritoryType__c = territories[0].TerritoryType__c;
            u.ActivityTerritoryMARSName__c = territories[0].TerritoryName__c;
            u.ActivityTerritoryRoleGroupId__c = territories[0].RoleGroupId__c;
            u.ActivityTerritoryRoleId__c = territories[0].RoleId__c;
            update u;

            List<Account> accts = DataFactory.createTestAccounts(1);
            insert accts;
            
            List<Contact> contacts = DataFactory.createTestContacts(3, accts, FALSE);
            insert contacts;
            
			List<Opportunity> opptys = new List<Opportunity>();
            opptys.add(new Opportunity(Name='test', AccountId=accts[0].Id, StageName='Prospect', CloseDate=system.today()));
            opptys.add(new Opportunity(Name='test2', AccountId=accts[0].Id, RepContact__c = contacts[0].Id,
                                       StageName='Prospect', CloseDate=system.today()));
			insert opptys;
            
            opptys[0].RepContact__c = contacts[0].Id;
            opptys[1].RepContact__c = contacts[1].Id;
            update opptys;
            
            opptys[0].RepContact__c = contacts[1].Id;
            opptys[1].RepContact__c = contacts[0].Id;
            update opptys;
            
        }
    }
}