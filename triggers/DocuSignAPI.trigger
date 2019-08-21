trigger DocuSignAPI on Attachment (After insert) {
    
    if(trigger.isInsert && trigger.isafter){
        
        for(Attachment csupdate: Trigger.new){  
            
            DocuSignAPITriggerHandler.DocuSigTriggerAfterInsert(csupdate.Id);        
            
        }
        
    }
}