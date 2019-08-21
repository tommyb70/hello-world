@isTest
global class MockHttpResponseGeneratorDocuSignAPI implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        // Create a fake response
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String bod= '{"envelopeId": "749f211b-0262-48da-8f23-d2a196571508","uri": "/envelopes/749f211b-0262-48da-8f23-d2a196571508","statusDateTime": "2018-02-21T21:15:12.8411596Z", "status": "sent"}';
        res.setBody(bod);
        res.setStatusCode(200);
        return res; 
        
    }
}