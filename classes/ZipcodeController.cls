public class ZipcodeController {
    
    @RemoteAction
    public static List<Zipcode__c> GetAllZipcodes(String city)
    {        
        List<Zipcode__c> zipCodeList = [SELECT Channel__c, Territory__r.TerritoryName__c, state__c, city__c, zip__c, county__c, Zone__c FROM Zipcode__c where city__c = :city];
        system.debug('size:'+zipCodeList.size());
        return zipCodeList;
    }
    
    @RemoteAction
    public static Set<String> GetAllCities()
    {      
        Set<String> distinctCities = new Set<String>();  
        //List<Zipcode__c> cityList = [SELECT city__c FROM Zipcode__c];
        
        for(Zipcode__c z : [SELECT city__c FROM Zipcode__c limit 40000]) {
            if (!distinctCities.Contains(z.city__c)) {
                distinctCities.add(z.city__c);
            }
        }
        system.debug('size:'+distinctCities.size());
        return distinctCities;
    }
}