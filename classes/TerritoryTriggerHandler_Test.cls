@isTest
private class TerritoryTriggerHandler_Test {
    static testMethod void ValidateAll() {
        
        //Profile p = [select id from profile where name='System Administrator']; 
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileSales__c);
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u) 
        {
            
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0', RoleProxy__c=null,UserRoleid=null);   
            insert u0;


            //Territory__c myTerr = [Select Id, Name, RoleId__c, Code__c FROM Territory__c where ChildrenCount__c=0 LIMIT 1];
            
            //Creating the Territory
            Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test'); 
            insert Terr; 
            
            // Creating the Corresponding Role
            UserRole Ur = new UserRole();
            Ur.Name = Terr.Name;
            Ur.DeveloperName = Terr.Id;
            Ur.CaseAccessForAccountOwner = 'Read';
            Ur.OpportunityAccessForAccountOwner = 'Read';
            Ur.ContactAccessForAccountOwner = 'Read';
            insert Ur;   
            
            // Creating the Corresponding Group
            Group Gr = new Group();
            Gr.name = Terr.Name;
            Gr.DeveloperName = Terr.Id;
            Gr.Type = 'Regular';
            insert Gr;     
            
            Terr.RoleID__c = ur.id;
            Terr.GroupID__c = gr.id;    
            update Terr;     
            
            // Child Territory
            Territory__c TerrChild = new Territory__c(Name='TestCHild',TerritoryName__c='TestCHild', ParentTerritory__c=Terr.id); 
            insert TerrChild; 
            //TerrChild.
            
            // Creating the Corresponding Role
            UserRole UrChild = new UserRole();
            UrChild.Name = TerrChild.Name;
            UrChild.DeveloperName = TerrChild.Id;
            UrChild.CaseAccessForAccountOwner = 'Read';
            UrChild.OpportunityAccessForAccountOwner = 'Read';
            UrChild.ContactAccessForAccountOwner = 'Read';
            insert UrChild;   
            
            // Creating the Corresponding Group
            Group GrChild = new Group();
            GrChild.name = TerrChild.Name;
            GrChild.DeveloperName = TerrChild.Id;
            GrChild.Type = 'Regular';
            insert GrChild;     

            TerrChild.RoleID__c = UrChild.id;
            TerrChild.GroupID__c = GrChild.id;    
            update Terr; 

            List<zone__c> AllZones = DataFactory.createAllZones();
            
            
            //system.debug('0 position allzone :' + AllZones.get(0).id);
            Test.startTest();       
            List<UserTerritory__c> newUserTerr = new List<UserTerritory__c>();    
            //test.startTest();
            UserTerritory__c ut0 = new  UserTerritory__c(user__c=u0.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true, Zoning__c=AllZones.get(0).id);  
            newUserTerr.add(ut0);  
			insert newUserTerr;

            TerrChild.RoleID__c = Urchild.id;
            TerrChild.GroupID__c = Grchild.id;  
            update TerrChild;    

            Terr.Name = 'TestChildRename';
            Terr.Touch__c = 'TRUE';
            update Terr;

            
            //TerrChild.RoleID__c = '';
            //TerrChild.GroupID__c = '';
            //update TerrChild;   
            
            //TerrChild.RoleID__c = Urchild.id;
            //TerrChild.GroupID__c = Grchild.id;   
            //update TerrChild;    
            
            /*delete GrChild;
            delete UrChild;  
            delete TerrChild;  
            
            delete Gr;
            delete Ur;  
            delete Terr; */   
            
            
        }
        
    }
    
}