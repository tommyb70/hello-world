public class FinancialAccountContactTriggerHandler {
    
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    static string ContactObjectEmailField = myCustomSetting.ContactObjectEmailField__c;
    static string UserNameFormat = myCustomSetting.UserNameFormat__c;
    public static String UseTestEmail = myCustomSetting.UseTestEmail__c;
    static String TestUserEmail  = myCustomSetting.TestUserEmail__c;
    static string PermissionSetForEndClient =   myCustomSetting.PemissionSetForEndClient__c;
    static string ProfileForFAUser =  myCustomSetting.ProfileForFAUser__c;
    static String PermissionSetsForFAUser = myCustomSetting.PermissionSetsForFAUser__c;
    static String ProfileForEndClient = myCustomSetting.ProfileForEndClient__c;
    
    public static void TriggerAfterInsert(List<FinancialAccountContact__c> myFAC){
        
        // Share Financial Account only if the user record for the inserted contact already exists
        // If user doesn't exist, the active, portal enabled user will be created and the FA will be shared durin the batch job
        
        Set<Id> contactSet = new Set<Id>();
        for (FinancialAccountContact__c fac : myFAC) {
            contactSet.add(fac.Contact__c);
        }
        
        List<FinancialAccount__Share> sharesToCreate = new List<FinancialAccount__Share>();
        List<User> contactUserList = new List<User>([SELECT ContactId, Id FROM User
                                                     WHERE IsPortalEnabled = TRUE
                                                     AND ContactId in :contactSet
                                                     AND IsActive = TRUE]);
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        for (User cu : contactUserList) {
            contactUserMap.put(cu.ContactId,cu.Id);
        }


        List<User> contactUserTCList = new List<User>([SELECT ContactId, Id FROM User
                                                     WHERE IsPortalEnabled = TRUE
                                                     AND ContactId in :contactSet
                                                       AND TermsandConditionsLastDeclined__c != null
                                                     AND IsActive = FALSE]);
        for (User u : contactUserTCList) {
        	removeTCDeclined(u.Id);
            }

        
        for (FinancialAccountContact__c fac : myFAC) {
            if (contactUserMap.containsKey(fac.Contact__c) && fac.Status__c == 'Current' && fac.View_Financial_Account_in_Community__c == TRUE) {
                
                FinancialAccount__Share cs = new FinancialAccount__Share(AccessLevel='Read',ParentId=fac.Financial_Account__c,
                                                                         RowCause=Schema.FinancialAccount__Share.RowCause.Manual,
                                                                         UserOrGroupId=contactUserMap.get(fac.Contact__c));
                sharesToCreate.add(cs);  
            }
            
            if(!sharesToCreate.isEmpty()) {
                upsert  sharesToCreate;
            }
        }
    }

	@future
    public static void removeTCDeclined(String userId) {
        User u = [SELECT Id, TermsandConditionsLastDeclined__c FROM User WHERE Id =: userId LIMIT 1];
        u.TermsandConditionsLastDeclined__c = null;
        update u;
    }
    
    public static void TriggerAfterDelete(List<FinancialAccountContact__c> myFAC){
        
        // Unshare Financial Account
        String RowCauseManual = Schema.FinancialAccount__Share.RowCause.Manual;
        
        Set<Id> financialAccountSet = new Set<Id>();
        Set<Id> contactSet = new Set<Id>();
        for (FinancialAccountContact__c fac : myFAC) {
            financialAccountSet.add(fac.Financial_Account__c);
            contactSet.add(fac.Contact__c);
        }
        
        List<User> contactUserList = new List<User>([SELECT ContactId, Id FROM User
                                                     WHERE ContactId in :contactSet]);
        
        Set<Id> contactUserSet = new Set<Id>();
        for (User cu : contactUserList) {
            contactUserSet.add(cu.Id);
        }
        
        List<FinancialAccount__share> sharesToDelete = new List<FinancialAccount__share>([SELECT Id, ParentId, UserOrGroupId
                                                                                          FROM FinancialAccount__Share
                                                                                          WHERE ParentId in : financialAccountSet
                                                                                          AND UserOrGroupId in : contactUserSet
                                                                                          AND RowCause = :RowCauseManual
                                                                                          AND AccessLevel = 'Read']);
        if(!sharesToDelete.isEmpty()) {
            delete sharesToDelete;
        }
    }
    
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // TriggerAfterUpdate
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void TriggerAfterUpdate(List<FinancialAccountContact__c> myFAC, Map<Id,FinancialAccountContact__c> myFACOldMap)
    {  
        String RowCauseManual = Schema.FinancialAccount__Share.RowCause.Manual;
        Set<Id> financialAccountSet = new Set<Id>();
        Set<Id> contactSetDel = new Set<Id>();
        Set<Id> contactSetAdd = new Set<Id>();
        
        for (FinancialAccountContact__c fac : myFAC) {
            financialAccountSet.add(fac.Financial_Account__c);
            if (fac.Status__c == 'Former' || fac.View_Financial_Account_in_Community__c == FALSE) {
                contactSetDel.add(fac.Contact__c);
            }
            if (fac.Status__c == 'Current' || fac.View_Financial_Account_in_Community__c == TRUE) {
                contactSetAdd.add(fac.Contact__c);
            }
       }
        
        List<User> contactUserListDel = new List<User>([SELECT ContactId, Id FROM User
                                                        WHERE ContactId in :contactSetDel]);
        
        Set<Id> contactUserSetDel = new Set<Id>();
        for (User cu : contactUserListDel) {
            contactUserSetDel.add(cu.Id);
        }
        
        List<FinancialAccount__share> sharesToDelete = new List<FinancialAccount__share>([SELECT Id, ParentId, UserOrGroupId
                                                                                          FROM FinancialAccount__Share
                                                                                          WHERE ParentId in : financialAccountSet
                                                                                          AND UserOrGroupId in : contactUserSetDel
                                                                                          AND RowCause = :RowCauseManual
                                                                                          AND AccessLevel = 'Read']);
        if(!sharesToDelete.isEmpty()) {
            delete sharesToDelete;
        }

        List<FinancialAccount__Share> sharesToCreate = new List<FinancialAccount__Share>();
        List<User> contactUserList = new List<User>([SELECT ContactId, Id FROM User
                                                     WHERE IsPortalEnabled = TRUE
                                                     AND ContactId in :contactSetAdd
                                                     AND IsActive = TRUE]);
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        for (User cu : contactUserList) {
            contactUserMap.put(cu.ContactId,cu.Id);
        }

        /*List<User> contactUserTCList = new List<User>([SELECT ContactId, Id FROM User
                                                     WHERE IsPortalEnabled = TRUE
                                                     AND ContactId in :contactSetAdd
                                                       AND TermsandConditionsLastDeclined__c != null
                                                     AND IsActive = FALSE]);
        for (User u : contactUserTCList) {
        	removeTCDeclined(u.Id);
            }*/

        for (FinancialAccountContact__c fac : myFAC) {
            if (contactUserMap.containsKey(fac.Contact__c) && fac.Status__c == 'Current' && fac.View_Financial_Account_in_Community__c == TRUE) {
                
                FinancialAccount__Share cs = new FinancialAccount__Share(AccessLevel='Read',ParentId=fac.Financial_Account__c,
                                                                         RowCause=Schema.FinancialAccount__Share.RowCause.Manual,
                                                                         UserOrGroupId=contactUserMap.get(fac.Contact__c));
                sharesToCreate.add(cs);  
            }
            
            if(!sharesToCreate.isEmpty()) {
                upsert  sharesToCreate;
            }
        }
        
    }
}