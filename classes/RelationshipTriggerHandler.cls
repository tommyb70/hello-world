public class RelationshipTriggerHandler {
    
    public static void RelationshipAfterInsert () {
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();
         for(npe4__Relationship__c  relationship  : [select Id, npe4__Contact__r.TranPYPurchases__c, npe4__Contact__r.TranYTDPurchases__c from npe4__Relationship__c where id in: trigger.new]) { 
             system.debug('Relationship:'+ relationship);
             npe4__Relationship__c r = new npe4__Relationship__c();
             r.Id = relationship.Id;
             r.ContactPYPurchases__c = relationship.npe4__Contact__r.TranPYPurchases__c;
             r.ContactYTDPurchases__c = relationship.npe4__Contact__r.TranYTDPurchases__c;
             system.debug('r:'+r);
             relationships.add(r);
         }
         update relationships;          
    }
}