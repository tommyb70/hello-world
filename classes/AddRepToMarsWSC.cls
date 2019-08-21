global class AddRepToMarsWSC {

 public class MySoapException extends Exception{}
  //public static string RepWebServiceURL = 'https://servicestest.ngam.natixis.com/repsvc/RepSvc.svc';
     static NGAMSettings__c myRepServiceSetting = NGAMSettings__c.getValues('NGAM_ALL');
     static string RepWebServiceURL = myRepServiceSetting.RepService__c;
   
    
   @future (callout=true)
    public static void addRepMarsById(String ContactId) {          
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
       
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting);
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting.RepService__c);
          
       Contact c= [SELECT Id , FirstName, LastName, Email,Phone, MailPreference__c,CallPreference__c, EmailPreference__c,Fax , lastModifiedBy.UserId__c, CreatedBy.UserId__c, Account.Name, Account.Id, Account.MarsAccountId__c,RecordType.Name,MarsRepId__c FROM Contact WHERE Id= :ContactId];
       
       
       req.setEndpoint(RepWebServiceURL);
       req.setMethod('POST');
       req.setHeader('Content-Type', 'text/xml');
       req.setHeader( 'SOAPAction', 'http://ga.natixis.com/RepSvc/IRepSvc/AddMarsRepSf');
       req.setTimeout(2*60*1000);  // 2 minutes

     
       String  Id = c.Id;
       String  FirstName = c.FirstName;
       String  MiddleName = '';
       String  LastName = c.LastName;
       String  Email = !String.isBlank(c.Email) ? c.Email : '';
       String  OffId = c.Account.MarsAccountId__c;
       String  WorkPhone = c.Phone;
       String  WorkFax =c.Fax ;
       String  ContactType =  'Rep/Staff'; //c.RecordType.Name ;
       String  CallPreference= c.CallPreference__c;
       String  MailPreference= c.MailPreference__c;
       String  EmailPreference= c.EmailPreference__c;
       String  CreatedBy = c.CreatedBy.UserId__c;
       String  ModifiedBy =c.lastModifiedBy.UserId__c;
       
       if(String.isBlank(CallPreference)) CallPreference ='NEVER';
       if(String.isBlank(MailPreference)) MailPreference ='NEVER';      
       if(String.isBlank(EmailPreference)) EmailPreference ='NEVER';
        
          String  miSoap='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" >' ;
          miSoap = miSoap + '<s:Header>' ; 
          miSoap = miSoap + '<h:UserAuth xmlns:h="http://ga.natixis.com/RepSvc" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
          miSoap = miSoap + '<h:Login>crmod</h:Login>' ;
          miSoap = miSoap + '<h:Password>Natixis1</h:Password>' ;
          miSoap = miSoap + '</h:UserAuth>' ;
          miSoap = miSoap + '</s:Header>' ; 
          miSoap = miSoap + '<s:Body>' ; 
          miSoap = miSoap + '<AddMarsRepSf xmlns="http://ga.natixis.com/RepSvc">' ; 
          miSoap = miSoap + '<c xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ; 
          miSoap = miSoap + '<CallPreference >'+ CallPreference +'</CallPreference>' ; 
          miSoap = miSoap + '<ContactType>' + ContactType + '</ContactType>' ;
          miSoap = miSoap + '<CreatedBy>' + CreatedBy + '</CreatedBy>'; 
          miSoap = miSoap + '<Email >' + Email + '</Email>' ;
          miSoap = miSoap + '<EmailPreference >'  + EmailPreference + '</EmailPreference>' ; 
          miSoap = miSoap + '<FirstName >' + FirstName + '</FirstName>' ;
          miSoap = miSoap + '<LastName  >' + LastName +  '</LastName>' ; 
          miSoap = miSoap + '<MailPreference  > ' + MailPreference + '</MailPreference>'; 
          miSoap = miSoap + '<MiddleName  > ' + MiddleName+ '</MiddleName>' ; 
          miSoap = miSoap + '<ModifiedBy>' + ModifiedBy + '</ModifiedBy>'; 
          miSoap = miSoap + '<OffId>'+ OffId  + '</OffId>' ;
          miSoap = miSoap + '<RowId>' + Id  + '</RowId>' ;
          miSoap = miSoap + '<WorkFax >'+ WorkFax +'</WorkFax>' ; 
          miSoap = miSoap + '<WorkPhone >' + WorkPhone +'</WorkPhone>' ; 
          miSoap = miSoap + '<OffSfId>'+ c.Account.Id +'</OffSfId>' ; 
          miSoap = miSoap + '<RepMarsID ></RepMarsID>' ; 
          miSoap = miSoap + '</c>' ; 
          miSoap = miSoap + '</AddMarsRepSf>' ; 
          miSoap = miSoap + '</s:Body>' ; 
          miSoap = miSoap + '</s:Envelope>'; 
          req.setBody(miSoap );
          //req.setHeader('Content-Length',String.valueof(req.getBody().length()));        
          System.debug(' -------- '+ req.getBody());
          System.debug(' Header SOAPAction-------- '+ req.getHeader('SOAPAction'));
               
          System.debug( 'req ----------------------------------' + req);

        try {
        List<Contact> updateContact = new List<Contact>();  
            //if (!Test.isRunningTest()) 
                            //{
                            res = http.send(req);
                            //}
               System.debug( 'res ---------------------' + res.toString());
               System.debug( 'res body---------------------' + res.getBody());
               System.debug( 'res status---------------------' + res.getStatus());
               if( res.getStatusCode() == 200){  
                 long MarsID = 0;                               
                 List<String> XMLData = new List<String>();
                 String strXML = res.getBody();
                 System.debug('----Inside Respose handler -----'+strXml);
                 Dom.Document doc = new Dom.Document();
                 doc.load(strXml);
                 //Retrieve the root element for this document.
                 Dom.XMLNode Envelope = doc.getRootElement();     
                 Dom.XMLNode Body= Envelope.getChildElements()[0];
                 System.debug('####Inside XMLParser Method########'+Body);
                 Dom.XMLNode response= Body.getChildElements()[0];
                 Dom.XMLNode resul= response.getChildElements()[0];
                System.debug('node type Result ---------------------' + resul.getNodeType());
                System.debug('Result  text---------------------' +  resul.getText());
                c.MarsRepId__c = resul.getText();
                }

                if( !String.IsBlank(c.MarsRepId__c) ) {
                string marsid= c.MarsRepId__c;
                   System.debug('Mars rep id text---------------------' +  c.MarsRepId__c);
                   List<Contact> MyContacts = [SELECT Id , MarsRepId__c FROM Contact WHERE MarsRepId__c= :marsid and Id !=  :c.Id];
                  
                    if( MyContacts.isEmpty() ) 
                        {
                        updateContact.add(c) ;      
                        }
                    else
                        {                 
                        throw new MySoapException ('Contact already exist in Salesforce, sending the request to delete from MARS');
                        }
                }        
                if( updateContact.size()> 0 ) {
                
                        update updateContact;
                        SendEmail('Successfully created the contact in MARS with Mars Id and updated salesforce account ' + c.MarsRepId__c, 'Successfully created the contact in MARS with Mars Id ' + c.MarsRepId__c );

               } 
                
                                                
    } catch(System.Exception e ) {
         System.debug('Callout error: '+ e);
         SendEmail('Exception Error: ' + e  + ' Request ' +  req.toString(), 'Error in creating the Contact from MARS -  ContactID '+ ContactId);

         System.debug(res.toString());            
         System.debug('Update Rep failed ----------------: '+ e);
         if( !String.IsBlank(c.MarsRepId__c) ) {
         System.debug(' send the delete for  : '+ c.MarsRepId__c);       
         DeleteRepMarsById(c.MarsRepId__c);
        }
     }

    }


 // @future (callout=true)  
   public static void DeleteRepMarsById( string RepMarsID  ) { 
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting);
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting.RepService__c);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String temp='' ;
        Http http = new Http();               
        req.setEndpoint(RepWebServiceURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader( 'SOAPAction', 'http://ga.natixis.com/RepSvc/IRepSvc/DeleteMarsRepSf');
        string  miSoap='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" >' ;
        miSoap = miSoap + '<s:Header>' ; 
        miSoap = miSoap + '<h:UserAuth xmlns:h="http://ga.natixis.com/RepSvc" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
        miSoap = miSoap + '<h:Login>crmod</h:Login>' ;
        miSoap = miSoap + '<h:Password>Natixis1</h:Password>' ;
        miSoap = miSoap + '</h:UserAuth>' ;
        miSoap = miSoap + '</s:Header>' ; 
        miSoap = miSoap + '<s:Body>' ; 
        miSoap = miSoap + '<DeleteMarsRepSf xmlns="http://ga.natixis.com/RepSvc">' ; 
        miSoap = miSoap + '<RepMarsID>' +  RepMarsID   + '</RepMarsID>' ; 
        miSoap = miSoap + '</DeleteMarsRepSf>' ; 
        miSoap = miSoap + '</s:Body>' ; 
        miSoap = miSoap + '</s:Envelope>'; 
        req.setBody(miSoap );
       
        System.debug(' -------- '+ req.getBody());
        System.debug(' Header SOAPAction-------- '+ req.getHeader('SOAPAction'));
  
    try {
            //res = http.send(req);
            //if (!Test.isRunningTest()) 
                //{
                res = http.send(req);
                //}  
               System.debug( 'res ---------------------' + res.toString());
               System.debug( 'res body---------------------' + res.getBody());
               System.debug( 'res status---------------------' + res.getStatus());
               if( res.getStatusCode() == 200){  
                 long MarsID = 0;                               
                 List<String> XMLData = new List<String>();
                 String strXML = res.getBody();
                 System.debug('----Inside Respose handler -----'+strXml);
                 Dom.Document doc = new Dom.Document();
                 doc.load(strXml);
                 //Retrieve the root element for this document.
                 Dom.XMLNode Envelope = doc.getRootElement();     
                 Dom.XMLNode Body= Envelope.getChildElements()[0];
                 System.debug('----Response body---- '+Body);
                 Dom.XMLNode response= Body.getChildElements()[0];
                 Dom.XMLNode resul= response.getChildElements()[0];
                 System.debug('node type Result ---------------------' + resul.getNodeType());
                 System.debug('Result  text---------------------' +  resul.getText());   
                 if( resul.getText()  == 'false')
                 {
                   System.debug('ERROR: could not delete the rep from mars' + RepMarsID);
                    SendEmail('Could not delete Contact from MARS - '+ RepMarsID  , 'Could not delete Contact from MARS - '+ RepMarsID  );
                 }  
                 else
                 {
                     System.debug('Successfully deleted the rep from mars' + RepMarsID);
                     //SendEmail('Successfully Deleted Contact from MARS - '+ RepMarsID  , 'Successfully Deleted Contact from MARS - '+ RepMarsID  );

                 }         
                }    
            
       } catch(System.Exception e ) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            SendEmail('Exception Error: ' + e, 'Error in Deleting the Contact from MARS - '+ RepMarsID  );
        }

  
  }
  
  
 public static void SendEmail(string message, string subject) { 

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC - Call Rep service ');
            mail.setSubject(subject);
            mail.setHTMLBody(message);
            if(!Test.isRunningTest()) {
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
 }  



}