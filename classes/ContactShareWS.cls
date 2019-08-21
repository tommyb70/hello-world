@RestResource(urlMapping='/ContactTerritoryShare/*')
global with sharing class ContactShareWS {

    @HttpPost
    global static List<id> ComputeSharing(DateTime LastTime) {
        List<id> JobList = new List<id> ();
        
        String MyQuery = 'Select Contact__c, Territory__r.RoleGroupId__c, Territory__r.GroupId__c from ContactTerritory__c WHERE CreatedDate >'+LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';      
		ContactShareBatch CSI = new ContactShareBatch();
        CSI.query = MyQuery;
		ID CSIid = database.executeBatch(CSI,2000); 
        JobList.add(CSIid);
        return JobList ;
        
    }
    
}