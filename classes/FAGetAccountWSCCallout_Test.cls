@isTest 
public class FAGetAccountWSCCallout_Test {
    
    static testMethod void FAGetAccountWSCCalloutTesting() {
        
       // Profile p = [select id from profile where name='System Administrator'];
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);  
        
        ExternalCommunitySettings__c ECS = new ExternalCommunitySettings__c(); 
        ECS.Name = 'EstatementCommunity'; 
        ECS.UseMPANamedCredential__c = 'testugng'; 
        ECS.UserNameFormat__c = 'TEstcom'; 
        ECS.TestUserEmail__c = 'TEst@gmail.com'; 
        insert ECS; 
        
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = p, 
                           timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) 
        {
            FinancialAccount__c testAcc =   new FinancialAccount__c(Name='Test Name',AccountID__c=123);  
            testAcc.RSAAccount__c = true;
            insert testAcc;
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new FAGetAccountWSCCallout_Mock());
            Test.startTest();
            // Call method to test.
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. 
            String Search = '';
            String response = FinancialAccountGetAccountWSCCallout.getDataSync(Search);
            // String expectedValue = '{"accountId":26,"accountNumber":"32000380","accountName":"BSM32000380","accountTitle":"ELIZABETH GROSSMAN TRUST","accountType":"TRUST","sponsor":"JP Morgan","program":"Stratis","manager":"AEW","modelName":"AEWREI","modelDescription":"AEW REIT","inceptionValue":140028,"inceptionDate":null,"terminationDate":null,"terminationValue":0,"firstTradeDate":null,"firstTradeValue":140028,"lifeCycleStep":"Active","faName":"PHYLLIS TABACHNICK","faEmail":null}';
            String expectedValue = '[{"accountId":26,"accountNumber":"32000380","accountName":"BSM32000380","accountTitle":"ELIZABETH GROSSMAN TRUST","accountType":"TRUST","sponsor":"JP Morgan","program":"Stratis","manager":"AEW","modelName":"AEWREI","modelDescription":"AEW REIT","inceptionValue":140028,"inceptionDate":1136246400000,"terminationDate":4386355200000,"terminationValue":0,"firstTradeDate":1136419200000,"firstTradeValue":140028,"lifeCycleStep":"Active","faName":"PHYLLIS TABACHNICK","faEmail":null}]';
            
            List<FAAccountDetailResponse> obj = FAAccountDetailResponse.parse(expectedValue);
            System.assertEquals(response, expectedValue);
     
            // set the test's page to your VF page (or pass in a PageReference)
            Test.setCurrentPage(Page.FinancialAccountPage);
            
            ApexPages.currentPage().getParameters().put('id', testAcc.id);
            
            
            FinancialAccountNewController controller = new FinancialAccountNewController(new ApexPages.StandardController(testAcc));
            Continuation conti = (Continuation)controller.getData();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(controller.requestLabel) != null);
            
            HttpResponse response1 = new HttpResponse();
            response1.setBody(FAAccountDetailResponse_Test.json);  
            // Set the fake response for the continuation    
            Test.setContinuationResponse(controller.requestLabel, response1);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(controller, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            
            FinancialAccountGetAccountWSCCallout.getData(null,'test',0,'test');
            
            Test.stopTest();
        }
    }
    
}