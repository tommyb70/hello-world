@isTest(SeeAllData=true)
private class WebsiteContact_Test {
   //DataFactory.CreateNGAMCustomSettings(); 
 static NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
static string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
    
    static testMethod void getAndCreateContactTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator']; 
       
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create Web account   
            
            // un-commented on 07/02 : starts here
            try {         
            Account a = new Account(Name='test', MarsAccountID__c='OF882244',  RecordType = new RecordType (Name='Office'));
            insert a;
            system.debug('Acc:'+a.Id);      
            }
            catch(Exception e) {
            system.debug('Account:'+ e.getMessage());
            }
            // un-commented on 07/02 : ends here
            
            // Commented on 07/02 : starts here
            //List<Account> myA = DataFactory.createTestAccounts(1);
            //insert myA;
             // Commented on 07/02 : ends here
              
            // Create addcontact post request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.FirstName = 'test';
            c.LastName = 'web';
            c.Email = 'test.web@test.com';
    
            req.requestURI = '/services/apexrest/websitecreatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.addContact(c);
            System.debug('resp1:' + results);             
            System.assert(results.ContactId != null, 'Contact added');
            
            String id = results.ContactId;
            
            // Create getcontact get request by email
            req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('email', 'test.web@test.com');
            req.addParameter('loginmethod', 'Website');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            results = WebsiteContactCreateService.getContact();
            System.debug('resp2:' + results);             
            System.assert(results.Status == 'Success', 'Found the contact'); 
            
             // Create getcontact get request by id
            req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('id', id);
            req.addParameter('loginmethod', 'LinkedIn');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            results = WebsiteContactCreateService.getContact();
            System.debug('resp3:' + results);             
            System.assert(results.Status == 'Success', 'Found the contact');     
            
            // Create getContactSalesTeam get request
            req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websiteupdatecontact';
            req.addParameter('id', id);
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            results = WebsiteContactUpdateService.getSalesTeam();
            System.debug('resp4:' + results);             
            System.assert(results.Status == 'Success', 'No contact sales Team found');   
            
             // Create updatecontact post request
            req = new RestRequest(); 
            res = new RestResponse();
            
