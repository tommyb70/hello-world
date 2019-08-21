@isTest
private class UpdateProspectInPardot_Test{
        
    
    @isTest 
    static void UpdateProspectOptoutInPardotByEmailTest() {

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
        
        System.runAs(u2) 
        {
            // Intitialize the settings
            PardotSettings__c ps1 = new PardotSettings__c();
            ps1.Name = 'LoginUrl';
            ps1.Value__c = 'https://pi.pardot.com/api/login/version/3';
            insert ps1;
            
            PardotSettings__c ps2 = new PardotSettings__c();
            ps2.Name = 'Email';
            ps2.Value__c = 'test@ngam.natixis.com';
            insert ps2;
            
            PardotSettings__c ps3 = new PardotSettings__c();
            ps3.Name = 'Password';
            ps3.Value__c = 'test';
            insert ps3;
            
            PardotSettings__c ps4 = new PardotSettings__c();
            ps4.Name = 'UserKey';
            ps4.Value__c = 'test';
            insert ps4;
            
            PardotSettings__c ps5 = new PardotSettings__c();
            ps5.Name = 'LoginBody';
            ps5.Value__c = 'email={0}&password={1}&user_key={2}';
            insert ps5;
            
            PardotSettings__c ps6 = new PardotSettings__c();
            ps6.Name = 'UpdateUrl';
            ps6.Value__c = 'https://pi.pardot.com/api/{0}/version/3/do/update/{1}/{2}';
            insert ps6;
            
                        
            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and
            // include response body in a static resource.   
            //MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
            //multimock.setStaticResource('https://pi.pardot.com/api/login/version/3', 'PardotLoginResponse');
            //multimock.setStaticResource('https://pi.pardot.com/api/Prospect/version/3/do/update/Email/test@ngam.natixis.com', 'PardotUpdateResponse');
            //multimock.setStatusCode(200);
            //multimock.setHeader('Content-Type', 'text/xml');
            
            // Set the mock callout mode    
            Test.setMock(HttpCalloutMock.class, new UpdateProspectInPardot_Mock());
            
            Test.startTest();
            // Call the method for the second endpoint
            UpdateProspectInPardot.UpdateProspectOptoutInPardotByEmail('test@ngam.natixis.com', true);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void UpdateProspectOptoutInPardotByEmailTest_InvalidAction() {
    
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
        
        System.runAs(u2) 
        {
            // Intitialize the settings
            PardotSettings__c ps1 = new PardotSettings__c();
            ps1.Name = 'LoginUrl';
            ps1.Value__c = 'https://pi.pardot.com/api/login/version/3';
            insert ps1;
            
            PardotSettings__c ps2 = new PardotSettings__c();
            ps2.Name = 'Email';
            ps2.Value__c = 'test@ngam.natixis.com';
            insert ps2;
            
            PardotSettings__c ps3 = new PardotSettings__c();
            ps3.Name = 'Password';
            ps3.Value__c = 'test';
            insert ps3;
            
            PardotSettings__c ps4 = new PardotSettings__c();
            ps4.Name = 'UserKey';
            ps4.Value__c = 'test';
            insert ps4;
            
            PardotSettings__c ps5 = new PardotSettings__c();
            ps5.Name = 'LoginBody';
            ps5.Value__c = 'email={0}&password={1}&user_key={2}';
            insert ps5;
            
            PardotSettings__c ps6 = new PardotSettings__c();
            ps6.Name = 'UpdateUrl';
            ps6.Value__c = 'https://pi.pardot.com/api/Prospect/version/3/do/update/email';
            insert ps6;                                             
            
            // Set the mock callout mode    
            Test.setMock(HttpCalloutMock.class, new UpdateProspectInPardot_Mock());
            
            Test.startTest();
            // Call the method for the third endpoint
            UpdateProspectInPardot.UpdateProspectOptoutInPardotByEmail('test@ngam.natixis.com', true);
            Test.stopTest();            
        }
    }
}