public class PortalActivityTriggerHandler {
    public static boolean isExecuting = false;
    
    public static void PortalActivityAfterInsert (List<PortalActivity__c> portalActivities) {           
        
        if(PortalActivityTriggerHandler.isExecuting ){
            // if was executed during the same context 
            // avoid recursion
            return;
        }
 
        PortalActivityTriggerHandler.isExecuting = true; 
    
        Set<string> repIds = new Set<string>();
        Set<string> userIds = new Set<string>();
        //Set<string> codeIds = new Set<string>();
        
        for (PortalActivity__c pa : portalActivities) {    
            if (pa.RepId__c != '' && pa.RepId__c != null) {
                repIds.add(pa.RepId__c);
            }
            if (pa.UserId__c != '' && pa.UserId__c != null) {
                userIds.add(pa.UserId__c);
            }
            //codeIds.add(pa.Code__c);
        }                  
               
        List<contact> contacts = [select Id, MarsRepId__c from contact where MarsRepId__c in : repIds];
                
        List<User> users = [select Id, UserId__c from User where UserId__c in : userIds];
      
        //List<PortalActivity__c> pas = [Select Id, RepId__c, UserId__c from PortalActivity__c where Code__c in : codeIds];               
        
        List<PortalActivity__c> l = new List<PortalActivity__c>();
        for (PortalActivity__c pa : portalActivities) {
            PortalActivity__c a = new PortalActivity__c(Id = pa.Id);
            system.debug('ff:' +pa);
            for (Contact c : contacts) {
                if (c.MarsRepId__c == pa.RepId__c) {
                    a.Contact__r = new Contact (MarsRepId__c = pa.RepId__c);
                    l.add(a);
                    break;
                }
            }  
            for (User u : users) {
                if (u.UserId__c == pa.UserId__c) {
                    a.User__r = new User (UserId__c = pa.UserId__c);
                    l.add(a);
                    break;
                }
            }                   
        }
        update l;          
    }
}