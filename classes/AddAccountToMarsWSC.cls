global class AddAccountToMarsWSC {

 public class MySoapException extends Exception{}
  //public static string RepWebServiceURL = 'https://servicestest.ngam.natixis.com/repsvc/RepSvc.svc';
     static NGAMSettings__c myRepServiceSetting = NGAMSettings__c.getValues('NGAM_ALL');
     static string RepWebServiceURL = myRepServiceSetting.RepService__c;
     public static string MathodNameForTest = 'AddAccountMarsById';
   
    
   @future (callout=true)
    public static void AddAccountMarsById(String AccountId) {  
MathodNameForTest = 'AddAccountMarsById';        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
         long MarsID = 0;                               
         List<String> XMLData = new List<String>();
       
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting);
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting.RepService__c);
          
       Account acc = [SELECT Fax,BillingCounty__c,Channel__c, NumberOfEmployees, Id, IsDeleted, MasterRecordId, Name, Type, RecordType.Name, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude, BillingAddress, Phone, AccountNumber, Website, Industry, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, MarsAccountId__c, FirmOfficeID18__c, FirmType__c, FirmOfficeD15__c, Status__c, CRDID__c, FINSearchId__c, HomeOfficeId__c, Territories__c, MyTerritory__c,Parent.Id  , Parent.MarsAccountId__c,Parent.Name ,CreatedBy.UserId__c,lastModifiedBy.UserId__c,ShippingCity ,ShippingCountry ,ShippingCountryCode,ShippingLatitude ,ShippingLongitude ,ShippingPostalCode ,ShippingState,ShippingStateCode ,ShippingStreet ,Zone__c FROM Account where MarsAccountId__c = null and Id= :AccountId];
       
       
       req.setEndpoint(RepWebServiceURL);
       req.setMethod('POST');
       req.setHeader('Content-Type', 'text/xml');
       req.setHeader( 'SOAPAction', 'http://ga.natixis.com/RepSvc/IRepSvc/AddMarsAccountSf');
       req.setTimeout(2*60*1000);  // 2 minutes

     
       String  value = acc.Id;
       String  Name = acc.Name;
      
       String  OffId = acc.MarsAccountId__c;
       String  WorkPhone = acc.Phone;
       String  WorkFax =acc.Fax ;
      
       String  CreatedBy = acc.CreatedBy.UserId__c;
       String  ModifiedBy =acc.lastModifiedBy.UserId__c;
       
     
        
          String  miSoap='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" >' ;
          miSoap = miSoap + '<s:Header>' ; 
          miSoap = miSoap + '<h:UserAuth xmlns:h="http://ga.natixis.com/RepSvc" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
          miSoap = miSoap + '<h:Login>crmod</h:Login>' ;
          miSoap = miSoap + '<h:Password>Natixis1</h:Password>' ;
          miSoap = miSoap + '</h:UserAuth>' ;
          miSoap = miSoap + '</s:Header>' ; 
          miSoap = miSoap + '<s:Body>' ; 
          miSoap = miSoap + '<AddMarsAccountSf xmlns="http://ga.natixis.com/RepSvc">' ; 
          miSoap = miSoap + '<newAccount xmlns:i="http://www.w3.org/2001/XMLSchema-instance">';
              //<c xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
 if(acc.AccountNumber != null)   miSoap = miSoap + '<AccountNumber>'  + acc.AccountNumber + '</AccountNumber>';
 if(acc.Type != null) miSoap = miSoap + '<AccountType>'  + acc.Type + '</AccountType>';
 //miSoap = miSoap + '<BillingAddress>'  + acc.BillingAddress + '</BillingAddress>';
 if(acc.BillingCity != null) miSoap = miSoap + '<BillingCity>'  + acc.BillingCity + '</BillingCity>';
 if(acc.BillingCountry != null) miSoap = miSoap + '<BillingCountry>' + acc.BillingCountry + '</BillingCountry>';
 if(acc.BillingCountryCode != null) miSoap = miSoap + '<BillingCountryCode>' + acc.BillingCountryCode + '</BillingCountryCode>';
 if(acc.BillingCounty__c != null) miSoap = miSoap + '<BillingCounty__c>' + acc.BillingCounty__c + '</BillingCounty__c>';
