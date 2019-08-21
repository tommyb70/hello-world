@isTest 
private class ContactShareWS_Test {
    static testMethod void ContactShareWSTesting() {

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
                // Testing Contact Share WS    
                RestRequest reqC = new RestRequest(); 
    			RestResponse resC = new RestResponse();
			   	reqC.requestURI = '/services/apexrest/ContactTerritoryShare/*';  
                reqC.httpMethod = 'POST';
    			RestContext.request = reqC;
    			RestContext.response = resC;  
   		 		List<id> ComWSC = ContactShareWS.ComputeSharing(system.now()+1);   
                    
        		}
		}
}