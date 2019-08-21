trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    
    switch on Trigger.operationType {
        
        when AFTER_INSERT {
            ContentDocumentLinkTriggerHandler.docuSignPWCase(trigger.new);        
        }
        
    }
}