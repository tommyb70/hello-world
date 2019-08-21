@RestResource(urlMapping='/websiteupdatecontact/*')
global with sharing class WebsiteContactUpdateService {
   
   
    @HttpPost
    global static WebsiteContactCreateService.Response updateContact(WebsiteContactCreateService.WebContact req) {
    
        WebsiteContactCreateService.Response r = new WebsiteContactCreateService.Response();     
    
        system.debug('req:'+req.Id + ' '+ req.Verified + ' ' + req.ContactIdCookieValue);
        if (String.isBlank(req.Id)) {
            r.ErrorCode = '0003'; 
            r.Status = 'Error';
            r.Message = 'Contact Id is not specified';
            return r;
        }
        if (req.Verified == null && req.ContactIdCookieValue == null) {
            r.ErrorCode = '0003'; 
            r.Status = 'Error';
            r.Message = 'Contact Id and verified is not specified';
            return r;
        }
        
        try {
            Contact [] c = [select Id, MarsRepId__c, Email, FirstName, LastName, Phone, CRDID__c, Account.Name, MailingStateCode, (select Id, email__c, phone__c, crdid__c, NotApproved__c,state__c, ContactIdCookieValue__c from contactwebprofiles__r) from Contact where Id=:req.id];
            
            if (c.size() == 0) {                
                r.ErrorCode = '0002'; 
                r.Status = 'Error';
                r.Message = 'Contact ' + req.Id + ' is not found';
                return r;               
            }
            
            if (c[0].contactwebprofiles__r.size() == 0) {
                r.ErrorCode = '0002'; 
                r.Status = 'Error';
                r.Message = 'Contact Web Profile for the contact with the contact Id ' + req.Id + ' is not found';
                return r;
            }
            
            if (req.ContactIdCookieValue != null) {
                r = updateContactCookieValue(c[0], req.ContactIdCookieValue);
            } if (req.Verified != null) {
                r = updateContactVerifiedValue(c[0], req.Verified);
            }
        } catch(Exception ex) { 
            r.ErrorCode = '0001';
            r.Status = 'Error'; 
            r.Message = ex.getMessage();
        }   
        return r;
        /*if (String.isBlank(req.Id) || req.Verified == null) {
            r.ErrorCode = '0003'; 
            r.Status = 'Error';
            r.Message = 'Contact Id or verified is not specified';
            return r;
        }
        
        if (req.Verified == false) {
            r.ErrorCode = '0003'; 
            r.Status = 'Error';
            r.Message = 'Verified is not true';
            return r;
        }    
                    
        try {
            Contact [] c = [select Id, MarsRepId__c, Email, FirstName, LastName, Phone, CRDID__c, Account.Name, MailingStateCode, (select Id, email__c, phone__c, crdid__c, NotApproved__c,state__c from contactwebprofiles__r) from Contact where Id=:req.id];
            
            if (c.size() == 0) {                
                r.ErrorCode = '0002'; 
                r.Status = 'Error';
                r.Message = 'Contact ' + req.Id + ' is not found';
                return r;               
            }
            
            if (c[0].contactwebprofiles__r.size() == 0) {
                r.ErrorCode = '0002'; 
                r.Status = 'Error';
                r.Message = 'Contact Web Profile for the contact with the contact Id ' + req.Id + ' is not found';
                return r;
            }
            
            c[0].contactwebprofiles__r[0].verified__c = req.Verified;
            update c[0].contactwebprofiles__r[0];
            
            // Create case
            String description = 'First Name:'+c[0].FirstName+'\r\nLast Name:'+c[0].LastName+'\r\nEmail:'+c[0].contactwebprofiles__r[0].email__c+
                            '\r\nPhone:'+c[0].contactwebprofiles__r[0].Phone__c+'\r\nState:'+c[0].contactwebprofiles__r[0].state__c+'\r\nCrd Id:'+c[0].contactwebprofiles__r[0].CrdId__c+'\r\nContact Id:'+c[0].Id;          
            String caseId = createCase(req.id, description);             
           
            r.Status = 'Success';
            r.ErrorCode = null; 
            r.Message = 'Success : Updated contact with the verified flag';
            r.ContactId = req.Id;
            r.NotApproved = c[0].contactwebprofiles__r[0].NotApproved__c;  
            r.Verified = req.Verified;                    
        }
        catch(Exception ex) { 
            r.ErrorCode = '0001';
            r.Status = 'Error'; 
            r.Message = ex.getMessage();
        }   
        return r;  */           
    } 
    
    @HttpGet
    global static WebsiteContactCreateService.Response getSalesTeam() {
        
        WebsiteContactCreateService.Response r = new WebsiteContactCreateService.Response();
        List<WebsiteContactCreateService.ContactSalesTeam> csts = new List<WebsiteContactCreateService.ContactSalesTeam>();
        
        try {      
            //Read the Request from the URL 
            String contactid = RestContext.request.params.get('id');
                
            if (String.IsBlank(contactid)) {
                r.ErrorCode = '0003'; 
                r.Status = 'Error'; 
                r.Message = 'Fail : Contact Id is not specified'; 
                return r;
            }
            
            Contact c = [select Id, MarsRepId__c, PrimaryTerritory__c, PrimaryMarketingUser__r.UserId__c, PrimaryMarketingUser__r.FirstName, 
                            PrimaryMarketingUser__r.LastName, PrimaryMarketingUser__r.Title, PrimaryMarketingUser__r.Phone, PrimaryMarketingUser__r.Email,
                            OverlapTerritory__c, OverlapExternalUser__r.UserId__c, OverlapExternalUser__r.FirstName, OverlapExternalUser__r.LastName, OverlapExternalUser__r.Title, 
                            OverlapExternalUser__r.Phone, OverlapExternalUser__r.Email from Contact where Id =:contactid limit 1];
            
            // Add PrimaryMarketingUser
            if (c.PrimaryMarketingUser__r != null) {                
                WebsiteContactCreateService.ContactSalesTeam cst = new WebsiteContactCreateService.ContactSalesTeam();                
                cst.Territory = c.PrimaryTerritory__c;
                cst.UserId = c.PrimaryMarketingUser__r.UserID__c;
                cst.FirstName = c.PrimaryMarketingUser__r.FirstName;
                cst.LastName = c.PrimaryMarketingUser__r.LastName;
                cst.Email = c.PrimaryMarketingUser__r.Email;
                cst.Title = c.PrimaryMarketingUser__r.Title;
                cst.Phone = c.PrimaryMarketingUser__r.Phone;
                csts.add(cst);
            }
            
            // Add OverlapExternalUser for retirement
            if (c.OverlapExternalUser__r != null) {   
                WebsiteContactCreateService.ContactSalesTeam cst1 = new WebsiteContactCreateService.ContactSalesTeam();               
                cst1.Territory = c.OverlapTerritory__c;
                cst1.UserId = c.OverlapExternalUser__r.UserID__c;
                cst1.FirstName = c.OverlapExternalUser__r.FirstName;
                cst1.LastName = c.OverlapExternalUser__r.LastName;
                cst1.Email = c.OverlapExternalUser__r.Email;
                cst1.Title = c.OverlapExternalUser__r.Title;
                cst1.Phone = c.OverlapExternalUser__r.Phone;
                csts.add(cst1);
            }
            
            if (csts.size() == 0) {
                r.ErrorCode = null;
                r.Status = 'Success';
                r.Message = 'There is no sales team';
                
                return r;
            }
                        
            system.debug('hey:'+csts);
            r.Status = 'Success';
            r.ErrorCode = null; 
            r.Message = 'Success : Found the sales team';     
            r.ContactSalesTeams = csts;
        }                       
        catch (Exception ex)
        {
            r.ErrorCode = '0001';
            r.Status = 'Error'; 
            r.Message = ex.getMessage();
        }
            
        return r;
    }
    
    private static WebsiteContactCreateService.Response updateContactCookieValue(Contact c, String value) {
    
        WebsiteContactCreateService.Response r = new WebsiteContactCreateService.Response();  
        
        c.contactwebprofiles__r[0].ContactIdCookieValue__c = value;
        update c.contactwebprofiles__r[0];
        
        r.Status = 'Success';
        r.ErrorCode = null; 
        r.Message = 'Success : Updated contact with the contact cookie value';
        r.ContactId = c.Id;
        r.NotApproved = c.contactwebprofiles__r[0].NotApproved__c;  
        r.ContactIdCookieValue = c.contactwebprofiles__r[0].ContactIdCookieValue__c;             
        
        return r;
    }
    
    private static WebsiteContactCreateService.Response updateContactVerifiedValue(Contact c, boolean value) {
            
        WebsiteContactCreateService.Response r = new WebsiteContactCreateService.Response();  
        
        if (value == false) {
            r.ErrorCode = '0003'; 
            r.Status = 'Error';
            r.Message = 'Verified is not true';
            return r;
        }   
         
        c.contactwebprofiles__r[0].verified__c = value;
        update c.contactwebprofiles__r[0];
        
        // Create case
        String description = 'First Name:'+c.FirstName+'\r\nLast Name:'+c.LastName+'\r\nEmail:'+c.contactwebprofiles__r[0].email__c+
                        '\r\nPhone:'+c.contactwebprofiles__r[0].Phone__c+'\r\nState:'+c.contactwebprofiles__r[0].state__c+'\r\nCrd Id:'+c.contactwebprofiles__r[0].CrdId__c+'\r\nContact Id:'+c.Id;          
        String caseId = createCase(c.Id, description);             
       
        r.Status = 'Success';
        r.ErrorCode = null; 
        r.Message = 'Success : Updated contact with the verified flag';
        r.ContactId = c.Id;
        r.NotApproved = c.contactwebprofiles__r[0].NotApproved__c;  
        r.ContactIdCookieValue = c.contactwebprofiles__r[0].ContactIdCookieValue__c;  
        r.Verified = value;   
        
        return r;
    }
        
    private static String createCase(String contactId, String description) {
        Case c = new Case(
            RecordType = new RecordType (Name='Data Operations'),
            Type = 'Maintenance Rep',
            Description = 'This is a new rep created by website verification process. Please verify.\r\n' + description,
            ContactId  = contactId,
            Origin = 'Web'            
        );
        
        insert c;
        return c.Id;
    }
   
}