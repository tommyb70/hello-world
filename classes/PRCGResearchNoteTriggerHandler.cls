public class PRCGResearchNoteTriggerHandler {
    
    public static void beforeInsert(List<PRCGResearchNote__c> myNewNotes) {
        
        verifyRelatedSymbols(myNewNotes);
        
    }
    
    public static void beforeUpdate(List<PRCGResearchNote__c> myNewNotes, Map<Id,PRCGResearchNote__c> myNewNotesMap, List<PRCGResearchNote__c> myOldNotes, Map<Id,PRCGResearchNote__c> myOldNotesMap) {
        
        List<PRCGResearchNote__c> toVerify = new List<PRCGResearchNote__c>();
        
        for (PRCGResearchNote__c r : myNewNotesMap.values()){
            
            if (r.RelatedSymbols__c != myOldNotesMap.get(r.Id).RelatedSymbols__c) {
                toVerify.add(r);
            }   
        }
        
        verifyRelatedSymbols(toVerify);
        
    }
    
    public static void verifyRelatedSymbols(List<PRCGResearchNote__c> myNotes) {
        
        Set<String> symbolSet = new Set<String>();
        Set<String> checkSymbolSet = new Set<String>();
        
        for (PRCGResearchNote__c n : myNotes) {
            if (!String.isBlank(n.RelatedSymbols__c)) {
                List<String> relatedSymbolList = new List<String>();
                relatedSymbolList = n.RelatedSymbols__c.split(';',0);
                for (String s : relatedSymbolList) {
                    symbolSet.add(s);
                }
            }
        }
        
        List<Security__c> securityList = [SELECT Ticker__c 
                                          FROM Security__c
                                          WHERE Ticker__c in :symbolSet];
        
        for (Security__c t : securityList) {
            checkSymbolSet.add(t.Ticker__c);
        }
        
        for (PRCGResearchNote__c n : myNotes) {
            if (!String.isBlank(n.RelatedSymbols__c)) {
                List<String> relatedSymbolList = n.RelatedSymbols__c.split(';',0);
                for (String s : relatedSymbolList) {
                    if (!checkSymbolSet.contains(s)){
                        n.addError('Ticker ' + s + ' does not exist in the Securities object.  Please add a Security with this Ticker or remove it from the Related Symbols field.');
                    }
                }
            }
            
        } 
        
    }    
    
}