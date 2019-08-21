global class ContactShareBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String query;
    public set<id> GContactIds = new set<id>();  
    public integer CScount = 0;
    
    global Database.querylocator start(Database.BatchableContext BC){   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ContactTerritory__c> scope)
    { 
        List<ContactShare> sharesToCreate = new List<ContactShare>();
        set<id> ContactIds = new set<id>();       
        
        for (ContactTerritory__c TA: scope)
        {
            if (!GContactIds.contains(TA.Contact__c))  
            {
                ContactIds.add(TA.Contact__c);    
            } 
            //ContactIds.add(TA.Contact__c); 
            //system.debug('TA.Contact__c' + TA.Contact__c);    
            
            ContactShare cs = new ContactShare();
            cs.ContactAccessLevel = 'Edit';
            cs.ContactId = TA.Contact__c;
            //cs.UserOrGroupId = MyGroups.get(TA.RoleId__c);
            cs.UserOrGroupId = TA.Territory__r.RoleGroupId__c;
            sharesToCreate.add(cs);  
            
            //ContactShare cs2 = new ContactShare();
            //cs2.ContactAccessLevel = 'Edit';
            //cs2.ContactId = TA.Contact__c;
            //cs2.UserOrGroupId = TA.TerrGroupId__c;
            //cs2.UserOrGroupId = TA.Territory__r.GroupId__c;
            //sharesToCreate.add(cs2);
            
            GContactIds.add(TA.Contact__c);      
        }    
        
        List<ContactShare> sharesToDelete = new List<ContactShare>([select id from ContactShare where Rowcause='Manual' and contactid in: ContactIds]);  
        //system.debug('vrdelete:' + sharesToDelete.size());
        
        if (!sharesToDelete.isEmpty())
        {   
            delete sharesToDelete;
        } 
        
        if (!sharesToCreate.isEmpty())
        {   
            insert sharesToCreate;
        }  
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        /*try{
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
mail.setToAddresses(toAddresses);
mail.setReplyTo('dat@ngam.natixis.com');
mail.setSenderDisplayName('DAT');
mail.setSubject('ContactsShare computation Completed');
mail.setPlainTextBody('Batch Process has completed and ' + CSCount + ' Role Contactshare were created');
//mail.setPlainTextBody('All Good !');
if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
}
catch (Exception e) {
System.debug('Exception: ' + e);            
} */   
    }
    
}