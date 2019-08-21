@isTest
private class ContactShareBatch_Test {
    static testMethod void ContactShareBatchTesting() {

       //Profile p = [select id from profile where name='System Administrator']; 
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
    
       
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) 
                {
                //Creating the Territory
                Territory__c Terr = new Territory__c(Name='Test',TerritoryName__c='Test'); 
                insert Terr; 
                    
                // Creating the Corresponding Role
                UserRole Ur = new UserRole();
                Ur.Name = Terr.Name;
                Ur.DeveloperName = Terr.Id;
                Ur.CaseAccessForAccountOwner = 'Read';
                Ur.OpportunityAccessForAccountOwner = 'Read';
                Ur.ContactAccessForAccountOwner = 'Read';
                insert Ur; 
                    
                Group UrGroup = [select id, relatedid from group where relatedid=:Ur.id limit 1][0];    
                
                Terr.RoleID__c = ur.id;   
                Terr.RoleGroupId__c = UrGroup.id;    
                update Terr;     
               
                Account myA = new Account(name='test me') ;   
                insert MyA;  
                
                Contact myC = new Contact(firstname='test',lastname='test', accountid=MyA.id);
                insert myC; 
                
                Test.StartTest();
     
                ContactTerritory__c myAC = new  ContactTerritory__c(contact__c =myC.id, territory__c=Terr.id, COntactTerrId__c = 'CO231176A507' );
                insert myAC ;
                      
                ContactShareBatch CSI = new ContactShareBatch();
                CSI.query =  'select Contact__c, Territory__r.RoleGroupId__c, Territory__r.GroupId__c from ContactTerritory__c';    
                ID CSIid = database.executeBatch(CSI);     
                    
                test.stopTest();          
                delete myAC;    

                }
        }
}