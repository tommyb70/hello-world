@isTest 
public class FinancialAccountNewController_Test {
    
    static testMethod void FinancialAccountNewControllerTesting() {
        
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
        User u2 = new User(alias = 'standt', 
                           email='SFDCadmin@ngam.natixis.com', 
                           emailencodingkey='UTF-8', 
                           lastname='Testing', 
                           languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           profileid = p, 
                           timezonesidkey='America/Los_Angeles', 
                           username='SFDCadmin@ngam.natixis.com',
                           UserID__c='SFDCadmin',
                           PrimaryChannelId__c='a1EF00000005Ws3MAE',
                           PrimaryChannel__c='WIREHOUSE',
                           ZoneId__c = myZOne.id,
                           ActivityZoneId__c = myZOne.id);
        
        System.runAs(u2) {           
            FinancialAccount__c testAcc =   new FinancialAccount__c(Name='Test Name',AccountID__c=123);  
            testAcc.RSAAccount__c = false;
            testAcc.AccountNameEncrypted__c ='abc';
            insert testAcc;
                                   
            //start the test execution context
            Test.startTest();
            FinancialAccountNewController controller = new FinancialAccountNewController(new ApexPages.StandardController(testAcc));
            ApexPages.currentPage().getParameters().put('id', testAcc.id);
            Test.setMock(HttpCalloutMock.class, new FAGetAccountWSCCallout_Mock());
            String Search = '';
            controller.getDataSync();
            //String expectedValue = '[{"accountId":26,"accountNumber":"32000380","accountName":"BSM32000380","accountTitle":"ELIZABETH GROSSMAN TRUST","accountType":"TRUST","sponsor":"JP Morgan","program":"Stratis","manager":"AEW","modelName":"AEWREI","modelDescription":"AEW REIT","inceptionValue":140028,"inceptionDate":1136246400000,"terminationDate":4386355200000,"terminationValue":0,"firstTradeDate":1136419200000,"firstTradeValue":140028,"lifeCycleStep":"Active","faName":"PHYLLIS TABACHNICK","faEmail":null}]';
            String expectedValue = '[{"accountId":26,"accountNumber":"32000380","accountName":"BSM32000380","accountTitle":"ELIZABETH GROSSMAN TRUST","accountType":"TRUST","sponsor":"JP Morgan","program":"Stratis","manager":"AEW","modelName":"AEWREI","modelDescription":"AEW REIT","inceptionValue":140028,"inceptionDate":1136246400000,"terminationDate":4386355200000,"terminationValue":0,"firstTradeDate":1136419200000,"firstTradeValue":140028,"lifeCycleStep":"Active","faName":"PHYLLIS TABACHNICK","faEmail":null}]';
            
            List<FAAccountDetailResponse> obj = FAAccountDetailResponse.parse(expectedValue);     
            //System.assertEquals(response1, expectedValue);
            
            // set the test's page to your VF page (or pass in a PageReference)
            Test.setCurrentPage(Page.FinancialAccountPage);
                                                
            Continuation conti = (Continuation)controller.getData();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(controller.requestLabel) != null);
            
            HttpResponse response = new HttpResponse();
            response.setBody(FAAccountDetailResponse_Test.json);  
            // Set the fake response for the continuation    
            Test.setContinuationResponse(controller.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(controller, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            List<SelectOption> l = controller.responseRecords;
            controller.save();
            controller.Cancel();
                        
            Test.stopTest();    
        }  
    }    
        
}