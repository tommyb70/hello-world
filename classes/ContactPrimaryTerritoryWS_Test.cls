@isTest 
private class ContactPrimaryTerritoryWS_Test {
    static testMethod void ContactPrimaryTerritoryWSTesting() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;


       //Profile p = [select id from profile where name='System Administrator'];
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
 
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = p, 
                    timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2)  { 
            /*User ngamUser = new User(alias = 'nuser', email='nuser@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='User', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='nuser@ngam.natixis.com',UserID__c='nuser');
                            
            insert(ngamUser);*/
            
            //Creating WHSE Territory
            Territory__c whseTerr = new Territory__c(Name='WHSE BOSTON METRO',TerritoryName__c='WHSE BOSTON METRO', TerritoryType__c = 'Territory'); 
            insert whseTerr; 
                
            // Creating the Corresponding Role
            UserRole Ur = new UserRole();
            Ur.Name = whseTerr.Name;
            Ur.DeveloperName = whseTerr.Id;
            Ur.CaseAccessForAccountOwner = 'Read';
            Ur.OpportunityAccessForAccountOwner = 'Read';
            Ur.ContactAccessForAccountOwner = 'Read';
            insert Ur; 
                
            Group UrGroup = [select id, relatedid from group where relatedid=:Ur.id limit 1][0];    
            
            Territory__Share TsR = new  Territory__Share(AccessLevel='Read',UserOrGroupId=urGroup.id,ParentId=whseTerr.id );    
            insert TsR;  
            
            // Creating the Corresponding Group
            Group Gr = new Group();
            Gr.name = whseTerr.Name;
            Gr.DeveloperName = whseTerr.Id;
            Gr.Type = 'Regular';
            insert Gr;                              
            
            whseTerr.RoleID__c = ur.id;   
            whseTerr.RoleGroupId__c = UrGroup.id; 
            whseTerr.GroupID__c = gr.id; 
            update whseTerr;  
            
            List<Account> myA = DataFactory.createTestAccounts(1);
            insert myA;
                               
            //Create the contact                  
            Contact myC = new Contact(FirstName = 'test', LastName ='user', MarsRepId__c='111',AccountId=myA[0].Id) ;   
            insert MyC; 
            
            //Create WHSE contact territory
            //ContactTerritory__c whseCT = new  ContactTerritory__c(contact__c =MyC.id, territory__c=whseTerr.id, ContactTerrId__c = 'FR231176A507' );
            //insert whseCT;
               
            // Testing Contact Share WS    
            RestRequest reqC = new RestRequest(); 
            RestResponse resC = new RestResponse();
            reqC.requestURI = '/services/apexrest/ContactPrimaryTerritory/*';  
            reqC.httpMethod = 'POST';
            RestContext.request = reqC;
            RestContext.response = resC;  
            List<id> ComWSC = ContactPrimaryTerritoryWS.ComputeSharing(system.now()+1);                      
        }
    }
}