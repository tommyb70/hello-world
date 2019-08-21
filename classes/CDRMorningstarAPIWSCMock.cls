public class CDRMorningstarAPIWSCMock implements HttpCalloutMock {
    
    public static HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(200);
			return resp;
	    }
    
    
}