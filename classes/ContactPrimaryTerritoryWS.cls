@RestResource(urlMapping='/ContactPrimaryTerritory/*')
global with sharing class ContactPrimaryTerritoryWS {

    @HttpPost
    global static List<id> ComputeSharing(DateTime LastTime) {
        List<id> JobList = new List<id> ();
        
        string myQuery = 'select Id, MarsRepId__c, PrimaryTerritory__c, PrimaryTerritoryLookup__r.TerritoryName__c, PrimaryRegion__c, PrimaryMarketingUser__r.UserId__c, FullServiceSalesUser__r.UserId__c, OverlapTerritory__c,OverlapExternalUser__r.UserId__c from contact';
                     
        ContactPrimaryTerritoryBatch cpt = new ContactPrimaryTerritoryBatch(myQuery);
        ID cptId = database.executeBatch(cpt,10000); 
        JobList.add(cptId);
        return JobList ;        
    }    
}