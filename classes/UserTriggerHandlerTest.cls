@isTest(SeeAllData=TRUE)
private class UserTriggerHandlerTest { 

/*    @testSetup static void setupTestData() { 
        DataFactory.CreateNGAMCustomSettings(); 
        User sysAdmin = DataFactory.createSystemAdminUser();   
        insert sysAdmin;  
    }*/ 
       
    static testMethod void ValidateInsert() {     
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];  
        NGAMSettings__c ngamSettings = [select id, ProfileStandardUser__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileStandardUser__c); 
        
        User u = new User(Alias = 'standt', 
                            Email='stysfgf@natixis.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p, 
                            userid__c='test35', 
                            TimeZoneSidKey='America/Los_Angeles', UserName='fhdgyus@natixis.com');         
        
        insert u; 
    } 
    
    static testMethod void ValidateUpdate() {
        
        NGAMSettings__c ngamSettings = [select id, ProfileSystemAdministrator__c, ProfileForInactiveUsers__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        string p2 = Util.getCustomSettingProfileId(ngamSettings.ProfileForInactiveUsers__c); 
        List<User> usersToUpdate = new List<User>();
        string currentUser = userinfo.getuserId(); 
        User u = [SELECT IsActive, Id FROM User WHERE IsActive = TRUE AND UserType = 'Standard' AND ProfileId =:p and Id !=:currentUser  LIMIT 1]; 
        StaticResource theStaticResource = [SELECT id, Body FROM StaticResource WHERE name = :'UserPictureTest' limit 1]; 
        u.Picture__c = theStaticResource.body.toString(); 
        u.IsActive = FALSE; 
        usersToUpdate.add(u); 
        User u2 = [SELECT IsActive, Id FROM User WHERE IsActive = FALSE AND UserType = 'Standard' AND ProfileId =:p2 AND Id !=:u.Id and Id !=:currentUser  LIMIT 1];  
        u2.IsActive = TRUE;
        u2.Picture__c = '';
        usersToUpdate.add(u2);
        update usersToUpdate;
    } 

    @isTest
    public static void handleAfterInsert_test(){
        
        Id profileId = [SELECT id FROM Profile WHERE name = 'Natixis Retail External'].Id; 
        
        List<user> lstUsers =  new List<User> ();

        User u = new User(Alias = 'standt', 
                            Email='stysfgf@natixis.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing1', 
                            FirstName='Testing1', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = profileId, 
                            userid__c='test35', 
                            TimeZoneSidKey='America/Los_Angeles', UserName='fhdgyu1@natixis.com');       
        User u2 = new User(Alias = 'stand2', 
                            Email='stysfg2@natixis.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testin2', 
                            FirstName='Testing2', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = profileId, 
                            userid__c='test36', 
                            TimeZoneSidKey='America/Los_Angeles', UserName='fhdgyu2@natixis.com');    

        lstUsers.add(u);
        lstUsers.add(u2);

        List<String> lstNameOfGroups = new List<String>();
        for (Integer i = 0; i < lstUsers.size(); i++) {
            lstNameOfGroups.add('Key Insights-' + lstUsers[i].FirstName + ' ' + lstUsers[i].LastName);
        }

        List<Group> lstGroup = [SELECT id FROM Group WHERE Name IN : lstNameOfGroups];
        System.assertEquals(lstGroup.size(), 0);

        insert lstUsers;

        lstGroup = [SELECT id FROM Group WHERE Name IN : lstNameOfGroups];
        System.assertEquals(lstGroup.size(), 2);
    }

}