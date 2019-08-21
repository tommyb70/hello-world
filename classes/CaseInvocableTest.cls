@isTest
public class CaseInvocableTest {
    
    @isTest
    public static void validateInvocable(){
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        //Profile p = [select id from profile where name='System Administrator']; 
        //Profile pSales = [select id from profile where name='NGAM Integration'];
        
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id, 
                                        ProfileIntegration__c, 
                                        ProfileSystemAdministrator__c from NGAMSettings__c limit 1];
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileIntegration__c);
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, ActivityTerritoryType__c = 'Region',
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u) {
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = p, ActivityTerritoryType__c = 'Region',
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0');    
            
            insert u0;                   
            
            //Creating the Territory
            Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test',RoleID__c = '',GroupID__c = '',TerritoryType__c = 'Region'); 
            insert Terr;        
            
            Territory__c Terr2 = new Territory__c(Name='Test2',TerritoryName__c='Test2',RoleID__c = '',GroupID__c = '',TerritoryType__c = 'Territory', ParentTerritory__c = Terr.Id); 
            insert Terr2;        


            // Creating the Corresponding Role
            UserRole Ur = new UserRole();
            Ur.Name = Terr.Name;
            Ur.DeveloperName = Terr.Id;
            Ur.CaseAccessForAccountOwner = 'Read';
            Ur.OpportunityAccessForAccountOwner = 'Read';
            Ur.ContactAccessForAccountOwner = 'Read';
            insert Ur;
            
            UserRole Ur2 = new UserRole();
            Ur2.Name = Terr2.Name;
            Ur2.DeveloperName = Terr2.Id;
            Ur2.CaseAccessForAccountOwner = 'Read';
            Ur2.OpportunityAccessForAccountOwner = 'Read';
            Ur2.ContactAccessForAccountOwner = 'Read';
            insert Ur2; 

            Group urGroup=[select id from group where RelatedId =:ur.id][0];                     
            Group urGroup2=[select id from group where RelatedId =:ur2.id][0];                     
            
            // Creating the Corresponding Group
            Group Gr = new Group();
            Gr.name = Terr.Name;
            Gr.DeveloperName = Terr.Id;
            Gr.Type = 'Regular';
            insert Gr;     

            Group Gr2 = new Group();
            Gr2.name = Terr2.Name;
            Gr2.DeveloperName = Terr2.Id;
            Gr2.Type = 'Regular';
            insert Gr2;     

            Territory__Share TsR = new  Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup.id,ParentId=terr.id );    
            insert TsR;      

            Territory__Share TsR2 = new  Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup2.id,ParentId=terr2.id );    
            insert TsR2;      
            
            //Territory__c uTerr = new Territory__c(id=Terr.id,RoleID__c = ur.id,GroupID__c = gr.id ); 
            Terr.RoleID__c = ur.id;
            Terr.RoleGroupId__c = urGroup.id;
            Terr.GroupID__c = gr.id;    
            update Terr;
            
            Terr2.RoleID__c = ur2.id;
            Terr2.RoleGroupId__c = urGroup2.id;
            Terr2.GroupID__c = gr2.id;    
            update Terr2;
            
            List<zone__c> AllZones = DataFactory.createAllZones();
            List<UserTerritory__c> ut = new List<UserTerritory__c>();
            
            ut.add(new  UserTerritory__c(user__c=u0.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true,  Zoning__c=AllZones.get(0).id));  
            ut.add(new  UserTerritory__c(user__c=u.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true,  Zoning__c=AllZones.get(0).id));              
            insert ut; 
            
            Account a = new Account(Name = 'TestAccount');
            insert a;    
            
            List<Case> cases = new List<Case>();
            cases.add(new Case(ownerid= u0.id, AccountId = a.Id, Requestor__c = u0.id, SubmittedOnBehalfOf__c = u.Id));
            insert cases;
            
            RunCaseAssignmentRules.runCaseAssignmentRules(cases);
            RunCaseSharing.runCaseSharing(cases);
            
        }         
        
    }
    
}