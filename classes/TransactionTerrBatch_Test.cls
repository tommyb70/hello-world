@isTest  
private class TransactionTerrBatch_Test {
    static testMethod void TransactionTerrBatchTesting() {
        
       // Profile p = [select id from profile where name='System Administrator']; 
        DataFactory.CreateNGAMCustomSettings(); 
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string p = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c);
        
        User u2 = new User(alias = 'standt', email='SFDCadmin@ngam.natixis.com', 
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = p, 
                           timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        
        System.runAs(u2) {
            List<id> TransactionTerrJobList = new List<id>();
            
            DateTime SplitDate = system.now().addDays(-16);
            String formatedDt = SplitDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            
            TransactionTerr__c tc = new TransactionTerr__c(TradeID__c ='test'); 
            insert tc;
            
            TransactionTerrBatch ttj1 = new TransactionTerrBatch();
            Map<id,Channel__c> channelMaps = TransactionTerrBatch.ChannelMap; 
            ttj1.query = ContactChannelHelper.ContactChannelFieldQuery();
            /*ttj1.query += ' territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c where TransactionType__c=\'Purchases\'';
            ttj1.query += ' and ScrubDate__c >='+ SplitDate.format('yyyy-MM-dd')+'T'+ SplitDate.format('HH:mm')+':00.000Z LIMIT 2000';*/
            ttj1.query += ' territory__r.Channel__c, territory__r.RoleGroupId__c from TransactionTerr__c LIMIT 2000'; 
            
            system.debug(ttj1.query);
            ID ttjid1 = database.executeBatch(ttj1,2000); 
            TransactionTerrJobList.add(ttjid1);
            
        }
    }
}