            c = new WebsiteContactCreateService.WebContact();
            c.id = id;
            c.verified = true; 
            c.ContactIdCookieValue = 'test';         
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            results = WebsiteContactUpdateService.updateContact(c);
            System.debug('resp8:' + results);             
            System.assert(results.ContactId != null, 'Contact updated');
                  
        }
    }

    static testMethod void contactNotFoundByEmailTest() {

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;        
        
        //Profile p = [select id from profile where name='System Administrator']; 
      
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
            // Create getcontact get request by email
            RestRequest req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('email', 'test.web@test.com');
            req.addParameter('loginmethod', 'Website');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.getContact();
            System.debug('resp5:' + results);             
            System.assert(results.Status == 'Error', 'contact not found'); 
        }
    }
    
    static testMethod void contactNotFoundByIdTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator'];
       
 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
            // Create getcontact get request by email
            RestRequest req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('id', '1234');
            req.addParameter('loginmethod', 'Website');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.getContact();
            System.debug('resp6:' + results);             
            System.assert(results.Status == 'Error', 'contact not found'); 
        }
    }
    
    static testMethod void contactFoundWithNoWebProfileTest() {

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;        
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
         
            
            // Added 07/02 -starts here
             try {         
            Account a = new Account(Name='test', MarsAccountID__c='OFXXXX123',  RecordType = new RecordType (Name='Office'));
            insert a;
            system.debug('Acc:'+a.Id);      
            }
            catch(Exception e) {
            system.debug('Account:'+ e.getMessage());
            }
            // Added 07/02 - ends here
           
            Contact c = new Contact (FirstName='t', LastName = 't', Email = 't.t@ngam.natixis.com', Phone='0000000000', CrdId__c='123', 
                            Account=new Account(MarsAccountId__c = 'OFXXXX123'), MarsRepId__c='22', MailingStateCode='CA');
            insert c;
            
            system.debug('hh:');
            // Create getcontact get request by email
            RestRequest req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('email', 't.t@ngam.natixis.com');
            req.addParameter('loginmethod', 'Website');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            system.debug('gg:');
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.getContact();
            System.debug('resp7:' + results);             
            System.assert(results.Status == 'Success', 'contact found'); 
        }
    }
    
    static testMethod void getContactEmailNotSpecifiedTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create getcontact get request by email
            RestRequest req = new RestRequest();                   
            req.requestURI = '/services/apexrest/websitecreatecontact';
            req.addParameter('loginmethod', 'Website');  
            req.httpMethod = 'GET';            
            RestContext.request = req;
            
            system.debug('gg:');
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.getContact();
            System.debug('resp7:' + results);             
            System.assert(results.Status == 'Error', 'No email specified'); 
        }
    }
    
     static testMethod void createContactFirstNameNotSpecifiedTest() {
         
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
         
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create addcontact post request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.LastName = 'web';
            c.Email = 'test.web@test.com';            
    
            req.requestURI = '/services/apexrest/websitecreatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactCreateService.addContact(c);
            System.debug('resp1:' + results);             
            System.assert(results.Status == 'Error', 'First Name not specified');
        }
    }
    
    static testMethod void updateContactWithoutIdTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create addcontact post request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.verified = true; 
            c.ContactIdCookieValue = 'test';         
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;            
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.updateContact(c);                      
            System.assert(results.Status == 'Error', 'Contact Id needs to be specified');
       }
    }
    
    static testMethod void updateContactWithVerifiedFalseTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;        
        
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create addcontact post request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.Id = '1234';
            c.verified = false;    
            c.ContactIdCookieValue = 'test';      
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.updateContact(c);                      
            System.assert(results.Status == 'Error', 'Verfied is not true');
       }
    }
    
     static testMethod void updateContactWithNoCookieAndVerifiedTest() {
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) { 
        
            // Create addcontact post request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.Id = '1234';                 
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.updateContact(c);                      
            System.assert(results.Status == 'Error', 'Verfied and Cookie are not present');
       }
    }
    
    
     static testMethod void getSalesTeamTest() {
         
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
         
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) {
            // ADU user
            User aduUser = new User(alias = 'wic', email='wic@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='IC', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='wic@ngam.natixis.com',UserID__c='wic');
                            
            insert(aduUser);
            
            // RADU user
            User raduUser = new User(alias = 'radu', email='radu@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='IC', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='radu@ngam.natixis.com',UserID__c='radu');
                            
            insert(raduUser);      

            //Create the contact     
            List<Account> myA = DataFactory.createTestAccounts(1);
            insert myA;
                                    
            Contact myC = new Contact(FirstName = 'test', LastName ='user', MarsRepId__c='111', PrimaryTerritory__c = 'IDU', 
                               OverlapTerritory__C = 'RADU', PrimaryMarketingUser__c = aduUser.Id, OverlapExternalUser__c = raduUser.Id,AccountId=myA[0].Id);   
            insert MyC;    
        
            // Create getSalesTeam get request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();                
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.addParameter('id', MyC.Id);  
            req.httpMethod = 'GET';            
            RestContext.request = req;            
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.getSalesTeam();                      
            System.assert(results.Status == 'Success', 'Found Sales Team');
       }
    }
    
    static testMethod void getSalesTeamWithNoContactIdTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) {
                   
            // Create getSalesTeam get request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();                
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';              
            req.httpMethod = 'GET';            
            RestContext.request = req;            
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.getSalesTeam();                      
            System.assert(results.Status == 'Error', 'contact id not specified');
       }
    }
    
    static testMethod void updateContactWithInvalidContactTest() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;        
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) {
                   
            // Create getSalesTeam get request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();        
    
            WebsiteContactCreateService.WebContact c = new WebsiteContactCreateService.WebContact();
            c.Id = '1234';
            c.verified = true; 
            c.ContactIdCookieValue = 'test';          
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.updateContact(c);                      
            System.assert(results.Status == 'Error', 'contact is not found');
       }
    }
    
    static testMethod void updateContactWithInvalidContactWebProfileTest() {

        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE; 
        hsettings.ByPassEventCampMemberValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        
        //Profile p = [select id from profile where name='System Administrator']; 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        System.runAs(u2) {
            
            // Added 07/02 -starts here
             try {         
            Account a = new Account(Name='test', MarsAccountID__c='OFXXXX123',  RecordType = new RecordType (Name='Office'));
            insert a;
            system.debug('Acc:'+a.Id);      
            }
            catch(Exception e) {
            system.debug('Account:'+ e.getMessage());
            }
            // Added 07/02 - ends here
                
            Contact c = new Contact (FirstName='t', LastName = 't', Email = 't.t@ngam.natixis.com', Phone='0000000000', CrdId__c='123', 
                            Account=new Account(MarsAccountId__c = 'OFXXXX123'), MarsRepId__c='22', MailingStateCode='CA');
            insert c;
                   
            // Create getSalesTeam get request
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();        
    
            WebsiteContactCreateService.WebContact wc = new WebsiteContactCreateService.WebContact();
            wc.Id = c.id;
            wc.verified = true;  
            wc.ContactIdCookieValue = 'test';        
    
            req.requestURI = '/services/apexrest/websiteupdatecontact';  
            req.httpMethod = 'POST';            
            RestContext.request = req;
            
            WebsiteContactCreateService.Response results = WebsiteContactUpdateService.updateContact(wc);                      
            System.assert(results.Status == 'Error', 'contact is not found');
       }
    }
}