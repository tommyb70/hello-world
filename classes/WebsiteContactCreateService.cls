@RestResource(urlMapping='/websitecreatecontact/*')
global with sharing class WebsiteContactCreateService {

    global class Response {
        public String ContactId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Status { get; set; }
        public String Message { get; set; }
        public String ErrorCode { get; set; }            
        public boolean Verified { get; set; }
        public boolean NotApproved { get; set; }   
        public String LoginMethod { get; set; }  
        public String ContactIdCookieValue { get; set; }
        public List<ContactSalesTeam> ContactSalesTeams { get; set; }           
    }
    
    global class WebContact {
        public String Id { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Email { get; set; }
        public String CompanyName { get; set; }
        public String Phone { get; set; }
        public String State { get; set; }
        public String CrdId { get; set; }                 
        public String LoginMethod { get; set; } 
        public boolean Verified { get; set; } 
        public String Url { get; set; }  
        public String ContactIdCookieValue { get; set; }
    }
    
    global class ContactSalesTeam { 
        public String TerritoryId { get; set; }
        public String Territory { get; set; }
        public String ZoneName { get; set; }
        public decimal Zone { get; set; }
        public String UserId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Email { get; set; }
        public String Title { get; set; }
        public String Phone { get; set; }        
    }
           
    @HttpGet
    global static Response getContact() {
    
        Response r = new Response();        
        
        try 
        {        
            //Read the Request from the URL 
            String email = RestContext.request.params.get('email');
            String id = RestContext.request.params.get('id');
            String cookieId = RestContext.request.params.get('cookieId');
            String loginMethod = RestContext.request.params.get('loginmethod');
            String url = RestContext.request.params.get('url');
            
            if (String.IsBlank(email) && String.IsBlank(id)) {
                r.ErrorCode = '0003'; 
                r.Status = 'Error'; 
                r.Message = 'Fail : Email/Id is not specified'; 
                return r;
            }                                        
           
            if (!String.IsBlank(email)) {
                boolean found = false;
                String message;
                String contactId;
                String webProfileId;
                String firstName;
                String lastName;
                String state;
                String phone;
                String compName;
                String crdId;
                Boolean notApproved;
                Boolean verified;  
                String contactIdCookieValue;             
                
                ContactWebProfile__c [] cwps = [select id, email__c, FirstName__c, LastName__c, CompanyName__c, Phone__c, State__c, CRDId__C, NotApproved__c, Verified__c, contact__r.id, contactIdCookieValue__c from ContactWebProfile__c where email__c = :email];                      
                
                if (cwps.size() == 0) {
                    Contact[] contacts = [select Id, MarsRepId__c, Email, FirstName, LastName, Phone, CRDID__c, Account.Name, MailingStateCode from Contact where email = :email and repContactType__c != 'Team'];
                    
                    system.debug('con size:'+ contacts.size());
                                    
                    if (contacts.size() == 1) {
                        String cwpId = createContactWebProfile(contacts[0].FirstName, contacts[0].LastName, email, contacts[0].Account.Name, contacts[0].Phone,
                                            contacts[0].MailingStateCode, contacts[0].CRDID__c, contacts[0].id, loginMethod);
                        contactId = contacts[0].id;
                        webProfileId = cwpId;
                        firstName = contacts[0].FirstName;
                        lastName = contacts[0].LastName;
                        compName = contacts[0].Account.Name;
                        phone = contacts[0].Phone;
                        state = contacts[0].MailingStateCode;
                        crdId = contacts[0].CRDID__c;                        
                        found = true;
                        notApproved = null;
                        verified = null;
                    }                    
                } 
                else if (cwps.size() > 1) {
                    found = false;
                    message = 'Fail : Multiple Contact Web Profiles found';
                }
                else {
                    contactId = cwps[0].contact__r.id;
                    webProfileId = cwps[0].id;
                    firstName = cwps[0].FirstName__c;
                    lastName = cwps[0].LastName__c;
                    compName = cwps[0].CompanyName__c;
                    phone = cwps[0].Phone__c;
                    state = cwps[0].State__c;
                    crdId = cwps[0].CRDID__c;   
                    notApproved = cwps[0].NotApproved__c;
                    verified = cwps[0].Verified__c;   
                    contactIdCookieValue = cwps[0].contactIdCookieValue__c;            
                    found = true;
                }                
                
                if (found == true) {            
                    r.Status = 'Success'; 
                    r.ErrorCode = null; 
                    r.Message = 'Success : Found Contact'; 
                    r.ContactId = contactId;
                    r.NotApproved = notApproved;
                    r.Verified = verified;
                    r.FirstName = firstName;
                    r.LastName = lastName;
                    r.contactIdCookieValue = contactIdCookieValue;
                    
                    String des = 'First Name:'+firstName+'\r\nLast Name:'+lastName+'\r\nEmail:'+email+
                            '\r\nPhone:'+phone+'\r\nState:'+state+'\r\nCrd Id:'+crdId+'\r\nContact Id:'+contactId;
                    String paId = createPortalActivity(contactId, 'Login', loginMethod, url, des);
                } else {
                    r.ErrorCode = '0002'; 
                    r.Status = 'Error'; 
                    r.Message = String.IsBlank(message) ? 'Fail : Contact with email ' + email + ' Not Found' : message; 
                }
            }
            else if (!String.IsBlank(id)) {
                 Contact[] c = [select Id, MarsRepId__c, Email, FirstName, LastName, Phone, CRDID__c, Account.Name, MailingStateCode, (select id, contactIdCookieValue__c, NotApproved__c, Verified__c from ContactWebProfiles__r) from Contact where id=:id]; 
                 
                 system.debug('Hello:'+c);
                 if (c.size() == 0) {
                    r.ErrorCode = '0002'; 
                    r.Status = 'Error'; 
                    r.Message = 'Fail : Contact with id ' + id + ' Not Found'; 
                 }
                 else {
                    r.Status = 'Success'; 
                    r.ErrorCode = null; 
                    r.Message = 'Success : Found Contact'; 
                    r.ContactId = id;
                    r.NotApproved = c[0].ContactWebProfiles__r[0].NotApproved__c;
                    r.Verified = c[0].ContactWebProfiles__r[0].Verified__c;
                    r.FirstName = c[0].FirstName;
                    r.LastName = c[0].LastName;
                    r.ContactIdCookieValue = c[0].ContactWebProfiles__r[0].contactIdCookieValue__c;
                    
                    String des = 'First Name:'+c[0].FirstName+'\r\nLast Name:'+c[0].LastName+'\r\nEmail:'+c[0].Email+
                            '\r\nPhone:'+c[0].Phone+'\r\nState:'+c[0].MailingStateCode+'\r\nCrd Id:'+c[0].CrdId__c+'\r\nContact Id:'+id;
                    String paId = createPortalActivity(id, 'Login', loginMethod, url, des);
                 } 
            }
        }  
        catch(Exception e)  
        { 
             //Add custom error code when you could not insert a record 
             r.ErrorCode = '0001'; 
             r.Status = 'Error'; 
             r.Message = e.getMessage(); 
        } 
        return r;      
    }
    
    @HttpPost
    global static Response addContact(WebContact req) {
        //String requestBody = RestContext.request.requestBody.toString();
        //WebContact req = (WebContact) JSON.deserialize(requestBody, WebContact.class); 
        
        system.debug('req:'+req);        
        
        Response r = new Response();
        
        //system.debug('Fm:'+ firstname + 'Lm:'+lastname+ 'email:'+email+'comp:'+companyName+'phone:'+phone+'state:'+state+'crdId:'+crdid);
        
        if (String.isBlank(req.FirstName) || string.isBlank(req.LastName) || String.isBlank(req.Email)) {            
            r.ErrorCode = '0003';
            r.Status = 'Error';
            r.Message = 'The first name and last name and email cannot be empty for a contact';
            return r;
        }       
        
        try {
            // Create contact
            String contactId = createContact(req.FirstName, req.LastName, req.Phone, req.CrdId);
            
            system.debug('Hello:'+contactId);
            
            //Create contact web profile
            String cwpId = createContactWebProfile(req.FirstName, req.LastName, req.Email, req.CompanyName, req.Phone, req.State, req.CrdId, contactId, req.LoginMethod);           
                      
            // Create portal activity
            String paDesc = 'First Name:'+req.FirstName+'\r\nLast Name:'+req.LastName+'\r\nEmail:'+req.Email+'\r\nCompany Name:'+req.CompanyName+
                            '\r\nPhone:'+req.Phone+'\r\nState:'+req.State+'\r\nCrd Id:'+req.CrdId+'\r\nContact Id:'+contactId;
            String paId = createPortalActivity(contactId, 'Login', req.LoginMethod, req.Url, paDesc);
            
            system.debug('activity:'+ paId);
            
            r.Status = 'Success'; 
            r.ErrorCode = null; 
            r.Message = 'Success : Created contact, contact web profile and portal activity'; 
            r.ContactId = contactId;
        }
        catch(Exception ex) {
             r.ErrorCode = '0003'; 
             r.Status = 'Error'; 
             r.Message = ex.getMessage(); 
        }
        
        return r;
    }       
    
    private static String createContactWebProfile(String firstName, String lastName, String email, String companyName, String phone, String state, String crdId, String contactId, String source) {
    system.debug('CWP:'+ contactId);
        ContactWebProfile__c cwp = new ContactWebProfile__c(
            FirstName__c = firstName,
            LastName__c = lastName,
            Email__c = email,
            CompanyName__c = companyName,
            Phone__c = phone,
            State__c = state,
            CRDId__c = crdId,
            Contact__c = contactId,
            RegistrationSource__c = source
        );
        
        insert cwp;
        return cwp.Id;
    }
    
    private static String createContact(String firstname, String lastname,
        String phone, String crdid) {
        system.debug('con:'+firstname + ' '+lastname+ ' '+ phone+ ' '+ crdid);
        String officeId = 'OF882244';
        Contact c = new Contact(
            FirstName = firstname,
            LastName = lastname,
            Phone = phone,
            RecordType = new RecordType (Name='Rep/Contact'),
            RepContactType__c = 'Rep/Contact',
            Account = new account(MarsAccountId__c = officeId),  
            CrdID__c = crdid,
            Ownerid = '005F0000003xza2IAA'
        );
        insert c;
        return c.Id;
    }  
           
    private static String createPortalActivity(String contactId, String action, String loginMethod, String url, String description) {
        PortalActivity__c pa = new PortalActivity__c (
            EventTime__c = system.now(),
            Contact__c = contactId,            
            Action__c = action,
            LoginMethod__c = loginMethod,
            Url__c = url,
            Source__c = 'NGAM Website',
            Description__c = description,
            RepId__c = contactId,
            Ownerid = '005F0000003xza2IAA'
        );
        insert pa;
        return pa.Id;       
    }
}