@isTest 
public class GPSEmailServiceActivity_Test {

    static testMethod void GPSEmailServiceActivityTesting() {

       //Profile p = [select id from profile where name='System Administrator']; 
       DataFactory.CreateNGAMCustomSettings(); 
       NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
       string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
       User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = p, 
                    timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
    System.runAs(u2) 
            {/*
        	List<Account> myAccounts = DataFactory.createTestAccounts(3);
        	insert myAccounts;
                    
        	List<Contact> myContacts = DataFactory.createTestContacts(3, myAccounts, false);
        	insert myContacts;     
                    
        	List<Task> myTasks = DataFactory.createTestTasks(3,myContacts,'Mass Email:TEST');  
        	insert myTasks;*/      
                
               
// Create a new email and envelope object 
 
   Messaging.InboundEmail email = new Messaging.InboundEmail(); 

   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 

// Create the plainTextBody and fromAddres for the test 

    email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone><ActivitySource>GPS</ActivitySource><CompletedDate>7/8/2015 2:13:14 PM</CompletedDate>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                 
    test.startTest();   
                   
    GPSemailServiceActivityHandler taskObj = new GPSemailServiceActivityHandler (); 
    taskObj.handleInboundEmail(email, env); 
    
    email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone><ActivitySource>GPS</ActivitySource>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
    taskObj.handleInboundEmail(email, env); 
    
    email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
    taskObj.handleInboundEmail(email, env); 
    
    email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
    taskObj.handleInboundEmail(email, env); 
    
    email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields>'; 
    email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
    taskObj.handleInboundEmail(email, env); 
    
    

   test.stopTest();

     }
    }
}