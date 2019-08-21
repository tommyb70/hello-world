public class ContactTriggerHandler {
    
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    static Boolean updateUserOnVestMarkEmail = false; 
    static String eStatementFirmName = '';
    static String portalUserName = '';
    static String communityAccountPrefix = ''; 
    static String endClientOwnerId = '';
    static Account portalFirm;
    static Id ECrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
    static Id CRrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Rep/Contact').getRecordTypeId();    
    static Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
    
    public static void onBeforeInsert(List<Contact> newContacts) {
        
        createAccountForEndClients(newContacts);
        newContacts = setFirm(newContacts);
        newContacts = setEmailPreferencesFieldBeforeInsert(newContacts); 
        newContacts = setWCMRelationshipFlag(newContacts);
        
    }
    
    public static void onAfterInsert(List<Contact> newContacts) {
        addRepToMARS(newContacts);
    }    
    
    public static void onBeforeUpdate(List<Contact> newContacts, Map<Id,Contact> oldMap) {
        newContacts = setFirm(newContacts);
        newContacts = setEmailPreferencesFieldBeforeUpdate(newContacts, oldMap);
		newContacts = setWCMRelationshipFlag(newContacts);
    }       
    
    public static List<Contact> setWCMRelationshipFlag(List<Contact> contacts) {

		Set<Id> wcmOverrideSet = new Set<Id>();
        WCMRelationshipSyncOverride__mdt[] wcmOverrides = [SELECT SFID__c FROM WCMRelationshipSyncOverride__mdt];

		for (WCMRelationshipSyncOverride__mdt w : wcmOverrides) {
			wcmOverrideSet.add(w.SFID__c);
		}    

        Set<Id> acctIdSet = new Set<Id>();
        
        for (Contact c : contacts) {
            acctIdSet.add(c.AccountId);
        }        
        
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id, WCMRelationshipFlag__c
                                                       FROM Account
                                                       WHERE Id in: acctIdSet]);
        
        for (Contact c : contacts) {
            if (acctMap.containsKey(c.AccountId) && c.AccountId != null  && !wcmOverrideSet.contains(c.Id)) {
            	c.WCMRelationshipFlag__c = acctMap.get(c.AccountId).WCMRelationshipFlag__c;
            }
        }
        
        return contacts;
    }
    
    public static List<Contact> setEmailPreferencesFieldBeforeInsert(List<Contact> myContactList) {
        
        for (Contact c : myContactList) {            
            getEmailPreferences(c);             
        }
        
        return myContactList;  
        
    }    
    
    public static List<Contact> setEmailPreferencesFieldBeforeUpdate(List<Contact> myContactList, Map<Id,Contact> oldContactMap) {
        
        for (Contact c : myContactList) {
            
            //if any of the key fields have changed, run the logic
            if ((c.HasOptedOutOfEmail != oldContactMap.get(c.Id).HasOptedOutOfEmail) ||
                (c.SnoozeEmails__c != oldContactMap.get(c.Id).SnoozeEmails__c) ||
                (c.PardotPrefCenterOptOut1__c != oldContactMap.get(c.Id).PardotPrefCenterOptOut1__c) ||
                (c.PardotPrefCenterOptOut2__c != oldContactMap.get(c.Id).PardotPrefCenterOptOut2__c) ||
                (c.PardotPrefCenterOptOut3__c != oldContactMap.get(c.Id).PardotPrefCenterOptOut3__c) ||
                (c.PardotPrefCenterOptOut4__c != oldContactMap.get(c.Id).PardotPrefCenterOptOut4__c) ||
                (c.EmailPreferencesRecalc__c != oldContactMap.get(c.Id).EmailPreferencesRecalc__c) ||
                (c.Email != oldContactMap.get(c.Id).Email) ||
                (c.InitiateEmailOptIn__c != oldContactMap.get(c.Id).InitiateEmailOptIn__c) ||
                (c.pi__pardot_hard_bounced__c != oldContactMap.get(c.Id).pi__pardot_hard_bounced__c))   {
                    
                    getEmailPreferences(c); 
                    
                }
            
        }
        
        return myContactList;  
        
    }
    
    public static void getEmailPreferences(Contact c) {
        
        c.EmailPreferences__c = '';
        
        if (c.InitiateEmailOptIn__c) {
            c.HasOptedOutOfEmail = FALSE;
            c.EmailPreferences__c = 'Email Opt-In Initiated';
        }    
        
        List<String> reasonForNoEmailsList = new List<String>();
        
        if (c.SnoozeEmails__c) reasonForNoEmailsList.add('Snoozed');
        if (c.HasOptedOutOfEmail) reasonForNoEmailsList.add('Global Opt-out');
        if (c.Email == null) reasonForNoEmailsList.add('No address');
        if (c.pi__pardot_hard_bounced__c) reasonForNoEmailsList.add('Hard Bounce');
        
        if (!reasonForNoEmailsList.isEmpty()) {
            c.EmailPreferences__c = 'No Emails: ' + String.join(reasonForNoEmailsList,', ');
        }
        
        if (String.isBlank(c.EmailPreferences__c)) {                 
            
            //is this a client with mixed preferences?
            Set<Boolean> mixedPrefSet = new Set<Boolean>();
            mixedPrefSet.add(c.PardotPrefCenterOptOut1__c);
            mixedPrefSet.add(c.PardotPrefCenterOptOut2__c);
            mixedPrefSet.add(c.PardotPrefCenterOptOut3__c);
            mixedPrefSet.add(c.PardotPrefCenterOptOut4__c);
            
            Boolean mixedPref = FALSE;
            
            if (mixedPrefSet.contains(TRUE) && mixedPrefSet.contains(FALSE)) mixedPref = TRUE;
            
            if (!mixedPref) {
                if (!c.InitiateEmailOptIn__c) {
                    c.EmailPreferences__c = 'All Emails';
                }
            } else {
                List<String> optInList = new List<String>();
                List<String> optOutList = new List<String>();
                String ppc1Label = fieldMap.get('PardotPrefCenterOptOut1__c').getDescribe().getLabel().removeEnd('Opt-out').trim();
                String ppc2Label = fieldMap.get('PardotPrefCenterOptOut2__c').getDescribe().getLabel().removeEnd('Opt-out').trim();
                String ppc3Label = fieldMap.get('PardotPrefCenterOptOut3__c').getDescribe().getLabel().removeEnd('Opt-out').trim();
                String ppc4Label = fieldMap.get('PardotPrefCenterOptOut4__c').getDescribe().getLabel().removeEnd('Opt-out').trim();
                
                if (c.PardotPrefCenterOptOut1__c) {
                    optOutList.add(ppc1Label);
                } else {
                    optInList.add(ppc1Label);
                }
                
                if (c.PardotPrefCenterOptOut2__c) {
                    optOutList.add(ppc2Label);
                } else {
                    optInList.add(ppc2Label);
                }
                
                if (c.PardotPrefCenterOptOut3__c) {
                    optOutList.add(ppc3Label);
                } else {
                    optInList.add(ppc3Label);
                }
                
                if (c.PardotPrefCenterOptOut4__c) {
                    optOutList.add(ppc4Label);
                } else {
                    optInList.add(ppc4Label);
                }
                
                c.EmailPreferences__c = 'Opted-in: ' + String.join(optInList,', ');
                c.EmailPreferences__c = c.EmailPreferences__c +  '\n' + 'Opted-out: ' + String.join(optOutList,', ');
                
            }
            
        }
    }
    
    public static void getCommunitySettings() { 
        
        if(myCustomSetting != null) {
            updateUserOnVestMarkEmail = myCustomSetting.UpdateVestMarkEmailInUserRecord__c;
            eStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
            portalUserName = myCustomSetting.PotalUserName__c;
            communityAccountPrefix = myCustomSetting.AccountPrefix__c;
            endClientOwnerId = myCustomSetting.EndClientOwnerId__c;
            
            List<Account> portalFirmTemp = [SELECT Id, Name, Type, RecordTypeId 
                                            FROM Account 
                                            WHERE Name =:EStatementFirmName 
                                            AND Type='Firm'
                                            LIMIT 1];
            
            if(!portalFirmTemp.isEmpty() && portalFirmTemp != null) portalFirm = portalFirmTemp[0];
        }
    }
    
    public static List<Contact> createAccountForEndClients (list<Contact> newContacts) { 
        
        getCommunitySettings();
        map<Contact,Account> c2a = new map<Contact,Account>();
        
        for(Contact c:newContacts) {
            if(c.recordTypeId==ECrecordTypeId && c.AccountId==null) {
                Account a = new Account(Name=CommunityAccountPrefix+' '+c.FirstName+' '+c.LastName, OwnerId = EndClientOwnerId, ParentId=portalFirm.Id);
                c2a.put(c,a);
            }
        }
        
        insert c2a.values();
        
        for(Contact c:c2a.keySet()) {
            c.AccountId = c2a.get(c).Id;
        }
        
        return newContacts;
    }
    
    public static void updateVestmarkEmail (List<Contact> myContacts, Map<Id,Contact> myOldContactMap) { 
        
        getCommunitySettings();
        Map<Id,User> communityContactUserMap = new Map<Id,User>(); 
        
        for (User u : [SELECT Id, ContactId, Email
                       FROM User
                       WHERE ContactId IN :myContacts
                       AND isActive=TRUE]) {
                           communityContactUserMap.put(u.ContactId,u);
                       }
        
        List<User> usersToUpdate = new List<User>();
        
        if(UpdateUserOnVestMarkEmail && !communityContactUserMap.isEmpty()) {
            for (Contact c : myContacts) {
                if (c.VestMarkEmail__c != myOldContactMap.get(c.Id).VestMarkEmail__c 
                    && communityContactUserMap.containsKey(c.Id)) {
                        usersToUpdate.add(new User(Id=communityContactUserMap.get(c.Id).Id,
                                                   Email = c.VestMarkEmail__c));
                        
                    }
            }
        }
        
        if (!usersToUpdate.isEmpty()) update usersToUpdate;
        
    }
    
    public static List<Contact> setFirm(List<Contact> myContacts) {
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for (Contact c : myContacts) {
            accountIdSet.add(c.AccountId);
        }
        
        Map<Id,Account> firmMap = new Map<Id,Account>([SELECT Id, Account.Name, ParentId, Parent.Name, 
                                                       Parent.ParentId, Parent.Parent.Name
                                                       FROM Account
                                                       WHERE Id IN :accountIdSet]);
        
        for (Contact c : myContacts) {
            
            if (firmMap.containsKey(c.AccountId)) {
                system.debug('Parent Parent: ' + firmMap.get(c.AccountId).Parent.ParentId);
                system.debug('Parent : ' + firmMap.get(c.AccountId).ParentId);
                
                if (firmMap.get(c.AccountId).Parent.ParentId == null) {
                    c.Firm__c = firmMap.get(c.AccountId).ParentId;
                    c.FirmNameText__c = firmMap.get(c.AccountId).Parent.Name;
                } else {
                    c.Firm__c = firmMap.get(c.AccountId).Parent.ParentId;
                    c.FirmNameText__c = firmMap.get(c.AccountId).Parent.Parent.Name;
                }
            }
        }
        
        return myContacts;
    }
    
    public static void addRepToMARS(List<Contact> myContacts) {
        
        getCommunitySettings();     
        
        for (Contact c : myContacts) {
            if (c.MarsRepId__c == null && c.RecordTypeId == CRrecordTypeId && !test.isRunningTest()) {
                AddRepToMarsWSC.addRepMarsById(c.Id);  
            }
        }
        
        
    }
    
}