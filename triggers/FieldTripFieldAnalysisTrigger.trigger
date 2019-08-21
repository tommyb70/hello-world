/** 
* @author : Pratibha Potluri 
* @Created Date: 10/02/2018 
* @description : Trigger on FieldTripFieldAnalysis object to Populate Field Statistics on DictionaryItem obj
*/ 

trigger FieldTripFieldAnalysisTrigger on Field_Trip__Field_Analysis__c (after insert, after update)  {
    FieldTripFieldAnalysisTriggerHandler.populateStatistics(trigger.new,trigger.newMap);
}