@isTest
private class AccountShareBatch_Test {
    static testMethod void AccountShareBatchTesting() {
    
        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;


       //Profile p = [select id from profile where name='System Administrator'];
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);

       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p, 
                            timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2){
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
                
                Test.StartTest();
     
                AccountTerritory__c myAC = new  AccountTerritory__c(account__c =MyA.id, territory__c=Terr.id, AccountTerrId__c = 'FR231176A507' );
                insert myAC ;
                      
                AccountShareBatch ASI = new AccountShareBatch();
                ASI.query = 'select Account__c, Territory__r.RoleGroupId__c, RoleId__c, GroupId__c from AccountTerritory__c';
                ID ASIid = database.executeBatch(ASI); 
                test.stopTest();
                    
                delete myAC;                                                                
                    
                }
        }
}