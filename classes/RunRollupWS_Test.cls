@isTest
public class RunRollupWS_Test {

   private static testMethod void methodone(){ 

        RestRequest reqA = new RestRequest(); 
        RestResponse resA = new RestResponse(); 
        reqA.requestURI = '/services/apexrest/RunRollup/ZApexTestCoverageDoNotDelete'; 
        reqA.httpMethod = 'POST'; 
        RestContext.request = reqA; 
        RestContext.response = resA;      
        List<id> jobsids = RunRollupWS.RunRollup(system.now());
        system.assert(!jobsids.isEmpty());
   } 
}