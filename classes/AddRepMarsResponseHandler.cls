global class AddRepMarsResponseHandler implements Messaging.InboundEmailHandler {    
global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                  Messaging.InboundEnvelope env){
        
        // Create an inboundEmailResult object 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();        
        String myPlainText = email.plainTextBody;
        String ContactID = '';
        String MarsID ='';
        System.debug('email body' + myPlainText );
        result.success = true; 
                
        try{
        myPlainText = email.plainTextBody.substring(email.plainTextBody.indexOf('<Contact>') + 9, email.plainTextBody.indexOf('</Contact>'));
        String[] str = myPlainText.split('#');
        ContactID = str[0];
        MarsID  = str[1];
        } catch(Exception Ex){
        System.debug(' Error in Parsing the email ' + myPlainText );
      }

if( !String.isBlank(MarsID) && ( !String.isBlank(ContactID)))
{
       try {
            System.debug('Contact ID ' + ContactID);
            System.debug(' MarsID' + MarsID);
               List<Contact> ContactList = [SELECT Id, MarsRepId__c, Email, FirstName, LastName FROM Contact WHERE Id= :ContactID];
               if(ContactList.size() > 0 ) 
               {   
               Contact c = ContactList[0];  
               List<Contact> MyContacts = [SELECT Id , MarsRepId__c FROM Contact WHERE MarsRepId__c= :MarsID];
                    if(MyContacts.isEmpty() &&  !String.isBlank(MarsID) && String.isBlank(c.MarsRepId__c)) 
                    {                       
                         System.debug(' Updating the MARS Rep ID ' + MarsID);
                         c.MarsRepId__c = MarsID;
                         update c; 
                     }
                  }
             }    catch (Exception e) {
                     System.debug('Exception: ' + e);                     
          }     
   }   
          return result;
      }  
      
}