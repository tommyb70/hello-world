@isTest 
public class  FAGetAccountWSCCallout_Mock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        System.debug('endpoint ' + req.getEndpoint());
        System.debug('Mathod ' + req.getMethod());
        System.debug('body ' + req.getBody());
        // Create a fake response
        HttpResponse res = new HttpResponse();       
        res.setHeader('Content-Type', 'application/json');
        String json = '[{"accountId":26,"accountNumber":"32000380","accountName":"BSM32000380","accountTitle":"ELIZABETH GROSSMAN TRUST","accountType":"TRUST","sponsor":"JP Morgan","program":"Stratis","manager":"AEW","modelName":"AEWREI","modelDescription":"AEW REIT","inceptionValue":140028,"inceptionDate":1136246400000,"terminationDate":4386355200000,"terminationValue":0,"firstTradeDate":1136419200000,"firstTradeValue":140028,"lifeCycleStep":"Active","faName":"PHYLLIS TABACHNICK","faEmail":null}]';
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
}