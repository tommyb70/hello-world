trigger ExchangeOptoutTrigger on ExchangeOptout__c (after insert) {
    
    if(trigger.isInsert && trigger.isAfter)
            {    
            ExchangeOptoutTriggerHandler.ExchangeOptoutAfterInsert(trigger.new);    
            }   
}