// if(acc.BillingGeocodeAccuracy != null)  miSoap = miSoap + '<BillingGeocodeAccuracy>' + acc.BillingGeocodeAccuracy + '</BillingGeocodeAccuracy>';
  if(acc.BillingLatitude != null)  miSoap = miSoap + '<BillingLatitude>' + acc.BillingLatitude + '</BillingLatitude>';
  if(acc.BillingLongitude != null) miSoap = miSoap + '<BillingLongitude>' + acc.BillingLongitude + '</BillingLongitude>';
  if(acc.BillingPostalCode != null) miSoap = miSoap + '<BillingPostalCode>' + acc.BillingPostalCode + '</BillingPostalCode>';
  if(acc.BillingState != null)  miSoap = miSoap + '<BillingState>' + acc.BillingState + '</BillingState>';
 if(acc.BillingStateCode != null) miSoap = miSoap + '<BillingStateCode>' + acc.BillingStateCode + '</BillingStateCode>';
 if(acc.BillingStreet != null)  miSoap = miSoap + '<BillingStreet>' + acc.BillingStreet + '</BillingStreet>';
 if(acc.CRDID__c != null)  miSoap = miSoap + '<CRDID__c>' + acc.CRDID__c + '</CRDID__c>';
 if(acc.Channel__c != null)  miSoap = miSoap + '<Channel__c>' + acc.Channel__c + '</Channel__c>';
 if(CreatedBy != null) miSoap = miSoap + '<CreatedBy>' + CreatedBy + '</CreatedBy>';
 if(acc.CreatedById != null)  miSoap = miSoap + '<CreatedById>' + acc.CreatedById + '</CreatedById>';
 if(acc.CreatedDate != null) miSoap = miSoap + '<CreatedDate>' + acc.CreatedDate + '</CreatedDate>';
 if(acc.Description != null) miSoap = miSoap + '<Description>' + acc.Description + '</Description>';
 if(acc.FINSearchId__c != null) miSoap = miSoap + '<FINSearchId__c>' + acc.FINSearchId__c + '</FINSearchId__c>';
 if(acc.Fax != null)  miSoap = miSoap + '<Fax>' + acc.Fax + '</Fax>';
  if(acc.Parent != null )  miSoap = miSoap + '<FirmID>' + acc.Parent.MarsAccountId__c + '</FirmID>';
  if(acc.Parent != null ){  acc.Parent.Name  = acc.Parent.Name.replace('&','&amp;'); miSoap = miSoap + '<FirmName>' + acc.Parent.Name + '</FirmName>'; }
  if(acc.FirmOfficeD15__c != null ) miSoap = miSoap + '<FirmOfficeD15__c>' + acc.FirmOfficeD15__c + '</FirmOfficeD15__c>';
  if(acc.FirmOfficeID18__c != null ) miSoap = miSoap + '<FirmOfficeID18__c>' + acc.FirmOfficeID18__c + '</FirmOfficeID18__c>';
  if(acc.ParentId != null )miSoap = miSoap + '<FirmSfID>' + acc.ParentId + '</FirmSfID>';
  if(acc.FirmType__c != null ) miSoap = miSoap + '<FirmType__c>' + acc.FirmType__c + '</FirmType__c>';
  if(acc.HomeOfficeId__c != null ) miSoap = miSoap + '<HomeOfficeID>' + acc.HomeOfficeId__c + '</HomeOfficeID>';
  if(acc.HomeOfficeId__c != null ) miSoap = miSoap + '<HomeOfficeId__c>' + acc.HomeOfficeId__c + '</HomeOfficeId__c>';
  if(acc.Id != null ) miSoap = miSoap + '<Id>' + acc.Id + '</Id>';
 if(acc.Industry != null ) miSoap = miSoap + '<Industry>' + acc.Industry + '</Industry>';
 if(acc.IsDeleted != null ) miSoap = miSoap + '<IsDeleted>' + acc.IsDeleted + '</IsDeleted>' ;
 if(acc.LastModifiedById != null )  miSoap = miSoap + '<LastModifiedById>' + acc.LastModifiedById + '</LastModifiedById>';
 if(acc.LastModifiedDate != null )  miSoap = miSoap + '<LastModifiedDate>' + acc.LastModifiedDate + '</LastModifiedDate>';
 if(ModifiedBy != null ) miSoap = miSoap + '<LastModifieldBy>' + ModifiedBy + '</LastModifieldBy>';
 if(acc.MarsAccountId__c != null ) miSoap = miSoap + '<MarsAccountId__c>' + acc.MarsAccountId__c + '</MarsAccountId__c>';
  if(acc.MasterRecordId != null ) miSoap = miSoap + '<MasterRecordId>' + acc.MasterRecordId + '</MasterRecordId>';
 if(acc.MyTerritory__c != null ) miSoap = miSoap + '<MyTerritory__c>' + acc.MyTerritory__c + '</MyTerritory__c>';
        if(acc.Name != null ) { acc.Name  = acc.Name.replace('&','&amp'); miSoap = miSoap + '<Name>' + acc.Name + '</Name>'; }
 if(acc.NumberOfEmployees != null ) miSoap = miSoap + '<NumberOfEmployees>' + acc.NumberOfEmployees + '</NumberOfEmployees>';
 if(acc.OwnerId != null ) miSoap = miSoap + '<OwnerId>' + acc.OwnerId + '</OwnerId>';
 if(acc.ParentId != null ) miSoap = miSoap + '<ParentId>' + acc.ParentId + '</ParentId>';
 if(acc.Phone != null ) miSoap = miSoap + '<Phone>' + acc.Phone + '</Phone>';
