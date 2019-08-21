@isTest 
private class UserData_Test {
    static testMethod void IsVipTest() { 
    
         //Profile p = [select id from profile where name='System Administrator'];
         DataFactory.CreateNGAMCustomSettings(); 
         NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
         string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);

         User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = p, 
                        timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
            
        System.runAs(u2){ 
    
        UserData u = new UserData();
        Test.StartTest();
        boolean isVip = u.IsVip;
        Test.stopTest();
        System.assertNotEquals(true, isVip); 
        }   
    }
    
    static testMethod void IsMDTest() { 
    
        // Profile p = [select id from profile where name='System Administrator']; 
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);

         User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = p, 
                        timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
                        
        System.runAs(u2){ 
        
        Zone__c z = new Zone__c(Name = 'MD', zone__c = 24);
        insert z;
        
        u2.ActivityZoneId__c = z.id;
        update u2; 
           
        UserData u = new UserData();
        Test.StartTest();  
        boolean isMd = u.isMD;      
        Test.stopTest();
        System.assertEquals(true, isMd); 
        }   
    }
}