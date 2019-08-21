public with sharing class PRCGResearchNotes {
    public final Case thisCase;
    public Map<string, List<PRCGResearchNote__c>> noteMap {get; set; }
    public List<PRCGResearchNote__c> PRCGNotes {get; set;}
    
    public PRCGResearchNotes(ApexPages.StandardController stdController) {
        this.thisCase = (Case)stdController.getRecord();
        system.debug('case:' + this.thisCase);
        system.debug('case id:'+this.thisCase.Id);
        //getnoteMap(this.thisCase.Id);
        PRCGNotes = getnoteList(this.thisCase.Id);
    }
    
    public Map<string, List<PRCGResearchNote__c>> getnoteMap(string id) {
        
        noteMap = new Map<string, List<PRCGResearchNote__c>>();
        //system.debug('case id:'+this.thisCase.RequestArtemusId__c);
        system.debug('case id:'+id);
        Case c = [select Id, RequestArtemusId__C, (select ModelId__c, Id from RequestModels__r) from case where Id = :id];
        
        for (PRCGRequestModel__c rm: c.RequestModels__r) {
            PRCGRequestModel__c model = [select Id, (select Security__r.Name, Security__r.Ticker__c, Security__c, ModelSecurityId__c from PRCGModelSecurities__r) from PRCGRequestModel__c where ModelId__C = : rm.ModelId__c];
            for (PRCGModelSecurity__c ms: model.PRCGModelSecurities__r) {
                system.debug('Hi:' + ms.Security__r.Name + 'id:' + ms.Security__c);
                string sec = ms.security__r.Name != null ? ms.security__r.Name : ms.security__c;
                
                if (noteMap.containsKey(sec)) continue;                
                //PRCGResearchNote__c [] researchNotes = [SELECT Id, name, security__c, security__r.Name, security__r.Ticker__c, Note__c, Subject__c, Approval_Status__c, Owner.Name, CreatedDate from PRCGResearchNote__c where security__c =:ms.Security__c and Approval_Status__c= 'Approved'];
                List<PRCGResearchNote__c>  researchNotes = [SELECT Id, name, security__c, security__r.Name, security__r.Ticker__c, Abstract__c, 
                                                        Note__c, Approval_Status__c, RecordType.Name, Owner.Name, CreatedDate, LastModifiedDate 
                                                        from PRCGResearchNote__c 
                                                        where security__c =:ms.Security__c 
                                                        and Approval_Status__c= 'Approved'
                                                        ORDER BY Security__r.Name, CreatedDate DESC, RecordType.Name];
                
                if (researchNotes.size() > 0) {
                    system.debug('Hello:' + ms.Security__r.Name);
                    for (PRCGResearchNote__c n : researchNotes) {
                        system.debug('Note:'+ n.security__c);
                        
                        if (noteMap.containsKey(sec)) {  
                            system.debug('hhh');              
                            List<PRCGResearchNote__c> values = noteMap.get(sec);
                            values.add(n);
                            noteMap.put(sec, values);                    
                        }
                        else {
                            system.debug('ggg');
                            noteMap.put(sec, new List<PRCGResearchNote__c>{n});
                        }
                    }
                    
                    
                    
                    
                }
            } 
            
            
            
        }
        system.debug('Notes:'+ noteMap.size());
        return noteMap;
    }
    
    public List<PRCGResearchNote__c> getnoteList(string id) {
        
        PRCGNotes = new List<PRCGResearchNote__c>();
        Set<Id> securitySet = new Set<Id>();
        //system.debug('case id:'+this.thisCase.RequestArtemusId__c);
        system.debug('case id:'+id);
        Case c = [select Id, RequestArtemusId__C, (select ModelId__c, Id from RequestModels__r) from case where Id = :id];
        
        for (PRCGRequestModel__c rm: c.RequestModels__r) {
            PRCGRequestModel__c model = [select Id, (select Security__r.Name, Security__r.Ticker__c, Security__c, ModelSecurityId__c from PRCGModelSecurities__r) from PRCGRequestModel__c where ModelId__C = : rm.ModelId__c];
            for (PRCGModelSecurity__c ms: model.PRCGModelSecurities__r) {
                system.debug('Hi:' + ms.Security__r.Name + 'id:' + ms.Security__c);
                securitySet.add(ms.Security__c);
            }
        } 
        
        system.debug('securitySet: ' + securitySet);
        
		List<PRCGResearchNote__c> PRCGNotes = new List<PRCGResearchNote__c>();
        List<PRCGResearchNote__c> PRCGNotesSelect = [SELECT Id, name, security__c, security__r.Name, security__r.Ticker__c, Abstract__c, 
                                               Note__c, Approval_Status__c, RecordType.Name, Owner.LastName, CreatedDate, LastModifiedDate 
                                               from PRCGResearchNote__c 
                                               where security__c =:securitySet 
                                               and Approval_Status__c= 'Approved'
                                               ORDER BY Security__r.Name, CreatedDate DESC, RecordType.Name];
        
        system.debug('PRCGNotesSelect: ' + PRCGNotesSelect);
        
        integer noteCount = 1;
        Id oldSecurity;
        Boolean firstLoop = TRUE;
        for (PRCGResearchNote__c n : PRCGNotesSelect) {
            
            if (firstLoop) {
              firstLoop = FALSE;
              oldSecurity = n.security__c;
            }
            
            if (n.security__c == oldSecurity) {
                noteCount = noteCount + 1;
            } else {
                noteCount = 1;
            }
            
            if (noteCount <= 3) PRCGNotes.add(n);
            oldSecurity = n.security__c;
            
        }
        
        
        return PRCGNotes;
    }
    
}