if(acc.RecordType != null ) miSoap = miSoap + '<RecordType>' + acc.RecordType.Name + '</RecordType>'; 
if(acc.RecordTypeId != null )   miSoap = miSoap + '<RecordTypeId>' + acc.RecordTypeId + '</RecordTypeId>';
// miSoap = miSoap + '<RecordTypeId>' + value + '</RecordTypeId>';
// miSoap = miSoap + '<ShippingAddress>' + value + '</ShippingAddress>';
if(acc.ShippingCity != null )  miSoap = miSoap + '<ShippingCity>' + acc.ShippingCity + '</ShippingCity>';
if(acc.ShippingCountry != null )  miSoap = miSoap + '<ShippingCountry>' + acc.ShippingCountry + '</ShippingCountry>';
if(acc.ShippingCountryCode != null ) miSoap = miSoap + '<ShippingCountryCode>' + acc.ShippingCountryCode + '</ShippingCountryCode>';
//if(acc.ShippingGeocodeAccuracy != null )miSoap = miSoap + '<ShippingGeocodeAccuracy>' + acc.ShippingGeocodeAccuracy + '</ShippingGeocodeAccuracy>';
if(acc.ShippingLatitude != null ) miSoap = miSoap + '<ShippingLatitude>' + acc.ShippingLatitude + '</ShippingLatitude>';
if(acc.ShippingLongitude != null ) miSoap = miSoap + '<ShippingLongitude>' + acc.ShippingLongitude + '</ShippingLongitude>';
if(acc.ShippingPostalCode != null ) miSoap = miSoap + '<ShippingPostalCode>' + acc.ShippingPostalCode + '</ShippingPostalCode>';
if(acc.ShippingState != null ) miSoap = miSoap + '<ShippingState>' + acc.ShippingState + '</ShippingState>';
if(acc.ShippingStateCode != null ) miSoap = miSoap + '<ShippingStateCode>' + acc.ShippingStateCode + '</ShippingStateCode>';
if(acc.ShippingStreet != null )  miSoap = miSoap + '<ShippingStreet>' + acc.ShippingStreet + '</ShippingStreet>';
if(acc.Status__c != null ) miSoap = miSoap + '<Status__c>' + acc.Status__c + '</Status__c>';
if(acc.Territories__c != null ) miSoap = miSoap + '<Territories__c>' + acc.Territories__c + '</Territories__c>';
if(acc.Type != null ) miSoap = miSoap + '<Type>' + acc.Type + '</Type>';
if(acc.Website != null ) miSoap = miSoap + '<Website>' + acc.Website + '</Website>';
if(acc.Zone__c != null ) miSoap = miSoap + '<Zone__c>' + acc.Zone__c + '</Zone__c>';
       
          miSoap = miSoap + '</newAccount>' ; 
          miSoap = miSoap + '</AddMarsAccountSf>' ; 
          miSoap = miSoap + '</s:Body>' ; 
          miSoap = miSoap + '</s:Envelope>'; 
          req.setBody(miSoap );
          //req.setHeader('Content-Length',String.valueof(req.getBody().length()));        
          System.debug(' -------- '+ req.getBody());
          System.debug(' Header SOAPAction-------- '+ req.getHeader('SOAPAction'));
               
          System.debug( 'req ----------------------------------' + req);

        try {
        List<Account> updateList = new List<Account>(); 
             String recordTypePrefix = 'OF';
                if ( (acc.RecordType != null) && ( acc.RecordType.Name == 'Firm')) recordTypePrefix = 'FR';
               
           // if (!Test.isRunningTest()) 
                            //{
                            res = http.send(req);
                            //}
               System.debug( 'res ---------------------' + res.toString());
               System.debug( 'res body---------------------' + res.getBody());
               System.debug( 'res status---------------------' + res.getStatus());
               if( res.getStatusCode() == 200){  
                
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
                acc.MarsAccountId__c =  resul.getText();
                }

                if( !String.IsBlank(acc.MarsAccountId__c) ) {
                  acc.MarsAccountId__c =   recordTypePrefix + acc.MarsAccountId__c;
                string marsidnew = acc.MarsAccountId__c;
                   System.debug('Mars rep id text---------------------' +  acc.MarsAccountId__c);
                   List<Account> MyAccounts = [SELECT Id , MarsAccountId__c FROM Account WHERE MarsAccountId__c= :marsidnew];
                  Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Id , MarsAccountId__c FROM Account WHERE MarsAccountId__c= :marsidnew]);
                    if( accountMap.isEmpty() ) 
                        {
                        System.debug('Update account'); 
                        updateList.add(acc) ;      
                        }
                    else
                        { 
                            if(accountMap.containsKey(acc.Id) && accountMap.size() == 1){ updateList.add(acc) ; }
                            else
                            {
                               throw new MySoapException ('Account already exist in Salesforce, sending the request to delete from MARS');
                            }
                            }
                }        
                if( updateList.size()> 0 ) {
                    System.debug('updateList has element'); 
                        update updateList;
                        SendEmail('Successfully created the Account in MARS with Mars Id and updated salesforce account ' + acc.MarsAccountId__c, 'Successfully created the Account in MARS with Mars Id ' + acc.MarsAccountId__c );
                }
                
                                                
    } catch(System.Exception e ) {
         System.debug('Callout error: '+ e);
         SendEmail('Exception Error: ' + e  + ' Request ' +  req.toString(), 'Error in creating the Contact from MARS -  Account '+ AccountId);
         System.debug(res.toString());            
         System.debug('Update Rep failed ----------------: '+ e);
         if( !String.IsBlank(acc.MarsAccountId__c) ) {
         System.debug(' send the delete for  : '+ acc.MarsAccountId__c);       
         DeleteAccMarsById(acc.Id,acc.MarsAccountId__c);
        }
     }
        //return res.toString();
    }


 // @future (callout=true)  
   public static void DeleteAccMarsById( string AccountId, String MarsAccountId  ) { 
       MathodNameForTest = 'DeleteAccMarsById';
   // Account acc = [SELECT Id, IsDeleted, MasterRecordId, Name, Type, RecordType.Name, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude,  BillingAddress, Phone, AccountNumber, Website, Industry, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, MarsAccountId__c, FirmOfficeID18__c, FirmType__c, FirmOfficeD15__c, Status__c, CRDID__c, FINSearchId__c, HomeOfficeId__c, Territories__c, MyTerritory__c,Parent.Id  , Parent.MarsAccountId__c,Parent.Name ,CreatedBy.UserId__c,lastModifiedBy.UserId__c FROM Account where  Status__c = 'Active' and  RecordType.Name = 'Office'  and Id= :AccountId];
   List<Account> MyAccounts = [SELECT Fax,BillingCounty__c,Channel__c, NumberOfEmployees, Id, IsDeleted, MasterRecordId, Name, Type, RecordType.Name, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude, BillingAddress, Phone, AccountNumber, Website, Industry, Description, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, MarsAccountId__c, FirmOfficeID18__c, FirmType__c, FirmOfficeD15__c, Status__c, CRDID__c, FINSearchId__c, HomeOfficeId__c, Territories__c, MyTerritory__c,Parent.Id  , Parent.MarsAccountId__c,Parent.Name ,CreatedBy.UserId__c,lastModifiedBy.UserId__c,ShippingCity ,ShippingCountry ,ShippingCountryCode,ShippingLatitude ,ShippingLongitude ,ShippingPostalCode ,ShippingState,ShippingStateCode ,ShippingStreet ,Zone__c FROM Account where Status__c = 'Active'  and Id= :AccountId];
      if(MyAccounts.isEmpty())return;
       Account acc = MyAccounts[0];
      String  CreatedBy = acc.CreatedBy.UserId__c;
      String  ModifiedBy =acc.lastModifiedBy.UserId__c;
       
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting);
       System.debug( 'myRepServiceSetting ----------------------------------' + myRepServiceSetting.RepService__c);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String temp='' ;
        Http http = new Http();               
        req.setEndpoint(RepWebServiceURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader( 'SOAPAction', 'http://ga.natixis.com/RepSvc/IRepSvc/DeleteMarsAccountSf');
        string  miSoap='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" >' ;
        miSoap = miSoap + '<s:Header>' ; 
        miSoap = miSoap + '<h:UserAuth xmlns:h="http://ga.natixis.com/RepSvc" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
        miSoap = miSoap + '<h:Login>crmod</h:Login>' ;
        miSoap = miSoap + '<h:Password>Natixis1</h:Password>' ;
        miSoap = miSoap + '</h:UserAuth>' ;
        miSoap = miSoap + '</s:Header>' ; 
        miSoap = miSoap + '<s:Body>' ; 
        miSoap = miSoap + '<DeleteMarsAccountSf xmlns="http://ga.natixis.com/RepSvc">' ; 
       // miSoap = miSoap + '<RepMarsID>' +  RepMarsID   + '</RepMarsID>' ; 
        miSoap = miSoap + '<c xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' ;
          miSoap = miSoap + '<AccountNumber>'  + acc.AccountNumber + '</AccountNumber>';
 miSoap = miSoap + '<AccountType>'  + acc.Type + '</AccountType>';
 //miSoap = miSoap + '<BillingAddress>'  + acc.BillingAddress + '</BillingAddress>';
 miSoap = miSoap + '<BillingCity>'  + acc.BillingCity + '</BillingCity>';
 miSoap = miSoap + '<BillingCountry>' + acc.BillingCountry + '</BillingCountry>';
 miSoap = miSoap + '<BillingCountryCode>' + acc.BillingCountryCode + '</BillingCountryCode>';
 miSoap = miSoap + '<BillingCounty__c>' + acc.BillingCounty__c + '</BillingCounty__c>';
// miSoap = miSoap + '<BillingGeocodeAccuracy>' + acc.BillingGeocodeAccuracy + '</BillingGeocodeAccuracy>';
 miSoap = miSoap + '<BillingLatitude>' + acc.BillingLatitude + '</BillingLatitude>';
 miSoap = miSoap + '<BillingLongitude>' + acc.BillingLongitude + '</BillingLongitude>';
 miSoap = miSoap + '<BillingPostalCode>' + acc.BillingPostalCode + '</BillingPostalCode>';
 miSoap = miSoap + '<BillingState>' + acc.BillingState + '</BillingState>';
 miSoap = miSoap + '<BillingStateCode>' + acc.BillingStateCode + '</BillingStateCode>';
 miSoap = miSoap + '<BillingStreet>' + acc.BillingStreet + '</BillingStreet>';
 miSoap = miSoap + '<CRDID__c>' + acc.CRDID__c + '</CRDID__c>';
 miSoap = miSoap + '<Channel__c>' + acc.Channel__c + '</Channel__c>';
 miSoap = miSoap + '<CreatedBy>' + CreatedBy + '</CreatedBy>';
 miSoap = miSoap + '<CreatedById>' + acc.CreatedById + '</CreatedById>';
 miSoap = miSoap + '<CreatedDate>' + acc.CreatedDate + '</CreatedDate>';
 miSoap = miSoap + '<Description>' + acc.Description + '</Description>';
 miSoap = miSoap + '<FINSearchId__c>' + acc.FINSearchId__c + '</FINSearchId__c>';
 miSoap = miSoap + '<Fax>' + acc.Fax + '</Fax>';
 miSoap = miSoap + '<FirmID>' + acc.Parent.MarsAccountId__c + '</FirmID>';
 miSoap = miSoap + '<FirmName>' + acc.Parent.Name + '</FirmName>';
 miSoap = miSoap + '<FirmOfficeD15__c>' + acc.FirmOfficeD15__c + '</FirmOfficeD15__c>';
 miSoap = miSoap + '<FirmOfficeID18__c>' + acc.FirmOfficeID18__c + '</FirmOfficeID18__c>';
 miSoap = miSoap + '<FirmSfID>' + acc.ParentId + '</FirmSfID>';
 miSoap = miSoap + '<FirmType__c>' + acc.FirmType__c + '</FirmType__c>';
 miSoap = miSoap + '<HomeOfficeID>' + acc.HomeOfficeId__c + '</HomeOfficeID>';
 miSoap = miSoap + '<HomeOfficeId__c>' + acc.HomeOfficeId__c + '</HomeOfficeId__c>';
 miSoap = miSoap + '<Id>' + acc.Id + '</Id>';
 miSoap = miSoap + '<Industry>' + acc.Industry + '</Industry>';
 miSoap = miSoap + '<IsDeleted>' + acc.IsDeleted + '</IsDeleted>' ;
 miSoap = miSoap + '<LastModifiedById>' + acc.LastModifiedById + '</LastModifiedById>';
 miSoap = miSoap + '<LastModifiedDate>' + acc.LastModifiedDate + '</LastModifiedDate>';
 miSoap = miSoap + '<LastModifieldBy>' + CreatedBy + '</LastModifieldBy>';
 miSoap = miSoap + '<MarsAccountId__c>' + acc.MarsAccountId__c + '</MarsAccountId__c>';
 miSoap = miSoap + '<MasterRecordId>' + acc.MasterRecordId + '</MasterRecordId>';
 miSoap = miSoap + '<MyTerritory__c>' + acc.MyTerritory__c + '</MyTerritory__c>';
 miSoap = miSoap + '<Name>' + acc.Name + '</Name>';
 miSoap = miSoap + '<NumberOfEmployees>' + acc.NumberOfEmployees + '</NumberOfEmployees>';
 miSoap = miSoap + '<OwnerId>' + acc.OwnerId + '</OwnerId>';
 miSoap = miSoap + '<ParentId>' + acc.ParentId + '</ParentId>';
 miSoap = miSoap + '<Phone>' + acc.Phone + '</Phone>';
 miSoap = miSoap + '<RecordType>' + acc.RecordType.Name + '</RecordType>'; 
 miSoap = miSoap + '<RecordTypeID>' + acc.RecordTypeId + '</RecordTypeID>';
// miSoap = miSoap + '<RecordTypeId>' + value + '</RecordTypeId>';
// miSoap = miSoap + '<ShippingAddress>' + value + '</ShippingAddress>';
 miSoap = miSoap + '<ShippingCity>' + acc.ShippingCity + '</ShippingCity>';
 miSoap = miSoap + '<ShippingCountry>' + acc.ShippingCountry + '</ShippingCountry>';
 miSoap = miSoap + '<ShippingCountryCode>' + acc.ShippingCountryCode + '</ShippingCountryCode>';
 //miSoap = miSoap + '<ShippingGeocodeAccuracy>' + acc.ShippingGeocodeAccuracy + '</ShippingGeocodeAccuracy>';
 miSoap = miSoap + '<ShippingLatitude>' + acc.ShippingLatitude + '</ShippingLatitude>';
 miSoap = miSoap + '<ShippingLongitude>' + acc.ShippingLongitude + '</ShippingLongitude>';
 miSoap = miSoap + '<ShippingPostalCode>' + acc.ShippingPostalCode + '</ShippingPostalCode>';
 miSoap = miSoap + '<ShippingState>' + acc.ShippingState + '</ShippingState>';
 miSoap = miSoap + '<ShippingStateCode>' + acc.ShippingStateCode + '</ShippingStateCode>';
 miSoap = miSoap + '<ShippingStreet>' + acc.ShippingStreet + '</ShippingStreet>';
 miSoap = miSoap + '<Status__c>' + acc.Status__c + '</Status__c>';
 miSoap = miSoap + '<Territories__c>' + acc.Territories__c + '</Territories__c>';
 miSoap = miSoap + '<Type>' + acc.Type + '</Type>';
 miSoap = miSoap + '<Website>' + acc.Website + '</Website>';
 miSoap = miSoap + '<Zone__c>' + acc.Zone__c + '</Zone__c>';
       
          miSoap = miSoap + '</c>' ; 

        miSoap = miSoap + '</DeleteMarsAccountSf>' ; 
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
                   System.debug('ERROR: could not delete the Account from mars' + AccountId);
                    SendEmail('Could not delete Account from MARS - '+ AccountId  , 'Could not delete Account from MARS - '+ AccountId  );
                 }  
                 else
                 {
                     System.debug('Successfully deleted the Account from mars' + AccountId);
                     //SendEmail('Successfully Deleted Contact from MARS - '+ RepMarsID  , 'Successfully Deleted Contact from MARS - '+ RepMarsID  );

                 }         
                }    
            
       } catch(System.Exception e ) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            SendEmail('Exception Error: ' + e, 'Error in Deleting the Account from MARS - '+ AccountId  );
        }

  
  }
  
  
 public static void SendEmail(string message, string subject) { 
        

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC - Call Account service ');
            mail.setSubject(subject);
            mail.setHTMLBody(message);
            if(!Test.isRunningTest()) {
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
 }



}