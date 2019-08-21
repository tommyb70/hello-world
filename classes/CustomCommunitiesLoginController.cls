global with sharing class CustomCommunitiesLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global String startUrl {get; set;}
    global CustomCommunitiesLoginController () {
        this.verified = true;
    }
    
    global PageReference login() {
        return Site.login(username, password, startUrl); 
    } 
    
    global PageReference forgotPassword() {
    PageReference forgotPage = new PageReference('/CustomCommunituesForgotPassword');
    forgotPage.setRedirect(false);
    return forgotPage;
    } 
    
    global PageReference contactUs() {
      //  PageReference forgotPage = new PageReference('/apex/communitiesEstatement#/contact');
        PageReference forgotPage = new PageReference('/CustomContactUs#/contact');
    forgotPage.setRedirect(false);
    return forgotPage;
    } 
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        
    return new PageReference(Site.getPathPrefix() + '/CustomCommunitiesLoginPage?startURL=' +
    EncodingUtil.urlEncode(startURL, 'UTF-8'));
     //   return Network.forwardToAuthPage(startUrl, displayType);
    }
    
    
    
    public  String loginAura(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
           // aura.redirect(lgn);
           lgn.setRedirect(true);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
   
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

   
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

   
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
    
    /* Configuration */

    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'https://www.google.com/recaptcha/api/verify'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = '6LeN7QkUAAAAALJ1MFmVqEDGieMxpJxQfjqRapWW';
    public String publicKey { 
        get { return '6LeN7QkUAAAAACowSgOji_XFMH_GcNb2WwdQE1S_'; }
    } 

    /* Implementation */
    
    // Simple form fields for the example form
    //public String myName { get; set; }
    //public String myEmail { get; set; }
    
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    
    public PageReference verify() {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return null; 
        }
                    
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) {
            // If they pass verification, you might do something interesting here
            // Or simply return a PageReference to the "next" page
            return null;
        }
        else {
            // stay on page to re-try reCAPTCHA
            return null; 
        }
    }

    public PageReference reset() {
        return null; 
    }   

    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    
    
}