@isTest
private class CampaignTriggerHandler_Test {
    static testMethod void CampaignTriggerHandlerValidateAll() {

        //Profile pSales = [select id from profile where name='NGAM Sales Wirehouse'];ProfileSales__c 
        //Profile p = [select id from profile where name='System Administrator']; 
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        string pSales = Util.getCustomSettingProfileId(ngamSettings.ProfileSales__c);

       User u2 = new User(alias = 'standt', email='SFDCadminZ@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadminZ@ngam.natixis.com',UserID__c='SFDCadminZ', ActivityTerritoryId__c='a022A00000WVtRLQA1');
        //insert u;
        System.runAs(u2){
                User u0 = new User(alias = 's0', email='Sales0@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing0', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = pSales, 
                            timezonesidkey='America/Los_Angeles', username='Sales0@ngam.natixis.com',UserID__c='Sales0');    

                insert u0;
                    
                //Creating the Territory
                Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test',RoleID__c = '',GroupID__c = ''); 
                insert Terr; 
                    
                //Creating the Territory
                Territory__c Terr2 = new Territory__c(Name='Test2',TerritoryName__c='Test2',RoleID__c = '',GroupID__c = ''); 
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
                    
                Campaign Camp1 = new Campaign(name='test 1', type='Call Campaign',ownerid=u0.id);
                insert Camp1;
                delete Camp1;
                    
                Campaign Camp2 = new Campaign(name='test 1', type='Static List',ownerid=u0.id);
                insert Camp2;
                delete Camp2; 
               }
        }
}