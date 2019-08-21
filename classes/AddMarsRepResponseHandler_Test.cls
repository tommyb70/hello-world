@isTest (SeeAllData=true)
public class AddMarsRepResponseHandler_Test {

    static testMethod void AddMarsRepResponseHandlerTesting() {

        NGAMSettingsHierarchy__c settings = NGAMSettingsHierarchy__c.getOrgDefaults();
        settings.ByPassAccountValidationRules__c  = TRUE;
        upsert settings NGAMSettingsHierarchy__c.Id;

       Profile p = [select id from profile where name='System Administrator']; 
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = p.Id, 
                    timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
    System.runAs(u2) 
            {   
                
               
                
                List<Account> myAccounts = DataFactory.createTestAccounts(1);
                insert myAccounts;
                    
                List<Contact> myContacts = DataFactory.createTestContacts(1, myAccounts, false);
                insert myContacts;    
           
// Create a new email and envelope object  
   Messaging.InboundEmail email = new Messaging.InboundEmail(); 
   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 

// Create the plainTextBody and fromAddres for the test 

    email.plainTextBody = '<Contact>' +myContacts[0].id +'#'+ '123456' + '</Contact>';
  //'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone><ActivitySource>GPS</ActivitySource><CompletedDate>7/8/2015 2:13:14 PM</CompletedDate>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                 
test.startTest();                      
AddRepMarsResponseHandler taskObj = new AddRepMarsResponseHandler(); 
taskObj.handleInboundEmail(email, env); 
email.plainTextBody = '<Contact>' +myContacts[0].id+'</Contact>';
taskObj.handleInboundEmail(email, env); 
      

                List<Account> myFirms = DataFactory.createTestFirms(1);
                insert myFirms;
                
                List<Account> myAccountFirms = DataFactory.createTestAccountswithFirms(1,myFirms);
                insert myAccountFirms;
            
       

// Account response
   email.plainTextBody = '<Account>' +myAccountFirms[0].id +'#'+ '123456' + '</Account>';    
   taskObj.handleInboundEmail(email, env); 
   email.plainTextBody = '<Account>' +myAccountFirms[0].id+'</Account>';
   taskObj.handleInboundEmail(email, env); 
                        
// Firm
 email.plainTextBody = '<Firm>' +myFirms[0].id +'#'+ '123456#1234567' + '</Firm>';    
    taskObj.handleInboundEmail(email, env); 
   email.plainTextBody = '<Firm>' +myFirms[0].id+'</Firm>';
   taskObj.handleInboundEmail(email, env); 
             

test.stopTest();

            }
        
    }
}