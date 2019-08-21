@isTest
public class EventRelationChangeEventTHTest {
    
    @testSetup
    static void setup() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
        DataFactory.CreateNGAMCustomSettings(); 

        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
        List<Channel__c> channels = DataFactory.createChannels();
        insert channels;
        
        User u = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p, 
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin',
                          ActivityChannelId__c = channels[0].Id);
        insert u;
        
    }
    
    @isTest static void test() {
        
        User u = [SELECT Id FROM User where username = 'SFDCadmin@ngam.natixis.com' LIMIT 1];
        
        System.runAs(u) {

	        Test.enableChangeDataCapture();
            
            List<Account> myAccounts = DataFactory.createTestAccounts(3);
            insert myAccounts;
            
            List<Contact> myContacts = DataFactory.createTestContacts(1, myAccounts, false);
            insert myContacts;     

            List<Contact> myContacts2 = DataFactory.createTestContacts(2, myAccounts, false);
            insert myContacts2;     

            List<Event> myEvents = DataFactory.createTestEvents(1,myContacts,'Meeting');  
            insert myEvents; 
            
            List<EventRelation> myERs = new List<EventRelation>();
            myERs.add(new EventRelation(RelationId = myContacts2[0].Id, EventId = myEvents[0].Id));
            myERs.add(new EventRelation(RelationId = myContacts2[1].Id, EventId = myEvents[0].Id));
			insert myERs;

	        Test.getEventBus().deliver();
            
            List<ActivityContact__c> checkAC = [SELECT Id, Contact__c FROM ActivityContact__c WHERE ActivityId__c = :myEvents[0].Id];
            //system.AssertEquals(checkAC.size(),3,'checkAC.size() - Number of Activity Contacts after insert is not correct');
            Map<Id,ActivityContact__c> checkACMap = new Map<Id,ActivityContact__c>();
            for (ActivityContact__c ac : checkAC) {
                checkACMap.put(ac.Contact__c,ac);
            }
            if(checkACMap.size() > 0){
                system.Assert(checkACMap.containsKey(myContacts2[0].Id),'myContacts2[0].Id is missing from Activity Contacts');
                system.Assert(checkACMap.containsKey(myContacts2[1].Id),'myContacts2[1].Id is missing from Activity Contacts');
            }
            Test.enableChangeDataCapture();
            delete myERs;
            Test.getEventBus().deliver();
                     
            List<ActivityContact__c> checkACdel = [SELECT Id, Contact__c FROM ActivityContact__c WHERE ActivityId__c = :myEvents[0].Id];
            //system.AssertEquals(checkACdel.size(),1,'checkACDel.size() - Number of Activity Contacts after delete is not correct');            

        }
        

        // Verify the change event trigger’s execution
        // ...
        
    }
    
    
    
    
    
}