@isTest 
private class UserHelperClass_Test { 

    @testSetup static void setupTestData() { 
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin'); 
        
        insert u2;     
    } 
    
    public static user frameUser(string pId,string email,string username,string alias,string zoneid){ 
        User u = new User(alias = alias, email=email, 
                        emailencodingkey='UTF-8', lastname='Testing001', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = pId, 
                        timezonesidkey='America/Los_Angeles', username=username ,UserID__c='SFDCadmin001'); 
        u.ActivityZoneId__c = zoneid; 
        return u; 
    } 
    
    public static Zone__c frameZone(string name){ 
        Zone__c z=new Zone__c(Name =name, Zone__c=12); 
        return z; 
    } 
    
    static testMethod void IsMRDTest() { 
    
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean MRD = false; 
            
            Zone__c z=frameZone('MRD Zone'); 
            insert z; 
            
            List<Zone__c> zones = [select id , name, Zone__c from Zone__c where Name like 'MRD%']; 
            if( zones != null && zones.size() > 0){ 
                String zoneid = zones[0].id; 
                string emailPassed = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailPassed,emailPassed,'standt',zoneid); 
                insert u; 
                MRD = UserHelperClass.IsMRD(u.Id); 
            } 
            Test.stopTest(); 
            //System.assertNotEquals(false, MRD ); 
        } 
    } 
    
    // IsVip 
    static testMethod void IsVipTest() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsVip= false; 
            User u3 = frameUser(p,'SFDCadmin123@ngam.natixis.com','SFDCadmin123@ngam.natixis.com','vipsta',null); 
            u3.VIP__c=true; 
            insert u3; 
            
            List<User> users = [select ID, ZoneNumber__c, ZoneID__c, ZoneLabel__c from User where VIP__c = true LIMIT 1 ]; 
            if( users != null && users.size() > 0){ 
            	IsVip= UserHelperClass.IsVip(users[0].Id); 
            } 
            Test.stopTest(); 
            System.assertNotEquals(false, IsVip); 
        } 
    } 
    
    // IsIC 
    static testMethod void IsICTest() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsIC= false; 
            
            Zone__c z=frameZone('IC Zone'); 
            insert z; 
            
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like 'IC%' ]; 
            if( zones != null && zones.size() > 0){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsIC= UserHelperClass.IsIC(u.Id); 
            } 
            Test.stopTest(); 
            //System.assertNotEquals(false, IsIC); 
        } 
    } 
    
    // IsInbound 
    static testMethod void IsInboundTest(){ 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsInbound = false; 
            
            Zone__c z=frameZone('Inbound Zone'); 
            insert z; 
            
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like 'Inbound%' ]; 
            if( zones != null && zones.size() > 0){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsInbound = UserHelperClass.IsInbound(u.Id); 
            } 
            Test.stopTest(); 
            // System.assertNotEquals(false, IsInbound); 
        } 
    } 
    
    // IsRD 
    static testMethod void IsRDTest() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsRD = false; 
            
            Zone__c z=frameZone('RD Zone'); 
            insert z; 
            
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like 'RD%']; 
            if( zones != null && zones.size() > 0){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsRD = UserHelperClass.IsRD(u.Id); 
            } 
            Test.stopTest(); 
            // System.assertNotEquals(false, IsRD); 
        } 
    } 
    
    // isIC or inbound 
    static testMethod void IsIC_Inbound() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsIC= false; 
            
            Zone__c z=frameZone('Inbound Zone'); 
            insert z; 
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like 'Inbound%']; 
            if( zones != null && zones.size() > 0){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsIC= UserHelperClass.IsIC_Inbound(u.Id); 
            } 
            Test.stopTest(); 
            //System.assertNotEquals(false, IsIC); 
        } 
    } 
    
    // isIC or inbound 
    static testMethod void IsMD() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsIC= false; 
            
            Zone__c z=frameZone('MD Zone'); 
            insert z; 
            
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like'MD%']; 
            if( zones != null && zones.size() > 0){ 
                //List<User> users = [select ID, ZoneNumber__c, ZoneID__c, ZoneLabel__c, ActivityZoneId__c from User where ActivityZoneId__c=:zones[0].id] ; 
                //if( users != null){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsIC= UserHelperClass.IsMD(u.Id); 
                //} 
            } 
            Test.stopTest(); 
            //System.assertNotEquals(false, IsIC); 
        } 
    } 
    
    static testMethod void IsDir() { 
        user u2 = [select id from user where email=:'SFDCadmin@ngam.natixis.com' limit 1]; 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
        System.runAs(u2){ 
            Test.StartTest(); 
            boolean IsIC= false; 
            
            Zone__c z=frameZone('DIR Zone'); 
            insert z; 
            List<Zone__c> zones = [select id , name,Zone__c from Zone__c where name like 'DIR%']; 
            if( zones != null && zones.size() > 0){ 
                string emailId = 'SFDCadmin'+'001'+'@ngam.natixis.com'; 
                User u = frameUser(p,emailId,emailId,'standt',zones[0].Id); 
                insert u; 
                IsIC= UserHelperClass.IsDir(u.Id); 
            } 
            Test.stopTest(); 
            //System.assertNotEquals(false, IsIC); 
        } 
    } 
}