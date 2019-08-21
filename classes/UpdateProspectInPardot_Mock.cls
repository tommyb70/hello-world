@isTest
public class UpdateProspectInPardot_Mock implements HttpCalloutMock {
        
    // Handle responses for two callouts
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
 
        //  Set the response body, based on endpoint. 
        if (req.getEndpoint() == 'https://pi.pardot.com/api/login/version/3') {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><rsp stat="ok" version="1.0"><api_key>1111</api_key></rsp>');
        }        
        else if (req.getEndpoint() == 'https://pi.pardot.com/api/Prospect/version/3/do/update/email/test@ngam.natixis.com') {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><rsp stat="ok" version="1.0"><prospect><id>1234</id><email>test@ngam.natixis.com</email><opted_out>1</opted_out></prospect></rsp>');             
        }            
        else if (req.getEndpoint() == 'https://pi.pardot.com/api/Prospect/version/3/do/update/email') {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><rsp stat="fail" version="1.0"> <err code="2">Invalid action</err></rsp>');
        }
         
        return res;          
    }
}