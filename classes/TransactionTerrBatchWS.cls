@RestResource(urlMapping='/TransactionTerr/*')
global with sharing class TransactionTerrBatchWS {

    @HttpPost
    global static List<id> TransactionTerrBatchIds(DateTime LastTime) {
        List<id> TransactionTerrJobList = new List<id>();
        
		//DateTime SplitDate = system.now().addDays(-16);
        //String formatedDt = LastModidified.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
		//system.debug('------------------- Mid Date ' + formatedDt);
        
		TransactionTerrBatch ttj1 = new TransactionTerrBatch();
		//ttj1.query = 'select id, contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.PROZoneWHSE__c, contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where territory__r.Channel__r.ZoneField__c!=\'\' and TransactionType__c=\'Purchases\'';
        //ttj1.query = ttj1.query + ' and ScrubDate__c >='+ SplitDate.format('yyyy-MM-dd')+'T'+ SplitDate.format('HH:mm')+':00.000Z';
        /*ttj1.query = 'select id, contact__r.PROZoneGR__c,contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.TierADU_IDU__c,contact__r.PROZoneWHSE__c, contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, Contact__r.ZoneADU_IDU__c, territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where TransactionType__c=\'Purchases\'';
        ttj1.query = ttj1.query + ' and LastModifiedDate >='+ LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';*/
        
        ttj1.query = ContactChannelHelper.ContactChannelFieldQuery();
        ttj1.query += ' territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where TransactionType__c=\'Purchases\'';
        ttj1.query += ' and LastModifiedDate >='+ LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';
        system.debug(ttj1.query);
        ID ttjid1 = database.executeBatch(ttj1,2000); 
        TransactionTerrJobList.add(ttjid1);
 
        TransactionTerrBatch ttj2 = new TransactionTerrBatch();
        /*ttj2.query = 'select id, contact__r.PROZoneGR__c, contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.TierADU_IDU__c,contact__r.PROZoneWHSE__c, contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, Contact__r.ZoneADU_IDU__c, territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where TransactionType__c=\'Redemptions\'';
        //ttj2.query = ttj2.query + ' and ScrubDate__c >='+ SplitDate.format('yyyy-MM-dd')+'T'+ SplitDate.format('HH:mm')+':00.000Z';
        ttj2.query = ttj2.query + ' and LastModifiedDate >='+ LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';*/
        ttj2.query = ContactChannelHelper.ContactChannelFieldQuery();
        ttj2.query += ' territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where TransactionType__c=\'Redemptions\'';
        ttj2.query += ' and LastModifiedDate >='+ LastTime.format('yyyy-MM-dd')+'T'+ LastTime.format('HH:mm')+':00.000Z';
        system.debug(ttj2.query);
        ID ttjid2 = database.executeBatch(ttj2,2000); 
        TransactionTerrJobList.add(ttjid2);
        
        /*
        TransactionTerrBatch ttj3 = new TransactionTerrBatch();
        ttj3.query = 'select id, contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.PROZoneWHSE__c, contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where territory__r.Channel__r.ZoneField__c!=\'\' and TransactionType__c=\'Purchases\'';
        ttj3.query = ttj3.query + ' and ScrubDate__c <'+ SplitDate.format('yyyy-MM-dd')+'T'+ SplitDate.format('HH:mm')+':00.000Z';
        system.debug(ttj3.query);
        ID ttjid3 = database.executeBatch(ttj3,2000); 
        TransactionTerrJobList.add(ttjid3);
        
        TransactionTerrBatch ttj4 = new TransactionTerrBatch();
        ttj4.query = 'select id, contact__r.PROTierWHSE__c,contact__r.PROTierFS__c,contact__r.PROTierIAG__c,contact__r.PROTierRS__c, contact__r.PROZoneWHSE__c, contact__r.PROZoneFS__c, contact__r.PROZoneIAG__c, contact__r.PROZoneRS__c, territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where territory__r.Channel__r.ZoneField__c!=\'\' and TransactionType__c=\'Redemptions\'';
        ttj4.query = ttj4.query + ' and ScrubDate__c <'+ SplitDate.format('yyyy-MM-dd')+'T'+ SplitDate.format('HH:mm')+':00.000Z';
        system.debug(ttj4.query);
        ID ttjid4 = database.executeBatch(ttj4,2000); 
        TransactionTerrJobList.add(ttjid4);*/

        
        return TransactionTerrJobList ;
    }
    
}