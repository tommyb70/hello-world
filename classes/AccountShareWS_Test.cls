@isTest 
private class AccountShareWS_Test {
    static testMethod void AccountShareWSTesting() {

       //Profile p = [select id from profile where name='System Administrator']; 
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
        
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) { 
                // Testing Account Share WS    
                RestRequest reqA = new RestRequest(); 
                RestResponse resA = new RestResponse();
                reqA.requestURI = '/services/apexrest/AccountTerritoryShare/*';  
                reqA.httpMethod = 'POST';
                RestContext.request = reqA;
                RestContext.response = resA;     
                List<id> ComWSA = AccountShareWS.ComputeSharing(system.now()+1);
                    
        }
    }
}