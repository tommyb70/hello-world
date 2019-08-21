trigger ProductCharacteristic on ProductCharacteristic__c (before insert, before update) {

    switch on Trigger.operationType {
        
        when BEFORE_INSERT {
            List<ProductCharacteristic__c> myProdChar = ProductCharacteristicTriggerHandler.SetPublishScheduleAndDate(trigger.new); 
            myProdChar = ProductCharacteristicTriggerHandler.SetCharacteristicOutputText(myProdChar);
            myProdChar = ProductCharacteristicTriggerHandler.SetPublishedFlag(myProdChar);
        }
        
        when BEFORE_UPDATE {
            List<ProductCharacteristic__c> myProdChar = ProductCharacteristicTriggerHandler.SetPublishedFlag(trigger.new);
        }
        
    }
    
}