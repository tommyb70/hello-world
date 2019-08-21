public class  AddAccountToMarsWSC_Mock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
     System.debug('endpoint ' + req.getEndpoint());
     System.debug('Mathod ' + req.getMethod());
     System.debug('body ' + req.getBody());

        // Create a fake response
     HttpResponse res = new HttpResponse();       
     res.setHeader('Content-Type', 'text/xml');
     string body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><AddMarsAccountSfResponse xmlns="http://ga.natixis.com/RepSvc"><AddMarsAccountSfResult>9999999</AddMarsAccountSfResult></AddMarsAccountSfResponse></s:Body></s:Envelope>';
       
     res.setBody(body);
     res.setStatusCode(200);
     return res;
    }
}