@isTest 
public class AddAccountToMarsWSC_Test {

    static testMethod void AddAccountToMarsWSCTesting() {
    
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
            NGAMSettings__c cs = new NGAMSettings__c();
            cs.Name='NGAM_ALL';
            cs.RepService__c = 'https://servicestest.ngam.natixis.com/repsvc/RepSvc.svc';
            insert cs;  
                
            NGAMSettings__c myRepServiceSetting = NGAMSettings__c.getValues('NGAM_ALL');
            string RepWebServiceURL = myRepServiceSetting.RepService__c; 
                    
              
              
        // specify fake response for a certain endpoint and

        // include response body in a static resource.   

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        string Method = AddAccountToMarsWSC.MathodNameForTest;
        multimock.setStaticResource( RepWebServiceURL , 'AddAccountMarsByIdResponse');
        //multimock.setStaticResource( RepWebServiceURL + '/DeleteAccMarsById', 'DeleteAccMarsByIdResponse');
        multimock.setStatusCode(200);

        multimock.setHeader('Content-Type', 'text/xml');

        // Set the mock callout mode
       // Test.setMock(HttpCalloutMock.class, multimock);
        // Call the method for the first endpoint
        List<Account> myFirms = DataFactory.createTestFirms(1);
         insert myFirms;
                
        List<Account> myAccounts = DataFactory.createTestAccountswithFirms(1,myFirms);
         insert myAccounts;
        
        // Verify response received
       
         Test.setMock(HttpCalloutMock.class, new AddAccountToMarsWSC_Mock());
         Test.startTest();
                
         AddAccountToMarsWSC.AddAccountMarsById(myAccounts[0].id);
           
         AddAccountToMarsWSC.DeleteAccMarsById(myAccounts[0].id, myAccounts[0].MarsAccountId__c);     
          
        //  List<Account>   myAccounts1 = DataFactory.createTestAccountswithFirms(3);
        //  insert myAccounts1;
              
                   
      //     AddAccountToMarsWSC.AddAccountMarsById(myAccounts1[0].id);
                // string AccountId, String MarsAccountId
       //    AddAccountToMarsWSC.DeleteAccMarsById(myAccounts1[1].id, myAccounts1[1].MarsAccountId__c);
                
           test.stopTest();

            }
    }
}