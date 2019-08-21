@isTest
private class SL_TerritoryToggleButton_Test {
    static testMethod void ValidateAll() {
        
        //Profile p = [select id from profile where name='System Administrator']; 
        //Profile pSales = [select id from profile where name='NGAM Sales Wirehouse'];
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
       string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileSales__c);
 
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        //insert u;
        System.runAs(u) 
        {   
            //Test.startTest();   
            //List<Zone__c> myZones = DataFactory.createAllZones();
            
            User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0', RoleProxy__c=null,UserRoleid=null);    
            User u1 = new User(alias = 's1', email='Sales1@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales1@ngam.natixis.com',UserID__c='Sales1'); 
            User u2 = new User(alias = 's2', email='Sales2@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales2@ngam.natixis.com',UserID__c='Sales2'); 
            User u3 = new User(alias = 's3', email='Sales3@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales3@ngam.natixis.com',UserID__c='Sales3');  
            User u5 = new User(alias = 's5', email='Sales5@ngam.natixis.com', 
                               emailencodingkey='UTF-8', lastname='Testing5', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = pSales, 
                               timezonesidkey='America/Los_Angeles', username='Sales5@ngam.natixis.com',UserID__c='Sales5');  
            insert u0;
            insert u1;
            insert u2;
            insert u3;
            //insert u5;
            //Territory__c myTerr = [Select Id, Name, RoleId__c, Code__c FROM Territory__c where ChildrenCount__c=0 LIMIT 1];

            //Creating the Territory
            Channel__c channel = new Channel__c(Name='TestChannel',ChannelName__c='TestChannel');
            insert channel;
            
            Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test',RoleID__c = '',GroupID__c = '',TerritoryType__c = 'Territory',Channel__c=Channel.Id); 
            insert Terr; 
            
            //Creating the Territory
            Territory__c Terr2 = new Territory__c(Name='Test2',TerritoryName__c='Test2',RoleID__c = '',GroupID__c = '',TerritoryType__c = 'Territory',Channel__c=Channel.Id); 
            insert Terr2; 
            
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
            //Group Gr = new Group();
            //Gr.name = Terr.Name;
            //Gr.DeveloperName = Terr.Id;
            //Gr.Type = 'Regular';
            //insert Gr;     
            
            Territory__Share TsR = new  Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup.id,ParentId=terr.id );    
            insert TsR;      
            
            //Territory__c uTerr = new Territory__c(id=Terr.id,RoleID__c = ur.id,GroupID__c = gr.id ); 
            Terr.RoleID__c = ur.id;
            Terr.RoleGroupId__c = urGroup.id;
            //Terr.GroupID__c = gr.id;    
            update Terr;
            
            List<zone__c> AllZones = DataFactory.createAllZones();
            
            
            //system.debug('0 position allzone :' + AllZones.get(0).id);
            Test.startTest();       
            List<UserTerritory__c> newUserTerr = new List<UserTerritory__c>();    
            //test.startTest();
            UserTerritory__c ut0 = new  UserTerritory__c(user__c=u0.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true, Zoning__c=AllZones.get(0).id);  
            newUserTerr.add(ut0);  
            //insert ut0;
            //test.stopTest();
            
            //system.debug (ur.id + '   '+  u0.id+ '   '+  u0.userrole.name);
            
            //UserTerritoryTriggerHandler.run = true;    
            UserTerritory__c ut1 = new  UserTerritory__c(user__c=u0.id, territory__c=Terr.Id, PrimaryTerritory__c=false, ActivityTerritory__c=false, Zoning__c=AllZones.get(1).id);  
            newUserTerr.add(ut1); 
            //insert ut1; 
            
            //UserTerritoryTriggerHandler.run = true;
            UserTerritory__c ut2 = new  UserTerritory__c(user__c=u2.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true, Zoning__c=AllZones.get(2).id);  
            newUserTerr.add(ut2);  
            //insert ut2;
            
            //UserTerritoryTriggerHandler.run = true;    
            UserTerritory__c ut3 = new  UserTerritory__c(user__c=u3.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true, Zoning__c=AllZones.get(3).id);  
            newUserTerr.add(ut3);  
            //insert ut3;
            
            
            //UserTerritoryTriggerHandler.run = true;  
            //UserTerritory__c ut5 = new  UserTerritory__c(user__c=u5.id, territory__c=Terr.Id, PrimaryTerritory__c=true, ActivityTerritory__c=true, Zoning__c=AllZones.get(4).id);     
            //newUserTerr.add(ut5);   
            //insert ut5;
            
            insert newUserTerr;
            //Test.stopTest();    

            system.debug('u1' + u1.UserRoleId);
            system.debug('u2' + u2.UserRoleId);
            system.debug('u3' + u3.UserRoleId);
            system.debug('u5' + u5.UserRoleId);
            
            // Testing SL_TerritoryToggleButton Controller
            
            SL_TerritoryToggleButton controller = new SL_TerritoryToggleButton();
            SL_TerritoryToggleButton.getUserTerritory();
            SL_TerritoryToggleButton.getUserPrimTerritory();
            SL_TerritoryToggleButton.getIsShowMe();
            SL_TerritoryToggleButton.btnApply(ut0.id);

        }
    }
}