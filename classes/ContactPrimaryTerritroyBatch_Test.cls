@isTest
private class ContactPrimaryTerritroyBatch_Test {
    static testMethod void ContactPrimaryTerritoryBatchTesting() {
    
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
        
        System.runAs(u2) {
            //Insert test users
            /*User ngamUser = new User(alias = 'nuser', email='nuser@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='User', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='nuser@ngam.natixis.com',UserID__c='nuser');
                            
            insert(ngamUser);*/
            
            // WHSE IC user
            User user = new User(alias = 'wic', email='wic@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='IC', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='wic@ngam.natixis.com',UserID__c='wic');
                            
            insert(user);                       

            //create channel
            Channel__c aduChannel = new Channel__c(ChannelName__c='ADU', Name='ADU');
            insert aduChannel;    
                    
            //Creating ADU Territory
            Territory__c aduTerr = new Territory__c(Name='ADU NORTHWEST',TerritoryName__c='ADU NORTHWEST', TerritoryType__c = 'Territory', Channel__c = aduChannel.id,
                                     Wholesaler1__c = user.Id); 
            insert aduTerr; 
            
                         
            // Creating the Corresponding Role
            UserRole Ur = new UserRole();
            Ur.Name = aduTerr.Name;
            Ur.DeveloperName = aduTerr.Id;
            Ur.CaseAccessForAccountOwner = 'Read';
            Ur.OpportunityAccessForAccountOwner = 'Read';
            Ur.ContactAccessForAccountOwner = 'Read';
            insert Ur; 
                
            Group UrGroup = [select id, relatedid from group where relatedid=:Ur.id limit 1][0];    
            
            aduTerr.RoleID__c = ur.id;   
            aduTerr.RoleGroupId__c = UrGroup.id;                
            update aduTerr;  
            
            //Creating RADU Territory
            Territory__c raduTerr = new Territory__c(Name='RADU NORTHWEST',TerritoryName__c='RADU NORTHWEST', TerritoryType__c = 'Region',
                                     Wholesaler1__c = user.Id); 
            insert raduTerr; 
                
            // Creating the Corresponding Role
            UserRole Ur6 = new UserRole();
            Ur6.Name = raduTerr.Name;
            Ur6.DeveloperName = raduTerr.Id;
            Ur6.CaseAccessForAccountOwner = 'Read';
            Ur6.OpportunityAccessForAccountOwner = 'Read';
            Ur6.ContactAccessForAccountOwner = 'Read';
            insert Ur6; 
                
            Group UrGroup6 = [select id, relatedid from group where relatedid=:Ur6.id limit 1][0];    
            
            raduTerr.RoleID__c = ur6.id;   
            raduTerr.RoleGroupId__c = UrGroup6.id;    
            update raduTerr;    
                                    
            //Creating RCDU Territory
            Territory__c rcduTerr = new Territory__c(Name='RCDU DIRECT',TerritoryName__c='RCDU DIRECT', TerritoryType__c = 'Territory'); 
            insert rcduTerr; 
                
            // Creating the Corresponding Role
            UserRole Ur5 = new UserRole();
            Ur5.Name = rcduTerr.Name;
            Ur5.DeveloperName = rcduTerr.Id;
            Ur5.CaseAccessForAccountOwner = 'Read';
            Ur5.OpportunityAccessForAccountOwner = 'Read';
            Ur5.ContactAccessForAccountOwner = 'Read';
            insert Ur5; 
                
            Group UrGroup5 = [select id, relatedid from group where relatedid=:Ur5.id limit 1][0];    
            
            rcduTerr.RoleID__c = ur5.id;   
            rcduTerr.RoleGroupId__c = UrGroup5.id;    
            update rcduTerr;                             
             
            //Create Zones
            Zone__c icZone = new Zone__c(Name='IC', zone__c = 5);
            insert icZone;
            Zone__c rd1Zone = new Zone__c(Name='RD1', zone__c = 2);
            insert rd1Zone;
            Zone__c mrdZone = new Zone__c(Name='MRD', zone__c = 1);
            insert mrdZone;

            List<Account> myA = DataFactory.createTestAccounts(1);
            insert myA;
            
            //Create the contact                  
            Contact myC = new Contact(FirstName = 'test', LastName ='user', MarsRepId__c='111',AccountId=myA[0].Id) ;   
            insert MyC; 
            
            //Create the contact                  
            Contact myC1 = new Contact(FirstName = 'test1', LastName ='user', MarsRepId__c='222', ZoneRCDU__r = mrdZone,AccountId=myA[0].Id);   
            insert myC1;
            
            //Create the contact                  
            Contact myC2 = new Contact(FirstName = 'test2', LastName ='user', MarsRepId__c='333',AccountId=myA[0].Id);   
            insert myC2;
                   
            //Create the contact                  
            Contact myC3 = new Contact(FirstName = 'test3', LastName ='user', MarsRepId__c='444',AccountId=myA[0].Id);   
            insert myC3; 
           
            //Create ADU contact territory
            ContactTerritory__c aduCT = new  ContactTerritory__c(contact__c =MyC.id, territory__c=aduTerr.id, territory__r=aduTerr, ContactTerrId__c = 'FR231176A507' );
            insert aduCT;             
            //Create RADU contact territory
            ContactTerritory__c raduCT = new  ContactTerritory__c(contact__c =MyC.id, territory__c=raduTerr.id, territory__r=raduTerr, ContactTerrId__c = 'FR231176A509' );
            insert raduCT; 
                       
            //Create RCDU contact1 territory
            ContactTerritory__c rcduCT1 = new  ContactTerritory__c(contact__c =MyC1.id, territory__c=rcduTerr.id, ContactTerrId__c = 'FR231176A510');
            insert rcduCT1; 
                        
            //Create Whse User Territories                      
            UserTerritory__c rcduICUT = new  UserTerritory__c(territory__c =rcduTerr.id, user__c = user.Id, zoning__c = mrdZone.Id, ActivityTerritory__c = true);
            insert rcduICUT; 
            UserTerritory__c rcduRD1UT = new  UserTerritory__c(territory__c =rcduTerr.id, user__c = user.Id, zoning__c = rd1Zone.Id, ActivityTerritory__c = true);
            insert rcduRD1UT;            
            
                                  
            Test.StartTest();                  
              
            string query = 'select Id, MarsRepId__c, PrimaryTerritory__c, PrimaryTerritoryLookup__r.TerritoryName__c, PrimaryRegion__c, PrimaryMarketingUser__r.UserId__c,FullServiceSalesUser__r.UserId__c,OverlapTerritory__c,OverlapExternalUser__r.UserId__c from contact where MarsRepId__c in (\'' +111 +'\', \'' +222 +'\', \'' +333 +'\', \'' +444 +'\')';
            ContactPrimaryTerritoryBatch job = new ContactPrimaryTerritoryBatch(query);
            Database.executeBatch(job);                  
            
            test.stopTest();
                
            contact c = [select PrimaryTerritory__c from contact where MarsRepId__c = '111'];
            
            System.assertEquals('ADU NORTHWEST', c.PrimaryTerritory__c);                                                
                 
        }
    } 
}