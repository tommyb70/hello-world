@isTest

private class CaseTriggerHandler_Test {
    static testMethod void CaseTriggerHandlerValidateAll() {

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        Id affRequestRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Affiliate Request').getRecordTypeId();
        Id IPMRFPRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RFP').getRecordTypeId();
        Id AffiliateRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();
        Id PWPRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId();

        
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id, 
                                        ProfileIntegration__c, 
                                        ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 

        List<Case> caseList = new List<case>();
        //Profile p = [select id from profile where name='System Administrator']; 
        //Profile pSales = [select id from profile where name='NGAM Integration']; 
        string sysAdminId = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileIntegration__c);
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = sysAdminId, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        //insert u;
        System.runAs(u){
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = sysAdminId, 
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0');    
            
            insert u0;                   
            
            //Creating the Territory
            Territory__c Region = new Territory__c(Name='1-Region',TerritoryName__c='Region',RoleID__c = '',GroupID__c = '',TerritoryType__c = 'Region'); 
            insert Region;        
            Territory__c Terr = new Territory__c(Name='2-Territory',TerritoryName__c='Territory',RoleID__c = '',GroupID__c = '', TerritoryType__c = 'Territory', ParentTerritory__c = Region.Id); 
            insert Terr;        
            
            // Creating the Corresponding Role
            List<UserRole> Ur = new List<UserRole>(); 
            
            Ur.add(new UserRole(Name = Terr.Name, 
                                DeveloperName = Terr.Id, 
                                CaseAccessForAccountOwner = 'Read', 
                                OpportunityAccessForAccountOwner = 'Read',
                                ContactAccessForAccountOwner = 'Read'));
            
            Ur.add(new UserRole(Name = Region.Name, 
                                DeveloperName = Region.Id, 
                                CaseAccessForAccountOwner = 'Read', 
                                OpportunityAccessForAccountOwner = 'Read',
                                ContactAccessForAccountOwner = 'Read'));
            insert Ur;   
            
            List<Group> urGroup = [SELECT Id FROM Group WHERE RelatedId in : Ur ORDER BY Name];
            
            // Creating the Corresponding Group
            List<Group> Gr = new List<Group>();
            Gr.add(new Group(Name = Terr.Name,DeveloperName = Terr.Id,Type = 'Regular'));
            Gr.add(new Group(Name = Region.Name,DeveloperName = Region.Id,Type = 'Regular'));
            insert Gr;     

            List<Territory__Share> TsR = new List<Territory__Share>();            
            TsR.add(new Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup[1].id,ParentId=terr.id));
            TsR.add(new Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup[0].id,ParentId=terr.id));
            insert TsR;      
            
            //Territory__c uTerr = new Territory__c(id=Terr.id,RoleID__c = ur.id,GroupID__c = gr.id ); 
            Terr.RoleID__c = ur[0].id;
            Terr.RoleGroupId__c = urGroup[1].id;
            Terr.GroupID__c = gr[0].id;    
            update Terr;
            
            Region.RoleID__c = ur[1].id;
            Region.RoleGroupId__c = urGroup[0].id;
            Region.GroupID__c = gr[1].id;    
            update Region;

            List<zone__c> AllZones = DataFactory.createAllZones();
            
            UserTerritory__c ut0 = new  UserTerritory__c(user__c=u0.id, territory__c=Region.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true,  Zoning__c=AllZones.get(0).id);  
            insert ut0; 
            
            system.debug ('u0.UserRoleId' + u0.UserRoleId);
            Account a = new Account(Name = 'TestAccount');
            insert a;   
            
            List<Account> affiliates = DataFactory.createTestFirms(1);
            affiliates[0].RecordTypeId = AffiliateRecTypeId;
            insert affiliates;
            
            List<Product2> products = DataFactory.createProduct2(1, 'Test');
            products[0].MARSAffiliate__c = affiliates[0].Id;
            insert products;

            
            List<Case> cases = new List<Case>();
            cases.add(new Case(RecordTypeId = affRequestRecTypeId,ownerid= u0.id, AccountId = a.Id, Requestor__c = u0.id, RunCaseSharing__c = TRUE, RunCaseAssignmentRules__c = TRUE));
            cases.add(new Case(RecordTypeId = IPMRFPRecTypeId,ownerid= u0.id, AccountId = a.Id, ProductStrategyMutualFund__c = products[0].Id, Requestor__c = u0.id, RunCaseSharing__c = TRUE, RunCaseAssignmentRules__c = TRUE));
            cases.add(new Case(RecordTypeId = PWPRecTypeId, AccountId = a.Id, Type = 'Account Opening'));
            insert cases;
            caseList.addAll(cases);
            Caseshare cs2 = new caseshare(caseid = cases[0].id, UserOrGroupId = Gr[1].id,  CaseAccessLevel= 'Edit');
            insert cs2;
            
            //CaseTriggerHandler.CaseTriggerAfterInsert(caseList);
            
        }         
    }
    
    /*static testMethod void CaseTriggerHandlerValidateAll2() {
        List<Case> caseList = new List<case>();
        set<id> caseIds = new set<id>();
        Case cs;
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id, 
                                        ProfileIntegration__c, 
                                        ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 

        string sysAdminId = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileIntegration__c);

        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        //insert u;
        System.runAs(u) 
        {
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = p, 
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0');    
            
            insert u0;
            
            system.debug('u0======'+u0);
            
            User u2 = new User(alias = 's02', email='Sales02@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing02', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales02@ngam.natixis.com',UserID__c='Sales02');    
            
            insert u2;                
            
            //Creating the Territory
            Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test',RoleID__c = '',GroupID__c = ''); 
            insert Terr;                     
            
            // Creating the Corresponding Role
            UserRole Ur = new UserRole();
            Ur.Name = Terr.Name;
            Ur.DeveloperName = Terr.Id;
            Ur.CaseAccessForAccountOwner = 'Read';
            Ur.OpportunityAccessForAccountOwner = 'Read';
            Ur.ContactAccessForAccountOwner = 'Read';
            insert Ur;   
            
            Group urGroup=[select id from group where RelatedId =:ur.id][0];
            
            // Creating the Corresponding Group
            Group Gr = new Group();
            Gr.name = Terr.Name;
            Gr.DeveloperName = Terr.Id;
            Gr.Type = 'Regular';
            insert Gr;     
            
            Territory__Share TsR = new  Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup.id,ParentId=terr.id );    
            insert TsR;      
            
            //Territory__c uTerr = new Territory__c(id=Terr.id,RoleID__c = ur.id,GroupID__c = gr.id ); 
            Terr.RoleID__c = ur.id;
            Terr.RoleGroupId__c = urGroup.id;
            Terr.GroupID__c = gr.id;    
            update Terr;
            
            List<zone__c> AllZones = DataFactory.createAllZones();
            
            UserTerritory__c ut0 = new  UserTerritory__c(user__c=u0.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true,  Zoning__c=AllZones.get(0).id);  
            
            insert ut0; 
            
            Map<String,Schema.RecordTypeInfo> RecordTypesByName = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
            
            Account a = new Account(Name = 'TestAccount');
            insert a;
            System.debug('Account Id:  '+a.Id);
            id rtypeid = [Select id, developername, sobjecttype from recordtype where sobjecttype = 'Case' and IsActive = TRUE LIMIT 1].id;                       
            
            system.debug ('rtypeid========' +rtypeid);
            system.debug ('rtypeid========' +rtypeid);
            system.debug ('u0========' +u0);
            system.debug ('u2========' +u2);
            Case Case1 = new Case(ownerid= u0.id,recordtypeid =rtypeid, Requestor__c = u0.id, AccountId = a.Id) ;
            
            insert Case1; 
            
            system.debug('Hello::::'+Case1.Id);
            List<case> csrec = [Select id,recordtype.DeveloperName, Requestor__c, AccountId from case where id =: Case1.id];
            
            system.debug('Hello1');
            system.debug('csrec size: '+csrec.size());
            system.debug('csrec[0]::::::'+csrec[0]);
            
            Caseshare cs2 = new caseshare(caseid = csrec[0].id, UserOrGroupId = Gr.id,  CaseAccessLevel= 'Edit');
            insert cs2;
            csrec[0].ownerid = u2.id;
            
            Update csrec[0];
            caseList.add(csrec[0]); 
            System.debug('caseList size:'+caseList.size());
            System.debug('csrec::::::'+csrec[0]);
            CaseTriggerHandler.CaseTriggerAfterUpdate(caseList); 
            
        }
        
    }*/
    
}