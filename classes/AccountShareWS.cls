@RestResource(urlMapping='/AccountTerritoryShare/*')
global with sharing class AccountShareWS {

    @HttpPost
    global static List<id> ComputeSharing(DateTime LastTime) {  
        //String pLastTime = RestContext.request.params.get('pLastTime');
        //DateTime LastTime = Datetime.valueOf(pLastTime); 
        List<id> JobIds = new List<id>();

    	AccountShareBatch ASI = new AccountShareBatch();
        ASI.query = 'select Account__c, Territory__r.RoleGroupId__c, RoleId__c, GroupId__c from AccountTerritory__c WHERE CreatedDate >'+LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';
    	ID ASIid = database.executeBatch(ASI,2000);  
        JobIds.add(ASIid );
        return JobIds ;
    }
    
}