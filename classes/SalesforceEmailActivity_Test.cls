@isTest 
public class SalesforceEmailActivity_Test { 
       static testMethod void SalesforceEmailActivityTestingMethod() { 
                
                //Profile p = [select id from profile where name='System Administrator']; 
                DataFactory.CreateNGAMCustomSettings(); 
                NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
                string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
           
                User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p, 
                                    timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin'); 
                
                User u3 = new User(alias = 'tesjs', email='neetu.gupta@ngam.natixis.com', 
                                    emailencodingkey='UTF-8', lastname='TestingNeet', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p, 
                                    timezonesidkey='America/Los_Angeles', username='neetu.gupta@ngam.natixis.com',UserID__c='SFDCadmin1'); 
                                    insert u3;                 
          System.runAs(u2){ 
                // Create a new email and envelope object                 
                Messaging.InboundEmail email = new Messaging.InboundEmail();                 
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
                
                // Create the plainTextBody and fromAddres for the test                 
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone><ActivitySource>GPS</ActivitySource><CompletedDate>7/8/2015 2:13:14 PM</CompletedDate>'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                
                test.startTest(); 
                
                SalesforceEmailActivityHandler taskObj = new SalesforceEmailActivityHandler (); 
                
                /* email.plainTextBody = null; 
                email.htmlBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); */ 
                
                List<String> To = new List<String>(); 
                To.Add('test@test.com'); 
                /* email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone>'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                taskObj.handleInboundEmail(email, env); */ 
                                
                List<String> cc= new List<String>(); 
                cc.Add('tom.cullen@ubs.com'); 
                /* email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                email.ccAddresses =cc; 
                taskObj.handleInboundEmail(email, env); */ 
                
                /* email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails>'; 
                email.fromAddress ='neetugupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); */ 
                
                // add an attachment 
                Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment(); 
                attachment.body = blob.valueOf('my attachment text'); 
                attachment.fileName = 'textfile.txt'; 
                attachment.mimeTypeSubType = 'text/plain'; 
                
                email.binaryAttachments = 
                new Messaging.inboundEmail.BinaryAttachment[] { attachment }; 
                                
                // add an attachment 
                Messaging.InboundEmail.TextAttachment textAttachments= new Messaging.InboundEmail.TextAttachment(); 
                textAttachments.body = 'my attachment text'; 
                textAttachments.fileName = 'textfile.txt'; 
                textAttachments.mimeTypeSubType = 'text/plain'; 
                
                email.textAttachments= 
                new Messaging.inboundEmail.TextAttachment[] { textAttachments}; 
                                
                // add an attachment 
                Messaging.InboundEmail.Header headers = new Messaging.InboundEmail.Header(); 
                headers.name= 'Date'; 
                headers.value = 'Thu, 3 Sep 2015 14:12:48 +0000'; 
                
                email.headers = new Messaging.inboundEmail.Header [] { headers };                 
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                taskObj.handleInboundEmail(email, env); 
                
                // error condition fields                 
                email.plainTextBody = null; 
                email.htmlBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone>'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                email.ccAddresses =cc; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails>'; 
                email.fromAddress ='neetugupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                headers.name= 'Date'; 
                headers.value = 'Thu, 3 Sap 2015 '; 
                email.headers = 
                new Messaging.inboundEmail.Header [] { headers }; 
                
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                test.stopTest();                 
          } 
      } 
                
      static testMethod void SalesforceEmailActivityTesting() { 
                
                //Profile p = [select id from profile where name='System Administrator']; 
                DataFactory.CreateNGAMCustomSettings(); 
                NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
                string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
          
                User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p, 
                                    timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');                 
          System.runAs(u2){ 
                
                // Create a new email and envelope object 
                
                Messaging.InboundEmail email = new Messaging.InboundEmail();                 
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
                
                // Create the plainTextBody and fromAddres for the test                 
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone><ActivitySource>GPS</ActivitySource><CompletedDate>7/8/2015 2:13:14 PM</CompletedDate>'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                
                test.startTest(); 
                
                SalesforceEmailActivityHandler taskObj = new SalesforceEmailActivityHandler (); 
                
                List<String> To = new List<String>(); 
                To.Add('test@test.com');                 
                                
                List<String> cc= new List<String>(); 
                cc.Add('tom.cullen@ubs.com'); 
                                
                // add an attachment 
                Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment(); 
                attachment.body = blob.valueOf('my attachment text'); 
                attachment.fileName = 'textfile.txt'; 
                attachment.mimeTypeSubType = 'text/plain'; 
                
                email.binaryAttachments = 
                new Messaging.inboundEmail.BinaryAttachment[] { attachment }; 
                                
                // add an attachment 
                Messaging.InboundEmail.TextAttachment textAttachments= new Messaging.InboundEmail.TextAttachment(); 
                textAttachments.body = 'my attachment text'; 
                textAttachments.fileName = 'textfile.txt'; 
                textAttachments.mimeTypeSubType = 'text/plain'; 
                
                email.textAttachments= 
                new Messaging.inboundEmail.TextAttachment[] { textAttachments}; 
                                
                // add an attachment 
                Messaging.InboundEmail.Header headers = new Messaging.InboundEmail.Header(); 
                headers.name= 'Date'; 
                headers.value = 'Thu, 3 Sep 2015 14:12:48 +0000'; 
                
                email.headers = new Messaging.inboundEmail.Header [] { headers };                                                                 
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                taskObj.handleInboundEmail(email, env); 
                
                // error condition fields                 
                email.plainTextBody = null; 
                email.htmlBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails><UserPhone>9789999999</UserPhone>'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                email.toAddresses = To; 
                email.ccAddresses =cc; 
                taskObj.handleInboundEmail(email, env); 
                
                email.plainTextBody = 'Here is my plainText body of the email<AdditionalFields><ContactEmails>tom.cullen@ubs.com</ContactEmails>'; 
                email.fromAddress ='neetugupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                headers.name= 'Date'; 
                headers.value = 'Thu, 3 Sap 2015 '; 
                email.headers = 
                new Messaging.inboundEmail.Header [] { headers }; 
                
                email.plainTextBody = 'Here is my plainText body of the email'; 
                email.fromAddress ='neetu.gupta@ngam.natixis.com'; 
                taskObj.handleInboundEmail(email, env); 
                
                test.stopTest();                 
         } 
      } 
}