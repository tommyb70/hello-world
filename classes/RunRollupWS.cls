@RestResource(urlMapping='/RunRollup/*')
global with sharing class RunRollupWS {

    @HttpPost()
    global static List<id> RunRollup( DateTime LastTime) {
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String RollupUniqueName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        List<id> JobList = new List<id> ();
        string runJobId = null;
        List<dlrs__LookupRollupSummary2__mdt> rollupMetadata =[select id from dlrs__LookupRollupSummary2__mdt where DeveloperName=:RollupUniqueName LIMIT 1];
        if(!rollupMetadata.isEmpty()){
            runJobId = rollupMetadata[0].id;
        }         
		Id rId = dlrs.RollupService.runJobToCalculate(runJobId);
        JobList.add(rId);
        return JobList ;     
        
    }        
}