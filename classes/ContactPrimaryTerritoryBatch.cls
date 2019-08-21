global class ContactPrimaryTerritoryBatch implements Database.Batchable<sObject>, Database.Stateful {
// This batch updates the contacts with the corresponding primary, overlap and secondary territories and external, hybrid and internal users
    global final String query;
      
    global ContactPrimaryTerritoryBatch(String q) {  
       query = q;  
    } 

    global Database.querylocator start(Database.BatchableContext BC){  
        return Database.getQueryLocator(query);          
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){  
    
        //Create a map to store distinct contacts with list of their Contact Territories.
        Map<string, List<ContactTerritory__c>> conMap = new Map<string, List<ContactTerritory__c>>();
        Set<string> repIds = new Set<string>();
        Map<string, Contact> cons = new Map<string, Contact>();
        for(Contact con : scope) {                         
            cons.put(con.Id, con);           
        }
        
        List<ContactTerritory__c> contactTerrs = [select Id,Territory__r.TerritoryName__c,Territory__r.ParentTerritory__r.TerritoryName__c,Contact__r.LastModifiedDate,Contact__r.MarsRepId__c,Contact__r.Id,
                                                Territory__r.Wholesaler1__r.UserId__c, Territory__r.CoverageUserID__c,    
                                                contact__r.PrimaryTerritory__c, contact__r.PrimaryRegion__c, contact__r.PrimaryMarketingUser__r.UserId__c,
                                                contact__r.OverlapTerritory__c,contact__r.OverlapExternalUser__r.UserId__c, Zone__c, 
                                                contact__r.PrimaryTerritoryLookup__r.TerritoryName__c
                                                from ContactTerritory__c where contact__r.Id in : cons.keySet()];
        
        for(ContactTerritory__c conTerr : contactTerrs) { 
            if (conMap.containsKey(conTerr.Contact__r.Id)) {                
                List<ContactTerritory__c> terrValues = conMap.get(conTerr.Contact__r.Id);
                terrValues.add(conTerr);
                conMap.put(conTerr.Contact__r.Id,terrValues);                    
            }
            else {
                conMap.put(conTerr.Contact__r.Id, new List<ContactTerritory__c>{conTerr});
            }
        }
        
        for(string id : cons.keySet()) {
            if (!conMap.containsKey(id)) {
                conMap.put(id, new List<ContactTerritory__c>());
            }
        } 
        
        // Get all the user territories based on the below criteria       
        List<UserTerritory__c> userTerritory = [select Id, Territory__r.TerritoryName__c, Territory__r.TerritoryType__c, Zoning__r.Name, Zoning__r.Zone__c, User__r.UserID__c, ActivityTerritory__c, User__r.ZoneCoverage__r.UserId__c
                        from UserTerritory__c where Territory__r.TerritoryName__c != 'NATIXIS GLOBAL ASSET MANAGEMENT' 
                        and Zoning__r.Name != 'All Zones' and User__r.IsActive = true and ActivityTerritory__c = true and
                        (not Territory__r.TerritoryName__c like 'RCDU %')
                        order by Territory__r.TerritoryName__c, Zoning__r.Zone__c];
                        
        userTerritory.addall([select Id, Territory__r.TerritoryName__c, Territory__r.TerritoryType__c, Zoning__r.Name, Zoning__r.Zone__c, User__r.UserID__c, ActivityTerritory__c, User__r.ZoneCoverage__r.UserId__c
                        from UserTerritory__c where Territory__r.TerritoryName__c != 'NATIXIS GLOBAL ASSET MANAGEMENT' 
                        and Zoning__r.Name != 'All Zones' and User__r.IsActive = true and 
                        (Territory__r.TerritoryName__c like 'RCDU %')
                        order by Territory__r.TerritoryName__c, Zoning__r.Zone__c]);
        
      
        // Get all the territories                
        List<Territory__c> territories = [select TerritoryName__c, TerritoryType__c, ParentTerritory__r.TerritoryName__c, (select TerritoryName__c, TerritoryType__c from Territories__r) from Territory__c];
        Map<string, Territory__c> allTerrMap = new Map<string, territory__c>();
        for(Territory__c t : territories) {
            allTerrMap.put(t.TerritoryName__c, t);
        }   
        
        //Create a map to store distinct Territories with list of their User Territories.               
        Map<string, List<UserTerritory__c>> userTerrMap = new Map<string, List<UserTerritory__c>>();
        for(UserTerritory__c userTerr : userTerritory) { 
            if (userTerr.Territory__r.TerritoryType__c == 'Region')
            {                    
                Territory__c t = allTerrMap.get(userTerr.Territory__r.TerritoryName__c);
                for(Territory__c t1 : t.Territories__r){
                    if (userTerrMap.containsKey(t1.TerritoryName__c)) {               
                        List<UserTerritory__c> userTerrValues = userTerrMap.get(t1.TerritoryName__c);
                        userTerrValues.add(userTerr);
                        userTerrMap.put(t1.TerritoryName__c,userTerrValues);                    
                    }
                    else {
                        userTerrMap.put(t1.TerritoryName__c, new List<UserTerritory__c>{userTerr});
                    }
                }
            }
            if (userTerrMap.containsKey(userTerr.Territory__r.TerritoryName__c)) {               
                List<UserTerritory__c> userTerrValues = userTerrMap.get(userTerr.Territory__r.TerritoryName__c);
                userTerrValues.add(userTerr);
                userTerrMap.put(userTerr.Territory__r.TerritoryName__c,userTerrValues);                    
            }
            else {
                userTerrMap.put(userTerr.Territory__r.TerritoryName__c, new List<UserTerritory__c>{userTerr});
            }
        }     
                                                       
        //List of contacts to update
        List<contact> contacts = new List<contact>();
                
        for(string key : conMap.keySet()){
        
            contact c = new contact(Id = key);
            contact ct = cons.get(key);
            
            // Save the existing values
            string oldPrimTerr = ct.PrimaryTerritory__c;
            string oldPrimReg = ct.PrimaryRegion__c;
            string oldPrimTerrLookup = ct.PrimaryTerritoryLookup__r.TerritoryName__c;
            string oldPrimMktUser = ct.PrimaryMarketingUser__r.UserId__c;           
            string oldOvlTerr = ct.OverlapTerritory__c;
            string oldOvlExtUser = ct.OverlapExternalUser__r.UserId__c; 
            string oldFullSrvUser = ct.FullServiceSalesUser__r.UserId__c;                                  
                                            
            //Empty all the fields
            c.PrimaryTerritory__c = null; 
            c.PrimaryRegion__c = null; 
            c.PrimaryTerritoryLookup__r = null;     
            c.OverlapTerritory__c = null;             
            c.PrimaryMarketingUser__r = null;                       
            c.OverlapExternalUser__r = null; 
            c.FullServiceSalesUser__r = null;                     
                                 
            List<ContactTerritory__c> conTerrs = conMap.get(key);           
            
            if (conTerrs.size() == 0) {  
                if (oldPrimTerr != c.PrimaryTerritory__c || oldPrimReg != c.PrimaryRegion__c || 
                     oldPrimTerrLookup != c.PrimaryTerritoryLookup__r.TerritoryName__c || oldPrimMktUser != c.PrimaryMarketingUser__r.UserId__c ||
                     oldOvlTerr != c.OverlapTerritory__c || oldOvlExtUser != c.OverlapExternalUser__r.UserId__c ||
                     oldFullSrvUser != c.FullServiceSalesUser__r.UserId__c) {
                    
                    if (c.PrimaryTerritoryLookup__r.TerritoryName__c == null) c.PrimaryTerritoryLookup__c = null;
                    if (c.PrimaryMarketingUser__r.UserId__c == null) c.PrimaryMarketingUser__c = null;    
                    if (c.OverlapExternalUser__r.UserId__c == null) c.OverlapExternalUser__c = null;   
                    if (c.FullServiceSalesUser__r.UserId__c == null) c.FullServiceSalesUser__c = null;          
                    contacts.add(c);
                }
                continue;
            }              
                        
            c .MarsRepId__c = conTerrs[0].contact__r.MarsRepId__c;     
             
            // Arrange the territories in the order as per the logic
            Map<Integer, string> terrMap = new Map<Integer, string>(); 
            Map<string, string> terrUserMap = new Map<string, string>(); 
            Map<string, string> terrFullSrvUserMap = new Map<string, string>();
            Map<string, string> conTerrMap = new Map<string, string>(); 
            Map<string, string> zoneMap = new Map<string, string>();             
            Boolean isRCDUZone = false; 
            for(ContactTerritory__c terr: conTerrs)
            {
                 if (terr.Territory__r.TerritoryName__c.startswith('RCDU') && terr.zone__c != null) { 
                     isRCDUZone = true;
                     break;
                 }
            }
            system.debug('isRCDUZone:' + isRCDUZone);
                             
            for(ContactTerritory__c terr: conTerrs)
            {
                if (isRCDUZone) {
                    if (terr.Territory__r.TerritoryName__c.startswith('RCDU')) terrMap.put(1, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('ADU') &&
                       !terr.Territory__r.TerritoryName__c.startswith('ADU BANK TRUST') &&
                       !terr.Territory__r.TerritoryName__c.startswith('ADU RIA')) terrMap.put(2, terr.Territory__r.TerritoryName__c);     
                    if (terr.Territory__r.TerritoryName__c.startswith('FIDUCIARY')) terrMap.put(3, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('INSTL')) terrMap.put(5, terr.Territory__r.TerritoryName__c);               
                    if (terr.Territory__r.TerritoryName__c.startswith('RCDU')) terrMap.put(6, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('PLAN SPONSOR')) terrMap.put(6, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('RADU')) terrMap.put(7, terr.Territory__r.TerritoryName__c);                              
                    if (terr.Territory__r.TerritoryName__c.startswith('GLOBAL RELATIONS')) terrMap.put(9, terr.Territory__r.TerritoryName__c);  
                    if (terr.Territory__r.TerritoryName__c.startswith('RIA PLATFORM')) terrMap.put(10, terr.Territory__r.TerritoryName__c);     
                    if (terr.Territory__r.TerritoryName__c.startswith('NAT ADV')) terrMap.put(11, terr.Territory__r.TerritoryName__c);
                } else {
                    if (terr.Territory__r.TerritoryName__c.startswith('ADU') &&
                       !terr.Territory__r.TerritoryName__c.startswith('ADU BANK TRUST') &&
                       !terr.Territory__r.TerritoryName__c.startswith('ADU RIA')) terrMap.put(2, terr.Territory__r.TerritoryName__c);     
                    if (terr.Territory__r.TerritoryName__c.startswith('FIDUCIARY')) terrMap.put(3, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('INSTL')) terrMap.put(5, terr.Territory__r.TerritoryName__c);               
                    if (terr.Territory__r.TerritoryName__c.startswith('RCDU')) terrMap.put(6, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('PLAN SPONSOR')) terrMap.put(6, terr.Territory__r.TerritoryName__c); 
                    if (terr.Territory__r.TerritoryName__c.startswith('RADU')) terrMap.put(7, terr.Territory__r.TerritoryName__c);                              
                    if (terr.Territory__r.TerritoryName__c.startswith('GLOBAL RELATIONS')) terrMap.put(9, terr.Territory__r.TerritoryName__c);  
                    if (terr.Territory__r.TerritoryName__c.startswith('RIA PLATFORM')) terrMap.put(10, terr.Territory__r.TerritoryName__c);     
                    if (terr.Territory__r.TerritoryName__c.startswith('NAT ADV')) terrMap.put(11, terr.Territory__r.TerritoryName__c);
                }                  
                            
                String userId = (terr.Territory__r.CoverageUserID__c != null) ? terr.Territory__r.CoverageUserID__c : terr.Territory__r.Wholesaler1__r.UserId__c;
                                
                // For RADU and PLAN SPONSOR, it should be always external                
                if (terr.Territory__r.TerritoryName__c.startswith('RADU') || terr.Territory__r.TerritoryName__c.startswith('PLAN SPONSOR'))  {
                    userId = terr.Territory__r.Wholesaler1__r.UserId__c;
                }

				// For unzoned RCDU, it should be external
                if (!isRCDUZone && terr.Territory__r.TerritoryName__c.startswith('RCDU')) {
                    userId = terr.Territory__r.Wholesaler1__r.UserId__c;
                }                
               
                zoneMap.put(terr.Territory__r.TerritoryName__c, terr.zone__c); 
                
                terrUserMap.put(terr.Territory__r.TerritoryName__c, userId);  
                terrFullSrvUserMap.put(terr.Territory__r.TerritoryName__c, terr.Territory__r.Wholesaler1__r.UserId__c); 
                conTerrMap.put(terr.Territory__r.TerritoryName__c, terr.Territory__r.ParentTerritory__r.TerritoryName__c);                
            }            
           
            List<Integer> terrList = new List<Integer>();
            terrList.addAll(terrMap.keySet());
            terrList.sort();                 
           
            //Assign overlap territory users
            for(Integer o: terrList)
            {
                string terr = terrMap.get(o);
                // Get user
                String userId = terrUserMap.get(terr);
                String fullSrvUserId = terrFullSrvUserMap.get(terr);
              
                // Get zone
                string zone = zoneMap.get(terr);
                system.debug('zone:'+ zone);
                                                                
                 //RADU territories should belong to Overlap
                if (string.IsEmpty(c.OverlapTerritory__c) && terr.startswith('RADU'))
                {
                    c.OverlapTerritory__c = terr;
                    if (userId != null) c.OverlapExternalUser__r = new User (UserId__c = userId);
                }  
                    
                if (string.IsEmpty(c.PrimaryTerritory__c))
                {                      
                    //Assign primary territory
                    c.PrimaryTerritory__c = terr;
                    String pRegion = conTerrMap.get(terr);
                    c.PrimaryRegion__c = pRegion;  
                    c.PrimaryTerritoryLookup__r = new Territory__c (TerritoryName__c = terr);                  
                    
                    if (terr.startsWith('GLOBAL RELATIONS')) {                        
                    }
                    else if (terr.startsWith('RCDU')) {                        
                        List<UserTerritory__c> userTerrs = userterrMap.get(terr);
                        system.debug('userterrs:'+userTerrs);
                        
                        if (userTerrs != null && zone != null) {
                           string user = getUserByContactZone(userTerrs, zone);
                           system.debug('user:'+user);
                           if(user!= null) {
                               c.PrimaryMarketingUser__r = new User ( UserId__c = user); 
                               c.FullServiceSalesUser__r = new User (UserId__c = user);
                           }                      
                        }   
                    }
                    else {                        
                        if (userId != null) c.PrimaryMarketingUser__r = new User ( UserId__c = userId);  
                        if (fullSrvUserId != null) c.FullServiceSalesUser__r = new User( UserId__c = fullSrvUserId);
                    } 
                }                                          
            } 
            
            //Update primary marketing user with NUser in case of no primary territory
            /*if (c.PrimaryMarketingUser__r == null)   {                     
                c.PrimaryMarketingUser__r =  new User (UserId__c = 'nuser');           
            }
            //Update overlap user with NUser in case of no overlap territory
            if (c.OverlapExternalUser__r == null)   {  
                c.OverlapExternalUser__r = new User (UserId__c = 'nuser');
            }
            if (c.FullServiceSalesUser__r == null)   {                     
                c.FullServiceSalesUser__r =  new User (UserId__c = 'nuser');           
            }*/
            system.debug('Hello:' + oldPrimTerr + ' | ' + c.PrimaryTerritory__c);
            system.debug('Hello:' + oldPrimReg + ' | ' + c.PrimaryRegion__c);
            system.debug('Hello:' + oldPrimTerrLookup + ' | ' + c.PrimaryTerritoryLookup__r.TerritoryName__c); 
            system.debug('Hello:' + oldPrimMktUser + ' | ' + c.PrimaryMarketingUser__r.UserId__c);            
            system.debug('Hello:' + oldOvlTerr + ' | ' + c.OverlapTerritory__c);
            system.debug('Hello:' + oldOvlExtUser + ' | ' + c.OverlapExternalUser__r.UserId__c);           
                        
            if (oldPrimTerr != c.PrimaryTerritory__c || oldPrimReg != c.PrimaryRegion__c ||
                oldPrimMktUser != c.PrimaryMarketingUser__r.UserId__c || oldPrimTerrLookup != c.PrimaryTerritoryLookup__r.TerritoryName__c ||  
                oldOvlTerr != c.OverlapTerritory__c || oldOvlExtUser != c.OverlapExternalUser__r.UserId__c ||
                oldFullSrvUser != c.FullServiceSalesUser__r.UserId__c) {
                                                      
                if (c.PrimaryMarketingUser__r.UserID__c == null) c.PrimaryMarketingUser__c = null;
                if (c.OverlapExternalUser__r.UserID__c == null) c.OverlapExternalUser__c = null;
                if (c.FullServiceSalesUser__r.UserId__c == null) c.FullServiceSalesUser__r = null;
                if (c.PrimaryTerritoryLookup__r.TerritoryName__c == null) c.PrimaryTerritoryLookup__c = null;
                contacts.add(c);
            }
        } 
              
        update contacts;
    } 
    
    private string getUserByContactZone(List<UserTerritory__c> userTerrs, string zone) {       
        for(UserTerritory__c userTerr: userTerrs) { 
                                                                  
            //Assign Marketing User based on contact territory zone    
            if (userTerr.Zoning__r.Name == zone) {
                /*if (userTerr.User__r.ZoneCoverage__r.UserId__c != null) {            
                    return userTerr.User__r.ZoneCoverage__r.UserId__c;
                } else {*/
                   return userTerr.User__r.UserId__c;                                  
                //}
            }                                               
        }
        return null;  
    } 
       
    global void finish(Database.BatchableContext BC){
            /*AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                 FROM AsyncApexJob WHERE Id = :BC.getJobId()];   
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'sireesha.meka@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('DAT');
            mail.setSubject('Contact primary territory updates for Marketing personalization has Completed');
            mail.setPlainTextBody('The Batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
            if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); */               
           
    }
}