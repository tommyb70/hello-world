@isTest 
public class TaskExtension_Test {
 
    @testSetup static void setup() {
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
    }
    
   static testMethod void TaskExtensionTestNonIc(){
   

            
            ExternalCommunitySettings__c ECS = new ExternalCommunitySettings__c(); 
            ECS.Name = 'EstatementCommunity'; 
            ECS.UseMPANamedCredential__c = 'testugng'; 
            insert ECS;
            
            //Profile p = [select id from profile where name='System Administrator'];
            DataFactory.CreateNGAMCustomSettings(); 
            NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
            string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
            
            Zone__c z=new Zone__c(Name ='Test Zone', Zone__c=12);
            insert z;
            
            Zone__c myZOne = [select id from zone__c limit 1][0];  
            
            User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', 
                                username='SFDCadmin@ngam.natixis.com',
                                UserID__c='SFDCadmin',
                                PrimaryChannelId__c='a1EF00000005Ws3MAE',
                                PrimaryChannel__c='WIREHOUSE',
                                ZoneId__c = myZOne.id,
                                ActivityZoneId__c = myZOne.id);
        
            System.runAs(u2){
                    Account testAccount = new Account(name='test');   
                    insert testAccount;
                        
                    Contact testContact = new Contact(lastname='Last Name',firstname='Test', accountid=testAccount.id,BPL__c=true);   
                    insert testContact;
                        
                    Task testTask = new Task(Subject='Test', status='Completed',type='Call - Informative', whoid=testContact.id, whatid=testAccount.id, description='test',ActivitySource__c ='',activitydate=date.today());  
                    insert TestTask;
                        
                  //start the test execution context
                    Test.startTest();
    
                    // set the test's page to your VF page (or pass in a PageReference)
                    Test.setCurrentPage(Page.TaskView);
                     
                    ApexPages.currentPage().getParameters().put('what_id', TestTask.whatid);
                    TestTask.whatid = null;
                     
                    ApexPages.currentPage().getParameters().put('who_id', TestTask.whoid);
                    TestTask.whoid= null;
                     
                    ApexPages.currentPage().getParameters().put('tsk12', TestTask.status);
                    TestTask.status= null;
                     
                    ApexPages.currentPage().getParameters().put('type', TestTask.type);
                    TestTask.type= null;
                     
                    ApexPages.currentPage().getParameters().put('retURL', testcontact.id);
                    // TestTask.type= null;                                             
                    TaskExtension controller = new TaskExtension(new ApexPages.StandardController(TestTask));
                    controller.retURL = testcontact.id;
                    
                    boolean ic = controller.is_ic_inbound;
                    boolean institutionalProfile= controller.InstitutionalProfile;
                                        
                 //TaskExtension controller = new TaskExtension();   
                    controller.unisave();
                    controller.TaskEdit();
                    controller.del();
                    system.assert(controller.isSF1 != null);
                    controller.SaveComplete();
                    controller.FollowUpActivity();
                    controller.upload();
                    controller.SaveEdit();                                                            
                    TestTask.Status = 'Open';
    
                    
                    TaskExtension.jsRemote(new Map<String, String>{'event' => 'upload', 'id' => '' + TestTask.id});
                    TaskExtension.jsRemote(new Map<String, String>{'event' => 'followup', 'id' => '' + TestTask.id});
                    TaskExtension.jsRemote(new Map<String, String>{'event' => 'del', 'id' => '' + TestTask.id});
                    
                    controller.del();
            
                    Test.stopTest();    
                    }   
            }    
    
      static testMethod void TaskExtensionTestIc() {
            //Profile p = [select id from profile where name='System Administrator']; 
            DataFactory.CreateNGAMCustomSettings(); 
            NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
            string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
          
            Zone__c z=new Zone__c(Name ='Test Zone', Zone__c=12);
            insert z;
            Zone__c myZOne = [select id from zone__c limit 1][0];  
            User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = p, 
                                timezonesidkey='America/Los_Angeles', 
                                username='SFDCadmin@ngam.natixis.com',
                                UserID__c='SFDCadmin',
                                PrimaryChannelId__c='a1EF00000005Ws3MAE',
                                PrimaryChannel__c='WIREHOUSE',
                                ZoneId__c = myZOne.id,
                                ActivityZoneId__c = myZOne.id);
        
        System.runAs(u2) 
                {
                Account testAccount = new Account(name='test');   
                insert testAccount;
                    
                Contact testContact = new Contact(lastname='Last Name',firstname='Test', accountid=testAccount.id,BPL__c=true);   
                insert testContact;
                    
                Task testTask = new Task(Subject='Test', status='Completed',type='Call - Informative', whoid=testContact.id, whatid=testAccount.id, description='test',ActivitySource__c ='' );  
                insert TestTask;
                    
                 //start the test execution context
                Test.startTest();

                // set the test's page to your VF page (or pass in a PageReference)
                Test.setCurrentPage(Page.TaskView);
                 
                 ApexPages.currentPage().getParameters().put('what_id', TestTask.whatid);
                 TestTask.whatid = null;
                 
                  ApexPages.currentPage().getParameters().put('who_id', TestTask.whoid);
                 TestTask.whoid= null;
                 
                  ApexPages.currentPage().getParameters().put('tsk12', TestTask.status);
                 TestTask.status= null;
                 
                  ApexPages.currentPage().getParameters().put('type', TestTask.type);
                 TestTask.type= null;
                 
                    ApexPages.currentPage().getParameters().put('retURL', testcontact.id);
                    
                    ApexPages.currentPage().getParameters().put('subject', TestTask.subject);
                    ApexPages.currentPage().getParameters().put('description', TestTask.description);
                    
                    ApexPages.currentPage().getParameters().put('retURL', testcontact.id);
                // TestTask.type= null;
                 
                TaskExtension controller = new TaskExtension(new ApexPages.StandardController(TestTask));
                controller.retURL = testcontact.id;
                
                boolean ic = controller.is_ic_inbound;
                boolean institutionalProfile= controller.InstitutionalProfile;
                
                
             //TaskExtension controller = new TaskExtension();   
               // controller.unisave();
               // controller.TaskEdit();
               // controller.del();
               
                controller.is_ic_inbound = true;
                
                 controller.unisave();
                controller.TaskEdit();
                controller.del();
                
                controller.SaveComplete();
                controller.FollowUpActivity();
                controller.upload();
                controller.SaveEdit();
                
                TestTask.Status = 'Open';

                
                controller.del();
        
                Test.stopTest();    
                }   
            }    

}