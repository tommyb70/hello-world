global class GPSEmailServiceActivityHandler implements Messaging.InboundEmailHandler {    
global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                  Messaging.InboundEnvelope env){
        
        // Create an inboundEmailResult object for returning 
        // the result of the Force.com Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String myPlainText = email.plainTextBody;
        if(email.plainTextBody.indexOf('<AdditionalFields>') > 0)
        {
              myPlainText = email.plainTextBody.substring(0, email.plainTextBody.indexOf('<AdditionalFields>'));
        }
        else 
        {          
             System.debug('No <AdditionalFields> in email: ');
        }
        String Contactemails= '';
        if(email.plainTextBody.indexOf('</ContactEmails>') > 0) {
         Contactemails= email.plainTextBody.substring(email.plainTextBody.indexOf('<ContactEmails>') + 15, email.plainTextBody.indexOf('</ContactEmails>'));
        }
        else 
        {            
             System.debug('No <ContactEmails> in email: ');
        }
        
        String UserPhone= '';
        if(email.plainTextBody.indexOf('</UserPhone>') > 0) {
         UserPhone= email.plainTextBody.substring(email.plainTextBody.indexOf('<UserPhone>') + 11, email.plainTextBody.indexOf('</UserPhone>'));
        }
        else 
        {
             System.debug('No <UserPhone> in UserPhone: ' );
        }
                
        String ActivitySource= 'GPS';
        if( email.plainTextBody.indexOf('</ActivitySource>') > 0) {
         ActivitySource= email.plainTextBody.substring(email.plainTextBody.indexOf('<ActivitySource>') + 16, email.plainTextBody.indexOf('</ActivitySource>'));
        }
        else
        {            
             System.debug('No <ActivitySource> in email: ' );
        }
         String CompletedDate= '';
         Date completed = Date.today();
               try {
          CompletedDate= email.plainTextBody.substring(email.plainTextBody.indexOf('<CompletedDate>') + 15, email.plainTextBody.indexOf('</CompletedDate>'));
          System.debug('CompletedDate : ' + CompletedDate);
          completed  =   Date.Parse(CompletedDate);       
           }
        catch(Exception e)
        {
            try{
                 String[] str = CompletedDate.split(' ');
                 completed  = Date.Parse(str[0]);
             }
             catch(Exception ex){
              completed = Date.today(); System.debug('No <Invalid date> : ' + ex);
             }
        }
        String fr =  '';
        fr = email.fromAddress;
        
        System.debug('AdditionalFields ============= : ' + Contactemails);
        System.debug('from ============= : ' + fr);
        System.debug('completed  ============= : ' + completed );
        
        try {
        
              List<User> userList = [select Id, UserName__c,UserID__c, UserRoleText__c , PrimaryTerritory__c,ZoneID__c, IsActive from User where Email in (:fr) and UserName__c != null and IsActive = true Limit 1]; 
               if ( userList.size() < 1){
                System.debug('No user found for email  ============= : ' + fr);
                }               
               User user = userList[0];
               System.debug('Contactemails ============= : ' + Contactemails);
               String[] emails = Contactemails.Split(',');
               
               Task t = new Task();
                  String login = user.UserID__c;
                  String actType = 'Email';
                                          
                 // t.SynergyRowId__c = login + DateTime.now().format('yyyyMMddHHmmss');
                 // if(t.SynergyRowId__c.length() > 20)t.SynergyRowId__c = t.SynergyRowId__c.mid(t.SynergyRowId__c.length()-20 ,20);
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

               
               for (String e:emails ) {
               String query = 'select Id, MarsRepId__c, Email, FirstName, LastName  from Contact where Email = \'' + e + '\'';
               System.debug('query ============= : ' + query);
                List<Contact> ContactList = Database.query(query);               
                /* if( ContactList.size() < 1) {
                  result.success = false;
                  System.debug('No Contact found for ============= : ' + Contactemails);
                  return  result;
                  }*/
                 
                 if( ContactList.size() >  1) { System.debug('More than one Conatct associated with the email : ' + e);   }     
                          
               ActivityContact__c[] ActivityContactList = new ActivityContact__c[0];
               for (Contact vCon:ContactList ) {
                    ActivityContact__c c = new ActivityContact__c();
                    c.ActivityId__c = t.Id;
                    c.Contact__c = vCon.Id;  
                  // c.Primary__c  = True; 
                   ActivityContactList .add(c);
                }
                 insert ActivityContactList ;                
            // update task
           // t.DTFlag__c = True;
           // update t;
            System.debug('New ActivityContactList Object: ' + ActivityContactList );
            }
        
          }
           catch (Exception e) {
           System.debug('Exception: ' + e);            
           }
        
           // Set the result to true, no need to send an email back to the user
           // with an error message
           result.success = true;        
          // Return the result for the Force.com Email Service
          return result;
 }  
      
}