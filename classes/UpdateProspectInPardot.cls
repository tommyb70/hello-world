global class UpdateProspectInPardot {
    
    @future (callout=true)
    public static void UpdateProspectOptoutInPardotByEmail(string email, boolean optOut) { 
    
        try {
            List<ApexActivitiesStatsLog__c> logs = new List<ApexActivitiesStatsLog__c>();
            
            // Extract and sort pardot custom settings
            Map<string, PardotSettings__c> settingsMap = PardotSettings__c.getAll();
            //List<String> settingsKeys = new List<String>(settingsMap.keySet()); 
            
            string loginUrl = settingsMap.get('LoginUrl').Value__c;
            string userEmail = settingsMap.get('Email').Value__c;
            string password = settingsMap.get('Password').Value__c;
            string userKey = settingsMap.get('UserKey').Value__c;
            string apiKey;
              
            system.debug('Hello:' + loginUrl + ':' + userEmail + ':' + password + ':' + userKey);
           
            // Format the request body for login to pardot
            string loginBody = string.format(settingsMap.get('LoginBody').Value__c, new string[] {userEmail, password, userKey});
            system.debug('Login Body:'+ loginBody);
            
            // Send the login request to pardot
            HttpResponse loginResponse = postHttp(loginUrl, loginBody);
                        
            PardotStatus loginStat = ParseHttpResponse(loginResponse, email, loginUrl, loginBody, logs);
                        
            if (loginStat.Success == false) {
                insert logs;
                return;
            }
            
            apiKey = loginStat.ApiKey;
                       
            // Send the update request to pardot with ApiKey obtained from the above request.
            string updateUrl = string.format(settingsMap.get('UpdateUrl').Value__c, new string[] { 'Prospect', 'email', email});
            string updateBody = 'api_key=' + apiKey  + '&user_key=' + userKey + '&opted_out=' + optOut;
             
            HttpResponse updateResponse = postHttp(updateUrl,updateBody);
                                                         
            PardotStatus stat = ParseHttpResponse(updateResponse, email, updateUrl, updateBody, logs); 
            insert logs;                                
        }
        catch (System.Exception ex){
            if (!Test.IsRunningTest()) SendEmail('Exception Error: ' + ex, 'Error in updating the prospect in pardot - ' + Email  );
        }
    }
    
    public static PardotStatus ParseHttpResponse(HttpResponse response, string email, string url, string body, List<ApexActivitiesStatsLog__c> logs) {
    
        // Log the http response
        system.debug('Response:' + response.getBody());            
   
        // Load the http response into dom document
        dom.Document responseDoc = response.getBodyDocument();
        dom.XmlNode rootNode = responseDoc.getRootElement();
        string status = rootNode.getAttributeValue('stat', rootNode.getNamespace());
        //system.debug('status:'+ status);
        
        // if status = 'fail'
        if (status == 'fail') {
            for(dom.XmlNode node : responseDoc.getRootElement().getChildElements()) {                         
                if (node.getName() == 'err') {
                    string msg = 'Error: ' + node.getText() + '\n Url: ' + url + '\n Body: ' + body + '\n';
                    if(!Test.isRunningTest()) SendEmail(msg, 'Error updating the prospect in pardot - ' + email  );
                    string code = node.getAttributeValue('code', node.getNamespace());
                    
                    // Send PardotStatus
                    PardotStatus ps = new PardotStatus ();
                    ps.Code = code;
                    ps.Message = node.getText();
                    ps.Success = false;
                    
                    // Log in ApexActivitiesStatsLog__c table
                    LogResponse(ps.Message, ps.Success, body, url, logs); 
                    
                    return ps;
                }
            }
        }   
        
        // if status = 'ok' get api_key for login
        if (status == 'ok') {
            for(dom.XmlNode node : responseDoc.getRootElement().getChildElements()) {                         
                if (node.getName() == 'api_key') { 
                                                                            
                    // Send PardotStatus              
                    PardotStatus ps = new PardotStatus (); 
                    ps.ApiKey = node.getText();
                    ps.Success = true;
                    ps.Message = 'Login is successful';
                    
                    // Log in ApexActivitiesStatsLog__c table
                    LogResponse(ps.Message, ps.Success, body, url, logs); 
                                        
                    return ps;
                }
            }
        }       
        
        PardotStatus ps = new PardotStatus ();
        ps.Success = true;
        ps.Message = 'Update is Successful';
        
        // Log in ApexActivitiesStatsLog__c table
        LogResponse(ps.Message, ps.Success, body, url,logs); 
                    
        return ps;
    }
    
    public class PardotStatus {
        public string Code { get; set; }
        public string Message { get; set; }
        public string ApiKey { get; set; }
        public boolean Success { get; set; }
    }
    
    // Send the request to pardot
    public static HttpResponse postHttp(string url, string body) {   
        system.debug('Url:' + url + 'Body:' + body);     
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        return response;
    }
    
    // Log in ApexActivitiesStatsLog__c table
    public static void LogResponse(string message, boolean success, string body, string url, List<ApexActivitiesStatsLog__c> logs) {
    
        string status;
        
        if (success == true) {
            status = 'ok';
        }
        else {
            status = 'fail';
        }
        
        ApexActivitiesStatsLog__c l = new ApexActivitiesStatsLog__c (ClassName__c = 'UpdateProspectInPardot', Message__c = message, MethodName__c = url, ObjectName__c = 'Contact', QueryBatchJob__c = body, Status__c = status);
        logs.Add(l);
    }                     
    
    public static void SendEmail(string message, string subject) { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'sireesha.meka@ngam.natixis.com'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('sireesha.meka@ngam.natixis.com');
        mail.setSenderDisplayName('NGAM SFDC - Call Pardot service');
        mail.setSubject(subject);
        mail.setHTMLBody(message);
        if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}