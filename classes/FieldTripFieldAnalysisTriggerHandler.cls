/** 
* @author : Pratibha Potluri 
* @Created Date: 10/02/2018 
* @description : handler class for FieldTripFieldAnalysisTrigger. 
**/ 

public class FieldTripFieldAnalysisTriggerHandler{

      public static void populateStatistics(List<Field_Trip__Field_Analysis__c> lstFTFA,Map<Id,Field_Trip__Field_Analysis__c> mapRecords){
        
        // Query the Field_Trip__Field_Analysis__c records on After Insert to get Field_Trip__Object_Analysis__c field values
        Map<Id,Field_Trip__Field_Analysis__c> mapFTRecords = new  Map<Id,Field_Trip__Field_Analysis__c>(
                                                            [select id,
                                                                    name,
                                                                    Field_Trip__Object_Analysis__c,
                                                                    Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c,
                                                             		Field_Trip__Object_Analysis__r.Name,
                                                                    Field_Trip__Populated_On__c,
                                                                    Field_Trip__Populated_On_Percent__c,
                                                                    Field_Trip__Object_Analysis__r.Field_Trip__Last_Analyzed__c from Field_Trip__Field_Analysis__c where Id In:mapRecords.keySet()]);
        
        // Map to store the Field_Trip__Field_Analysis__c records with unique key
        Map<string,Field_Trip__Field_Analysis__c> mapFT = new Map<string,Field_Trip__Field_Analysis__c>();
        
        // Looping all the records we got in Map
        for(Field_Trip__Field_Analysis__c fa:mapFTRecords.values()){
            
            // framing unique Key value with Field and field trip object analysis object name and  field trip field analysis name
            string keyValue = 'Field:'+fa.Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c+'.'+fa.Name;
            keyValue = keyValue.toUpperCase();
            
            // adding to map with unique key and value
            mapFT.put(keyValue,fa);
        }
        
        
        // Querying Dictionary Item  records with MapFT keyset as in Dictionary Item MetadataIdentifier
        List<DictionaryItem__c> lstDI = [select id,
                                                MetadataIdentifier__c,
                                                PopulatedOn__c,
                                                PopulatedOnPercent__c,
                                         		FieldTripName__c,
                                                PopulationLastAnalyzed__c from DictionaryItem__c where MetadataIdentifier__c IN:mapFT.keyset() and MetadataIdentifier__c != null];
        
            
            if(!lstDI.isEmpty()){ 
                // looping all the Dictionary Items queried
                for(DictionaryItem__c DI:lstDI){
                    // checking whether metadataIdentifier is in Map as key or not
                    String MetadataIdentifierUpper = DI.MetadataIdentifier__c.toUpperCase();
                    if(mapFT.containsKey(MetadataIdentifierUpper)){ 
                                                
                        DI.PopulatedOn__c = mapFT.get(MetadataIdentifierUpper).Field_Trip__Populated_On__c;                                             
                        DI.PopulatedOnPercent__c = mapFT.get(MetadataIdentifierUpper).Field_Trip__Populated_On_Percent__c;                       
                        DI.PopulationLastAnalyzed__c = mapFT.get(MetadataIdentifierUpper).Field_Trip__Object_Analysis__r.Field_Trip__Last_Analyzed__c;
                        DI.FieldTripName__c = mapFT.get(MetadataIdentifierUpper).Field_Trip__Object_Analysis__r.Name;
                    }
                }                
                update lstDI;
           }
    }    
}