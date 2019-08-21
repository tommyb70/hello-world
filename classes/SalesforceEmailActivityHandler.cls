global class SalesforceEmailActivityHandler implements Messaging.InboundEmailHandler {    
global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                  Messaging.InboundEnvelope env){
        
        // Create an inboundEmailResult object for returning 
        // the result of the Force.com Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String myPlainText = email.plainTextBody;             
       if (email.plainTextBody != null){
           myPlainText = email.plainTextBody;
          } else {
        myPlainText = email.htmlBody;
         }                                          
        String ActivitySource= 'Outlook Email Svc';  //'Outlook Integration';
        Date completed = Date.today();
        String fr =  '';
        fr = email.fromAddress;
        // Contactemails= email.toAddresses;
         List<String> ccEmails = email.ccAddresses;
         List<String> toEmails= email.toAddresses;
         List<String> Contactemails = new List<String>();

        if( email.toAddresses!= null)  Contactemails.addAll(toEmails);
        if( email.ccAddresses != null) Contactemails.addAll(ccEmails);
        
        System.debug('Contactemails============= : ' + Contactemails);
        System.debug('from ============= : ' + fr);
        System.debug('completed  ============= : ' + completed );
        System.debug('references   ============= : ' + email.references );
        
        
      if (email.headers!= null && email.headers.size() > 0) {
      for (integer i = 0 ; i < email.headers.size() ; i++) {
        System.debug('email.headers[i].name   ============= : ' + email.headers[i].name);
        System.debug('email.headers[i].value ============= : ' + email.headers[i].value);
        if(email.headers[i].name == 'Date'){
        // Thu, 3 Sep 2015 14:12:48 +0000
        try {
         Map <String, Integer> months = new Map <String, Integer> {'jan'=>1, 'feb'=>2
        , 'mar'=>3, 'apr'=>4, 'may'=>5, 'jun'=>6, 'jul'=>7, 'aug'=>8, 'sep'=>9
        , 'oct'=>10, 'nov'=>11, 'dec'=>12};
        String dateString = email.headers[i].value;
       if(dateString  != null) {
         List <String> dateParts = dateString.toLowerCase().replace(',','').split(' ');
         if(dateParts.size() > 3)
         {
          Integer month = months.get(dateParts[2]);
          Integer day = Integer.valueOf(dateParts[1]);
          Integer year = Integer.valueOf(dateParts[3]);
          Date parsedDate = Date.newInstance(year,month,day);
          completed  = parsedDate;
           System.debug('========Send date : ' + completed  );  
          }        
       }
      } catch (Exception e) {
           System.debug('========Exception in date parsing: ' + e);  
           completed = Date.today();          
           }  
           break;     
        }
      }
   }
        try {
        
              List<User> userList = [select Id, UserName__c,UserID__c, UserRoleText__c , PrimaryTerritory__c,ZoneID__c, IsActive from User where Email in (:fr) and UserName__c != null and IsActive = true Limit 1]; 
               if ( userList.size() < 1){
                System.debug('No user found for email  ============= : ' + fr);
                result.success = true;        
                return result;
                }               
               User user = userList[0];
               System.debug('Contactemails ============= : ' + Contactemails);
                             
               Task t = new Task();
                  String login = user.UserID__c;
                  String actType = 'Email';
                                          
                 // t.SynergyRowId__c = login + DateTime.now().format('yyyyMMddHHmmss');
                //  if(t.SynergyRowId__c.length() > 20)t.SynergyRowId__c = t.SynergyRowId__c.mid(t.SynergyRowId__c.length()-20 ,20);
                //  System.debug('t.SynergyRowId__c ============= : ' + t.SynergyRowId__c);
                  t.OwnerId = user.Id;
                  t.Subject = email.subject;               
                  t.Status = 'Completed';
                  t.Subject = actType;
                  t.ActivitySource__c = ActivitySource;
                  t.OwnerTerritory__c = user.PrimaryTerritory__c;    
                  if(myPlainText.length() > 31999)myPlainText =myPlainText.substring(0,31999);
                  t.Description = myPlainText;
                 /* if(myPlainText.length() > 255)myPlainText =myPlainText.substring(0,255);
                  t.ActivityComments__c = myPlainText;   */ 
                  t.CanStayOpen__c = false;
                  t.Type = actType;
                  t.ActivityDate = completed ;  
                  
                                    
                  insert t;
//                 List<Attachment>  AttachmentList = new List<Attachment>();
                  if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                      System.debug('email.binaryAttachments.size  ============= : ' + email.binaryAttachments.size() );
      for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
/*        Attachment attachment = new Attachment();
        attachment.ParentId =  t.Id;
        attachment.OwnerId = user.Id;
        attachment.Name = email.binaryAttachments[i].filename;
        attachment.Body = email.binaryAttachments[i].body;
        AttachmentList.add(attachment);
        System.debug('attachment.Name  ============= : ' + attachment.Name );*/
          
                ContentVersion cv = new ContentVersion();
                cv.VersionData = email.binaryAttachments[i].body;
                cv.Title = email.binaryAttachments[i].filename;
                cv.PathOnClient = email.binaryAttachments[i].filename;
                insert cv;
	     
				cv = [select ContentDocumentId from ContentVersion where id = :cv.id limit 1];

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = t.id;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'V';
                insert cdl;


          
          
          
          
          
              }
    }
    
     if (email.textAttachments != null && email.textAttachments.size() > 0) {
      for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
                ContentVersion cv = new ContentVersion();
                cv.VersionData = email.binaryAttachments[i].body;
                cv.Title = email.binaryAttachments[i].filename;
                cv.PathOnClient = 'EmailAttachment';
                insert cv;
	     
				cv = [select ContentDocumentId from ContentVersion where id = :cv.id limit 1];

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = t.id;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'V';
                insert cdl;

      }
    }
     //System.debug('AttachmentList ============= : ' + AttachmentList);
     //insert AttachmentList; 
                         
     Set<sobject> myset = new Set<sobject>();
     ActivityContact__c[] ActivityContactList = new ActivityContact__c[0];
                           
               for (String e:Contactemails) {
               String query = 'select Id, MarsRepId__c, Email, FirstName, LastName  from Contact where Email = \'' + e + '\'';
               System.debug('query ============= : ' + query);
                List<Contact> ContactList = Database.query(query);               
               
     if( ContactList.size() >  1) { System.debug('More than one Conatct associated with the email : ' + e);   }     
     for (Contact vCon:ContactList ) {              
                    ActivityContact__c c = new ActivityContact__c();
                    c.ActivityId__c = t.Id;
                    c.Contact__c = vCon.Id;  
                  //  c.Primary__c  = True; this does not create the Task relation
                    if (myset.add(vCon)) {
                    ActivityContactList .add(c);
                    }
                }
                   
            // update task
           // t.DTFlag__c = True;
           // update t;
         }
              System.debug('New ActivityContactList Object: ' + ActivityContactList );
              insert ActivityContactList ;     
                 
        }  catch (Exception e) {
           System.debug('Exception: ' + e);            
           }        
           // Set the result to true, no need to send an email back to the user
           // with an error message
           result.success = true;        
          // Return the result for the Force.com Email Service
          return result;
 }  
      
}