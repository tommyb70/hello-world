@isTest
private class UtilTest {
    
    @testSetup static void setup() {
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
    }
    
    @isTest static void testGetCustomSettingProfileId() {

        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
                
    }
    
    @isTest static void testGetUserTerritoryMap() {

        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c,ProfileSales__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
        List<User> users = new List<User>();
        users.add(new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p,
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin'));
        users.add(new User(alias = 'standt2', email='SFDCadmin2@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p,
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin2@ngam.natixis.com',UserID__c='SFDC2admin'));        
        insert users;

        Map<Id,User> userMap = Util.getUserTerritoryMap();
        Boolean containsRightUsers = (userMap.containsKey(users[0].Id) && userMap.containsKey(users[1].Id));
        system.assertEquals(containsRightUsers, TRUE, 'getUserTerritoryMap() does not contain right users');

        Set<Id> userIdSet = new Set<Id>();
        userIdSet.add(users[0].Id);
        userMap = Util.getUserTerritoryMap(userIdSet);
        containsRightUsers = (userMap.containsKey(users[0].Id) && userMap.size() == 1);
        system.assertEquals(containsRightUsers, TRUE, 'getUserTerritoryMap(userIdSet) does not contain right users');        

    }    
    
    @isTest static void testGetAccountFirmIdMap() {
        
        Set<Id> accountIdSet = new Set<Id>();
        
        List<Account> firm0 = DataFactory.createTestFirms(1);
        insert firm0;
        accountIdSet.add(firm0[0].Id);
        
        List<Account> firm1 = DataFactory.createTestAccountswithFirms(1, firm0);
        firm1[0].ParentId = firm0[0].Id;
        firm1[0].MarsAccountId__c = 'TESTCHILD';
        insert firm1;
        accountIdSet.add(firm1[0].Id);
        
        List<Account> office = DataFactory.createTestAccountswithFirms(1, firm1);
        insert office;
        accountIdSet.add(office[0].Id);
        
        Map<Id,Id> accountFirmIdMap = Util.getAccountFirmIdMap(accountIdSet);
        
    }
    
    @isTest static void testGetChannelMap() {
        
		Map<Id,Channel__c> channelMap = Util.getChannelMap();
        
    }    
    
}