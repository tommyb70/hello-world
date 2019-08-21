public class CDRQualitativeDataTriggerHandler {
    
    public static void dateDupeChecks (List<CDRQualitativeData__c> myNewCDR, Map<Id,CDRQualitativeData__c> myOldCDRMap) {
        
        CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
        
        if (settings.OverrideTriggerValidations__c == FALSE) {
            Map<String, CDRQualitativeData__c> cdrMap= new Map<String, CDRQualitativeData__c>();
            Map<String,CDRQualitativeData__c> parentKeyDraftMap = new Map<String,CDRQualitativeData__c>();
            Map<String,CDRQualitativeData__c> parentKeyActHistMap = new Map<String,CDRQualitativeData__c>();
            Set<String> parentKeySet = new Set<String>();
            Map<String,CDRQualitativeData__c> parentKeyEffDtMap = new Map<String,CDRQualitativeData__c>();
            
            for (CDRQualitativeData__c ahm : myNewCDR) {
                parentKeySet.add(ahm.ParentKey__c);
                if ((ahm.Status__c == 'Active' || ahm.Status__c == 'Historical' || ahm.Status__c == 'Pending Activation')  
                    && System.Trigger.isInsert) {
                        parentKeyActHistMap.put(ahm.ParentKey__c, ahm);
                    }
            }
            
            for (CDRQualitativeData__c cdr : myNewCDR) {
                
                if (cdr.Status__c == 'Draft') {
                    if (parentKeyDraftMap.containsKey(cdr.ParentKey__c)) {
                        cdr.addError('There is another Draft record already; please coordinate updates');
                    } else {
                        parentKeyDraftMap.put(cdr.ParentKey__c, cdr);
                    }
                }
                
                if (cdr.Status__c == 'Draft') {
                    if (parentKeyActHistMap.containsKey(cdr.ParentKey__c)) {
                        if (parentKeyActHistMap.get(cdr.ParentKey__c).EffectiveDate__c > cdr.EffectiveDate__c)    
                            cdr.addError('There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed');
                    } else {
                        parentKeyActHistMap.put(cdr.ParentKey__c, cdr);
                    }                    
                    
                }
                
                if (parentKeyEffDtMap.containsKey(cdr.ParentKey__c + cdr.EffectiveDate__c.format())) {
                    cdr.addError('There is another row with the exact same Effective Date; please change the Effective Date on this record');
                } else {
                    parentKeyEffDtMap.put(cdr.ParentKey__c + cdr.EffectiveDate__c.format(), cdr);
                }
                
            }
            
            for (CDRQualitativeData__c cdr : [SELECT ParentKey__c 
                                              FROM CDRQualitativeData__c
                                              WHERE Status__c = 'Draft'
                                              AND ParentKey__c IN :parentKeyDraftMap.KeySet()
                                              AND Id NOT IN :myNewCDR]) {
                                                  if (parentKeyDraftMap.containsKey(cdr.ParentKey__c)) {
                                                      CDRQualitativeData__c newCDR = parentKeyDraftMap.get(cdr.ParentKey__c);
                                                      newCDR.addError('There is another Draft record already; please coordinate updates');
                                                  }
                                              }
            
            for (CDRQualitativeData__c cdr : [SELECT ParentKey__c, EffectiveDate__c, Name
                                              FROM CDRQualitativeData__c
                                              WHERE ParentKey__c IN :parentKeyDraftMap.KeySet()
                                              AND Id NOT IN :myNewCDR
                                              AND Status__c IN ('Active','Historical','Pending Activation')]) {
                                                  system.debug('ParentKey__c: ' + cdr.ParentKey__c);
                                                  system.debug('Effdt: ' + cdr.EffectiveDate__c);
                                                  if (parentKeyDraftMap.containsKey(cdr.ParentKey__c)) {
                                                      CDRQualitativeData__c newCDR = parentKeyDraftMap.get(cdr.ParentKey__c);
                                                      if (cdr.EffectiveDate__c > newCDR.EffectiveDate__c) {
                                                          newCDR.addError('There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed');
                                                      }
                                                  }
                                              }
            
            for (CDRQualitativeData__c cdr : [SELECT Id, ParentKey__c, EffectiveDate__c, Name
                                              FROM CDRQualitativeData__c
                                              WHERE ParentKey__c IN :parentKeySet
                                              AND Id NOT IN :myNewCDR]) {
                                                  system.debug('Found: ' + cdr.Name);
                                                  if (parentKeyEffDtMap.containsKey(cdr.ParentKey__c + cdr.EffectiveDate__c.format())) {
                                                      CDRQualitativeData__c newCDR = parentKeyEffDtMap.get(cdr.ParentKey__c + cdr.EffectiveDate__c.format());
                                                      if (newCDR.Id != cdr.Id) {                                                      
                                                          newCDR.addError('There is another row with the exact same Effective Date; please change the Effective Date on this record');
                                                      }
                                                  }
                                              }
        }
    }
    
    public static void setFieldValuesBefore (List<CDRQualitativeData__c> myNewCDR) {
        
        Boolean containsContacts = FALSE;
        Boolean containsAccounts = FALSE;
        Boolean containsProducts = FALSE;
        Boolean containsAddlInfo = FALSE;
        
        CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
        
        Map<Id,Schema.RecordTypeInfo> recTypeMap = CDRQualitativeData__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Set<String> relatedRecordIdSet = new Set<String>();
        Map<Id,String> nameMap = new Map<Id,String>();
        
        for (CDRQualitativeData__c cdr : myNewCDR) {
            
            if (system.trigger.isInsert && settings.OverrideSetStatusOnCreate__c == FALSE) {
                cdr.Status__c = 'Draft';
            }
            
            if (cdr.Status__c == 'Pending Activation' && cdr.EffectiveDate__c <= datetime.now()) {
                cdr.Status__c = 'Active';
            } 
            
            if (cdr.Status__c == 'Draft') {
                cdr.ApprovalStatus__c = 'Not Submitted';
            }
            
            if (cdr.AdditionalInfo__c != null) {
                relatedRecordIdSet.add(cdr.AdditionalInfo__c);
                containsAddlInfo = TRUE;
            }
            if (cdr.Product__c != null) {
                relatedRecordIdSet.add(cdr.Product__c);
                containsProducts = TRUE;
            }
            if (cdr.Benchmark__c != null) {
                relatedRecordIdSet.add(cdr.Benchmark__c);
                containsProducts = TRUE;
            }
            if (cdr.ChildProduct__c != null) {
                relatedRecordIdSet.add(cdr.ChildProduct__c);
                containsProducts = TRUE;
            }
            if (cdr.ChildAccount__c != null) {
                relatedRecordIdSet.add(cdr.ChildAccount__c); 
                containsAccounts = TRUE;
            }
            if (cdr.Account__c != null) {
                relatedRecordIdSet.add(cdr.Account__c);
                containsAccounts = TRUE;
            }
            if (cdr.Contact__c != null) {
                relatedRecordIdSet.add(cdr.Contact__c); 
                containsContacts = TRUE;
            }
            
        }
        
        // gets for Product, Benchmark, Child Product
        if (containsProducts){
            for (Product2 nm : [SELECT Id, Name, CaseSafeId__c FROM Product2 WHERE Id in :relatedRecordIdSet]) {
                nameMap.put(nm.Id,nm.Name);
            }
        }
        
        if (containsAddlInfo) {
            for (AdditionalInfo__c nm : [SELECT Id, Name, CaseSafeId__c FROM AdditionalInfo__c WHERE Id in :relatedRecordIdSet]) {
                nameMap.put(nm.Id,nm.Name);
            }
        }
        
        if (containsAccounts) {
            for (Account nm : [SELECT Id, Name, FirmOfficeID18__c FROM Account WHERE Id in :relatedRecordIdSet]) {
                nameMap.put(nm.Id,nm.Name);
            }
        }
        
        if (containsContacts) {
            for (Contact nm : [SELECT Id, Name, CaseSafeId__c FROM Contact WHERE Id in :relatedRecordIdSet]) {
                nameMap.put(nm.Id,nm.Name);
            }
        }
        
        
        for (CDRQualitativeData__c cdr : myNewCDR) {
            
            String newName = cdr.EffectiveDate__c.format('yyyy-MM-dd') + ' (' + cdr.Status__c.left(1) + ') '; 
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Additional Info')) newName += nameMap.get(cdr.AdditionalInfo__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Benchmark')) newName += nameMap.get(cdr.Benchmark__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Benchmark-Additional Info')) newName += nameMap.get(cdr.Benchmark__c).left(30) + ' - ' + nameMap.get(cdr.AdditionalInfo__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Contact')) newName += nameMap.get(cdr.Contact__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Contact-Additional Info')) newName += nameMap.get(cdr.Contact__c).left(30) + ' - ' + nameMap.get(cdr.AdditionalInfo__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('ETF')) newName += nameMap.get(cdr.Product__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm')) newName += nameMap.get(cdr.Account__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm-Additional Info')) newName += nameMap.get(cdr.Account__c).left(30) + ' - ' + nameMap.get(cdr.AdditionalInfo__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm-Child Firm')) newName += nameMap.get(cdr.Account__c).left(30) + ' - ' + nameMap.get(cdr.ChildAccount__c).left(30);            
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm-Contact')) newName += nameMap.get(cdr.Account__c).left(30) + '-' + nameMap.get(cdr.Contact__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm-Product')) newName += nameMap.get(cdr.Account__c).left(30) + '-' + nameMap.get(cdr.Product__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Mutual Fund')) newName += nameMap.get(cdr.Product__c);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Product-Additional Info')) newName += nameMap.get(cdr.Product__c).left(30) + '-' + nameMap.get(cdr.AdditionalInfo__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Product-Benchmark')) newName += nameMap.get(cdr.Product__c).left(30) + ' - ' + nameMap.get(cdr.Benchmark__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Product-Child Product')) newName += nameMap.get(cdr.Product__c).left(30) + ' - ' + nameMap.get(cdr.ChildProduct__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Product-Contact')) newName += nameMap.get(cdr.Product__c).left(30) + ' - ' + nameMap.get(cdr.Contact__c).left(30);
            if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Share Class')) newName += nameMap.get(cdr.Product__c);            
            cdr.Name = newName;
            
        }       
        
    }
    
    
    public static void bumpCDRRecordStatus(Map<Id,CDRQualitativeData__c> newCDRMap, Map<Id,CDRQualitativeData__c> oldCDRMap) {
        
        Map<String,CDRQualitativeData__c> newStatusMap = new Map<String,CDRQualitativeData__c>();
        List<CDRQualitativeData__c> toBeBumped = new List<CDRQualitativeData__c>();
        List<CDRQualitativeData__c> setDates = new List<CDRQualitativeData__c>();
        Map<String,CDRQualitativeData__c> stagingMap = new Map<String,CDRQualitativeData__c>();
        Map<String,CDRQualitativeData__c> pendingMap = new Map<String,CDRQualitativeData__c>();
        List<CDRQualitativeData__c> activeAndHistoricalList = new List<CDRQualitativeData__c>();
        List<CDRQualitativeData__c> toBeLocked = new List<CDRQualitativeData__c>();
        List<CDRQualitativeData__c> toBeUnlocked = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c cdr : newCDRMap.values()) {
            if (cdr.Status__c != oldCDRMap.get(cdr.Id).Status__c && cdr.Status__c != 'Historical' && cdr.Status__c != 'Inactive') {
                newStatusMap.put(cdr.ParentKey__c, cdr);
            }
        }
        
        for (CDRQualitativeData__c b : [SELECT Id, SortOrder__c, ParentKey__c, Status__c, EffectiveDate__c, Name
                                        FROM CDRQualitativeData__c
                                        WHERE ParentKey__c in :newStatusMap.keySet()
                                        AND Status__c in ('Active', 'Pending Activation','Staging')
                                        AND Id NOT in: newCDRMap.keySet()
                                        ORDER BY ParentKey__c, Status__c]) {
                                            
                                            if (newStatusMap.containsKey(b.ParentKey__c)) {
                                                // Coming from Staging to Active bumps any currently Active rows to Historical
                                                
                                                if (b.Status__c == 'Active' && newStatusMap.get(b.ParentKey__c).Status__c == 'Active' ) {
                                                    b.Status__c = 'Historical';
                                                    b.NextPendingActivationDate__c = null;
                                                    b.NextStagingDate__c = null;
                                                    toBeLocked.add(b);
                                                    toBeBumped.add(b);
                                                }
                                                // Coming from Staging to Pending Activation bumps any currently Pending Activation rows to Draft
                                                if (b.Status__c == 'Pending Activation' && newStatusMap.get(b.ParentKey__c).Status__c == 'Pending Activation') {
                                                    b.Status__c = 'Inactive';                
                                                    toBeLocked.add(b);
                                                    toBeBumped.add(b);
                                                }
                                                // Coming from Draft to Staging bumps any currently Staging rows to Draft
                                                if (b.Status__c == 'Staging' && newStatusMap.get(b.ParentKey__c).Status__c == 'Staging') {
                                                    b.Status__c = 'Draft';
                                                    toBeUnlocked.add(b);
                                                    toBeBumped.add(b);
                                                }
                                            }
                                        }
        
        update toBeBumped;
        
        // setting up map after bump to pick up any new Staging and Pending Activation records
        for (CDRQualitativeData__c m : [SELECT Id, SortOrder__c, ParentKey__c, Status__c, EffectiveDate__c, Name, HistoricalDate__c
                                        FROM CDRQualitativeData__c
                                        WHERE ParentKey__c in :newStatusMap.keySet()
                                        AND Status__c IN ('Staging', 'Pending Activation', 'Historical','Active')
                                        ORDER BY ParentKey__c, EffectiveDate__c DESC]) {
                                            if (m.Status__c == 'Staging') stagingMap.put(m.ParentKey__c,m);
                                            if (m.Status__c == 'Pending Activation') pendingMap.put(m.ParentKey__c,m);
                                            if (m.Status__c == 'Active' || m.Status__c == 'Historical') activeAndHistoricalList.add(m);
                                            if (m.SortOrder__c == 124) system.debug('Adding 124');
                                        }
        
        // for All currently Active or Historical rows, set Historical Date
        for (CDRQualitativeData__c hdo : activeAndHistoricalList) {
            
            for (CDRQualitativeData__c hdi : activeAndHistoricalList) {
                
                if (hdo.EffectiveDate__c < hdi.EffectiveDate__c && hdo.ParentKey__c == hdi.ParentKey__c) {
                    hdo.HistoricalDate__c = hdi.EffectiveDate__c;
                }
                
            }
            
            if (hdo.Status__c == 'Historical') {
                hdo.EffectiveDate__c = (hdo.EffectiveDate__c == null) ? Datetime.now() : hdo.EffectiveDate__c;
                setDates.add(hdo);                
            }
        }
        
        // for all currently Active or Pending Activation rows, set or reset 'next' dates
        for (CDRQualitativeData__c d : [SELECT Id, SortOrder__c, ParentKey__c, Status__c, EffectiveDate__c, Name
                                        FROM CDRQualitativeData__c
                                        WHERE ParentKey__c in :newStatusMap.keySet()
                                        AND Status__c IN ('Active', 'Pending Activation')]) {
                                            
                                            // if status is Active, set NextStagingDate and NextPendingActivationDate
                                            if (d.Status__c == 'Active') {
                                                if (stagingMap.containsKey(d.ParentKey__c)) {
                                                    d.NextStagingDate__c = stagingMap.get(d.ParentKey__c).EffectiveDate__c;
                                                    d.HasStagingRow__c = TRUE;
                                                } else {
                                                    d.NextStagingDate__c = null;
                                                    d.HasStagingRow__c = FALSE;
                                                }
                                                if (pendingMap.containsKey(d.ParentKey__c)) {
                                                    d.NextPendingActivationDate__c = pendingMap.get(d.ParentKey__c).EffectiveDate__c;
                                                    d.HasPendingActivationRow__c  = TRUE;
                                                } else {
                                                    d.NextPendingActivationDate__c = null;
                                                    d.HasPendingActivationRow__c  = FALSE;
                                                }
                                                setDates.add(d);
                                            }
                                            
                                            // if status is Pending Activation, set NextStagingDate 
                                            if (d.Status__c == 'Pending Activation') {
                                                if (stagingMap.containsKey(d.ParentKey__c)) {
                                                    d.NextStagingDate__c = stagingMap.get(d.ParentKey__c).EffectiveDate__c;
                                                    d.HasStagingRow__c = TRUE;
                                                } else {
                                                    d.NextStagingDate__c = null;
                                                    d.HasStagingRow__c = FALSE;
                                                }
                                                setDates.add(d);
                                            }
                                            
                                        }
        
        update setDates;
        
    }    
    
    public static void updateParentsOnActive (List<CDRQualitativeData__c> myNewCDR) {
        
        Boolean containsContacts = FALSE;
        Boolean containsAccounts = FALSE;
        Boolean containsProducts = FALSE;
        Boolean containsAddlInfo = FALSE;
        
        Map<Id,Schema.RecordTypeInfo> recTypeMap = CDRQualitativeData__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<Id,CDRQualitativeData__c> parentCDRMap = new Map<Id,CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c cdr : myNewCDR) {
            
            if (cdr.Status__c == 'Active') {
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Benchmark')) parentCDRMap.put(cdr.Benchmark__c, cdr); containsProducts = TRUE;
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Mutual Fund')) parentCDRMap.put(cdr.Product__c, cdr); containsProducts = TRUE;
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Share Class')) parentCDRMap.put(cdr.Product__c, cdr); containsProducts = TRUE;
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('ETF')) parentCDRMap.put(cdr.Product__c, cdr); containsProducts = TRUE;               
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Firm')) parentCDRMap.put(cdr.Account__c, cdr); containsAccounts = TRUE;
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Contact')) parentCDRMap.put(cdr.Contact__c, cdr); containsContacts = TRUE;               
                if (recTypeMap.get(cdr.RecordTypeId).getName().equals('Additional Info')) parentCDRMap.put(cdr.AdditionalInfo__c, cdr); containsAddlInfo = TRUE;
            }
            
        }
        
        List<Product2> prodToUpdate = new List<Product2>();
        List<Account> accountToUpdate = new List<Account>();
        List<Contact> contactToUpdate = new List<Contact>();
        List<AdditionalInfo__c> AddlInfoToUpdate = new List<AdditionalInfo__c>();
        
        if (containsProducts) {
            prodToUpdate = [SELECT ActiveCDRQualitativeData__c, TradingSymbol__c FROM Product2 WHERE Id in :parentCDRMap.keySet()];
        }
        if (containsAccounts) {
            accountToUpdate = [SELECT ActiveCDRQualitativeData__c FROM Account WHERE Id in :parentCDRMap.keySet()];
        }
        if (containsContacts) {
            contactToUpdate = [SELECT ActiveCDRQualitativeData__c FROM Contact WHERE Id in :parentCDRMap.keySet()];
        }
        if (containsAddlInfo) {
            AddlInfoToUpdate = [SELECT ActiveCDRQualitativeData__c FROM AdditionalInfo__c WHERE Id in :parentCDRMap.keySet()];        
        }
        
        for (Product2 p : prodToUpdate) {
            p.ActiveCDRQualitativeData__c = parentCDRMap.get(p.Id).Id;
            p.TradingSymbol__c = parentCDRMap.get(p.Id).TradingSymbol__c;
            p.InceptionDate__c = parentCDRMap.get(p.Id).InceptionDate__c;     
            p.CUSIP__c = parentCDRMap.get(p.Id).CUSIP__c;
            p.ISIN__c = parentCDRMap.get(p.Id).ISIN__c;            
            p.ShareClass__c = parentCDRMap.get(p.Id).ShareClass__c;
            
            if (recTypeMap.get(parentCDRMap.get(p.Id).RecordTypeId).getName().equals('Benchmark')) {
                p.LegalName__c = (parentCDRMap.get(p.Id).BenchmarkLegalName__c != null) ? parentCDRMap.get(p.Id).BenchmarkLegalName__c.stripHtmlTags() : p.LegalName__c;  
                p.RichTextName__c = (parentCDRMap.get(p.Id).BenchmarkLegalName__c != null) ? parentCDRMap.get(p.Id).BenchmarkLegalName__c : p.RichTextName__c; 
            } else {
                p.LegalName__c = (parentCDRMap.get(p.Id).ProductLegalName__c != null) ? parentCDRMap.get(p.Id).ProductLegalName__c.stripHtmlTags() : p.LegalName__c;  
                p.RichTextName__c = (parentCDRMap.get(p.Id).ProductLegalName__c != null) ? parentCDRMap.get(p.Id).ProductLegalName__c : p.RichTextName__c; 
            }
            
        }        
        
        for (Account a : accountToUpdate) {
            a.ActiveCDRQualitativeData__c = parentCDRMap.get(a.Id).Id;
            if (parentCDRMap.get(a.Id).FirmLegalName__c != null) a.LegalName__c = parentCDRMap.get(a.Id).FirmLegalName__c.stripHtmlTags();
        }        
        
        for (Contact c : contactToUpdate) {
            c.ActiveCDRQualitativeData__c = parentCDRMap.get(c.Id).Id;
        }        
        
        for (AdditionalInfo__c i : AddlInfoToUpdate) {
            i.ActiveCDRQualitativeData__c = parentCDRMap.get(i.Id).Id;
        }        
        
        if (!prodToUpdate.isEmpty()) update prodToUpdate;
        if (!accountToUpdate.isEmpty()) update accountToUpdate;
        if (!contactToUpdate.isEmpty()) update contactToUpdate;
        if (!AddlInfoToUpdate.isEmpty()) update AddlInfoToUpdate;        
        
    }
    
    public static void lockAndUnlockRecords (List<CDRQualitativeData__c> myNewCDR) {
        //Set up to account for all approval and recall actions, bump actions, etc.
        
        List<CDRQualitativeData__c> toBeLocked = new List<CDRQualitativeData__c>();
        List<CDRQualitativeData__c> toBeUnlocked = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c cdr : myNewCDR) {
            
            if (cdr.Status__c == 'Draft') {
                toBeUnlocked.add(cdr);
            } else {
                toBeLocked.add(cdr);
            }
        }
        
        List<Approval.LockResult> ur = Approval.lock(toBeLocked);
        List<Approval.UnLockResult> ulr = Approval.unLock(toBeUnlocked);
        
    }
    
}