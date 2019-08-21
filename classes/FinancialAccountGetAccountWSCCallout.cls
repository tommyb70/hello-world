public class FinancialAccountGetAccountWSCCallout {
    public class WSCSoapNewException extends Exception{}
   
    
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');    
    static string UseMPAUrl =   myCustomSetting.UseMPANamedCredential__c;
    
    public static String getDataSync(string search) {
        HttpRequest req; 
        // Create callout request
        req = new HttpRequest();
        req.setMethod('GET');
      //  req.setEndpoint('https://mobitest.ngam.natixis.com/mpaws/getAccountDetailsByName?accountName=' + search);
        req.setEndpoint('callout:'+UseMPAUrl+'/getAccountDetailsByName?accountName='+search);
        
      //  req.setClientCertificate('mobitest', 'awsrocks');
      /*          if ((username != null ) && (username.length() > 0)) 
        {
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            System.debug('authorizationHeader' + authorizationHeader);
            req.setHeader('Authorization', authorizationHeader);
        }*/
        HTTP h = new Http();
        HttpResponse resp = h.send(req);
        if (resp.getStatusCode() == 200) {
            String msg = resp.getBody();
            System.debug(msg);               
            return msg;
        }
        String msg = 'HTTP Response #' + resp.getStatusCode() + ':' ; msg += resp.getBody();
        System.debug('Error : ' + msg); throw new WSCSoapNewException(msg);
    }
    
    
    public static String getData(Continuation con,string search, Integer seconds, String URL) {
        // URL ='http://172.27.40.45:8080/getAccountDetailsByName?accountName='+search;
        HttpRequest req; 
        // Create callout request
        req = new HttpRequest();
        req.setMethod('GET');     
        req.setEndpoint('callout:'+UseMPAUrl+'/getAccountDetailsByName?accountName='+search);      
        if (con == null)
        {
            HTTP h = new Http();
            HttpResponse resp = h.send(req);
            if (resp.getStatusCode() == 200) { String msg = resp.getBody();
                System.debug(msg);
                return msg;
            }
            String msg = 'HTTP Response #' + resp.getStatusCode() +  ': ' + resp.getBody();
            System.debug('Error : ' + msg); throw new WSCSoapNewException(msg);
        } 
        else
        {
            try
            {
                String requestLabel = con.addHttpRequest(req);    return requestLabel;
            }
            catch(System.Exception ex)
            {  System.debug('msg: ' + ex.getMessage());   throw new WSCSoapNewException(ex.getMessage());     }
        }
    }
    
    
}