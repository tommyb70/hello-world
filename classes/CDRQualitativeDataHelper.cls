public class CDRQualitativeDataHelper {
    
    public static String getCDRStatusQueryStatement(String additionalWhere, String selectScope) {
        // to use this method, you must have the variables 'asOfDate' and 'status' feeding your query in your own method
        // this method builds the standard query statement that will put the appropriate CDRQualitativeData__c records into a list where [0] is the record you should use
        // note that the query could return more than one row - always use [0]
        // parameters
        // 		additionalWhere = a statement that begins with ' WHERE ' and includes any additional criteria needed in the select statement
        // 		selectScope = All or Basic; All will return all fields; Basic or null returns only the fields in the String query init below
        // return
        // 		A full query statement for CDRQualitativeData__c that adhere to the status rules
        
        String query = 'SELECT RecordType.Name, AdditionalInfo__c, AdditionalInfo__r.RecordType.Name, AdditionalInfo__r.ShortName__c, '; 
        query = query + ' Product__c, Product__r.Name, Account__c, Account__r.Name, Contact__c, Contact__r.Name, ChildAccount__c, ';
        query = query + ' ChildAccount__r.Name, ChildProduct__c, ChildProduct__r.Name, Benchmark__c, Benchmark__r.Name ';
        
        if (selectScope == 'All') {
            
            Set<String> inBasic = new Set<String>{'additionalinfo__c', 'product__c', 'account__c', 'contact__c', 'childaccount__c', 'childproduct__c', 'benchmark__c'};
            
            Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('CDRQualitativeData__c').getDescribe().fields.getMap(); 
            
            query = query + ', ';
            
            for(String s : fields.keySet()) { 
                if (!inBasic.contains(s)) {
                 query += ' ' + s + ','; 
                }
            } 
            
            if (query.subString(query.Length()-1,query.Length()) == ','){ 
                query = query.subString(0,query.Length()-1); 
            } 
        }
        
        String addlWhereWork = (!String.isBlank(additionalWhere)) ? additionalWhere : ' WHERE 1 = 1 '; 
        system.debug(addlWhereWork);
        
        query = query + ' FROM CDRQualitativeData__c '; 
        query = query + addlWhereWork;        
        query = query + ' AND EffectiveDate__c <= :asOfDate ';
        query = query +  ' AND (   (Status__c = \'Historical\' AND HistoricalDate__c >= :asOfDate) ';
        query = query + '      OR (Status__c = \'Pending Activation\') ' ;        
        query = query + '      OR (Status__c = \'Active\' ';                
        query = query + '          AND (     (   (NextPendingActivationDate__c < :asOfDate AND HasPendingActivationRow__c = TRUE) ';
        query = query + '                     OR (HasPendingActivationRow__c = FALSE)) ';
        query = query + '                OR  (   (NextStagingDate__c > :asOfDate AND HasStagingRow__c = TRUE) ' ;            
        query = query + '                     OR (HasStagingRow__c = FALSE)) ';
        query = query + '              ))  ' ; 
        query = query + '      OR (Status__c = :status) ' ;                        
        query = query + '      ) ' ;             
        query = query + ' ORDER BY Status__c ' ;  
        
        return query;
    }
    
    public static Map<Id,List<CDRQualitativeData__c>> getCDRQualitativeDataMapByParentIds(String parentField, Set<Id> parentIds, String recTypeName, Date asOfDate, String status) {
        // parameters
        // 		parentField = one of the following field names: Account__c, AdditionalInfo__c, Product__c, ChildProduct__c, ChildAccount__c, Contact__c, Benchmark__c
        // 		parentIds = the set of parentIds that you want to return a list of CDRQualitativeData__c records for; for example a set of Product Ids
        // 		recTypeName = the RecordType.Name of the CDRQualitativeData__c records you want to return: Mutual Fund, ETF, Share Class, Benchmark, Firm-Child Firm, etc.
        // 		asOfDate = the as of date you want to use for your query (get me the CDRQualitativeData__c records that are/were effective on this date)
        // 		status = null or Staging only 
        // 			Staging will return the staging row effective on the asOfDate if one exists, otherwise it follows the rules for a null value
        // 			null will return the historical, pending activation, or active row for the asOfDate
        // return
        // 		Id of returned map is the parentId; note that if there is not a CDRQualtitativeData__c row for a parentId that meets the rest of the parms, 
        // 			the map will not have an Id for it, so be sure to check for containsKey() before getting
        // 		List<QualitativeData__c> returns the CDRQualitativeData__c rows where [0] is the right row; there may be more than one row in the List; always use [0]
        // 			All fields on CDRQualitativeData__c are in the select query plus those in the String query initialization below
        
        Map<Id,List<CDRQualitativeData__c>> rMap = new Map<Id,List<CDRQualitativeData__c>>(); 
        
        Id recTypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId(); 
        String query = getCDRStatusQueryStatement(' WHERE RecordTypeId = :recTypeId AND ' + parentField + ' IN :parentIds ','All');        
        
        for (CDRQualitativeData__c c : Database.query(query)) { 
            system.debug(parentField + ': ' + c);
            SWITCH ON parentField { 
                WHEN 'Product__c' { 
                    if (rMap.containsKey(c.Product__c)) { 
                        rMap.get(c.Product__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.Product__c,n); 
                    } 
                }                 
                WHEN 'AdditionalInfo__c' { 
                    if (rMap.containsKey(c.AdditionalInfo__c)) { 
                        rMap.get(c.AdditionalInfo__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.AdditionalInfo__c,n); 
                    } 
                } 
                WHEN 'Account__c' { 
                    if (rMap.containsKey(c.Account__c)) { 
                        rMap.get(c.Account__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.Account__c,n); 
                    } 
                } 
                WHEN 'Contact__c' { 
                    if (rMap.containsKey(c.Contact__c)) { 
                        rMap.get(c.Contact__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.Contact__c,n); 
                    } 
                } 
                WHEN 'Benchmark__c' { 
                    if (rMap.containsKey(c.Benchmark__c)) { 
                        rMap.get(c.Benchmark__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.Benchmark__c,n); 
                    } 
                } 
                WHEN 'ChildProduct__c' { 
                    if (rMap.containsKey(c.ChildProduct__c)) { 
                        rMap.get(c.ChildProduct__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.ChildProduct__c,n); 
                    } 
                }     
                WHEN 'ChildAccount__c' { 
                    if (rMap.containsKey(c.ChildAccount__c)) { 
                        rMap.get(c.ChildProduct__c).add(c); 
                    } else { 
                        List<CDRQualitativeData__c> n = new List<CDRQualitativeData__c>(); 
                        n.add(c); 
                        rMap.put(c.ChildAccount__c,n); 
                    } 
                }                     
            } 
        } 
        return rMap; 
    }
    
    public static List<CDRQualitativeData__c> getCDRQualitativeDataParent(Id id, Datetime asOfDttm, Boolean dispStaging) {
        
        Map<String,CDRQualitativeData__c> cdrMap = new Map<String,CDRQualitativeData__c>();
        
        String status = dispStaging ? 'Staging' : null;
        
        for (CDRQualitativeData__c s : [SELECT Id, Name, Status__c, RecordType.Name, EffectiveDate__c, HistoricalDate__c,
                                        Product__c, Product__r.Name, Account__c, Account__r.Name,
                                        Contact__c, Contact__r.Name, ChildProduct__c, ChildProduct__r.Name,
                                        Benchmark__c, Benchmark__r.Name,
                                        ChildAccount__c, ChildAccount__r.Name,
                                        AdditionalInfo__c, AdditionalInfo__r.Name
                                        FROM CDRQualitativeData__c
                                        WHERE EffectiveDate__c <= :asOfDttm
                                        AND (   (Status__c = 'Historical' AND HistoricalDate__c >= :asOfDttm)
                                             OR (Status__c = 'Pending Activation')        
                                             OR (Status__c = 'Active'                
                                                 AND (     (   (NextPendingActivationDate__c < :asOfDttm AND HasPendingActivationRow__c = TRUE)
                                                            OR (HasPendingActivationRow__c = FALSE))
                                                      OR  (   (NextStagingDate__c > :asOfDttm AND HasStagingRow__c = TRUE)          
                                                           OR (HasStagingRow__c = FALSE))
                                                     ))
                                             OR (Status__c = :status)                        
                                            )             
                                        AND (Product__c = :id
                                             OR Account__c = :id
                                             OR Contact__c = :id
                                             OR AdditionalInfo__c = :id
                                             OR Benchmark__c = :Id)
                                        ORDER BY Status__c, SortOrder__c, Name]) {
                                            
                                            system.debug('Name: ' + s.Name);
                                            
                                            if (s.RecordType.Name == 'Additional Info') cdrMap.put(s.AdditionalInfo__c,s);
                                            if (s.RecordType.Name == 'Benchmark') cdrMap.put(s.Benchmark__c,s);
                                            if (s.RecordType.Name == 'Benchmark-Additional Info') cdrMap.put((String)s.Benchmark__c + (String)s.AdditionalInfo__c,s);
                                            if (s.RecordType.Name == 'Contact') cdrMap.put(s.Contact__c,s);
                                            if (s.RecordType.Name == 'Contact-Additional Info') cdrMap.put((String)s.Contact__c + (String)s.AdditionalInfo__c,s);
                                            if (s.RecordType.Name == 'ETF' || s.RecordType.Name == 'Mutual Fund' || s.RecordType.Name == 'Share Class') cdrMap.put(s.Product__c,s);
                                            if (s.RecordType.Name == 'Firm') cdrMap.put(s.Account__c,s);
                                            if (s.RecordType.Name == 'Firm-Additional Info') cdrMap.put((String)s.Account__c + (String)s.AdditionalInfo__c,s);
                                            if (s.RecordType.Name == 'Firm-Child Firm') cdrMap.put((String)s.Account__c + (String)s.ChildAccount__c,s);
                                            if (s.RecordType.Name == 'Firm-Contact') cdrMap.put((String)s.Account__c + (String)s.Contact__c,s); 
                                            if (s.RecordType.Name == 'Firm-Product') cdrMap.put((String)s.Account__c + (String)s.Product__c,s);
                                            if (s.RecordType.Name == 'Product-Additional Info') cdrMap.put((String)s.Product__c + (String)s.AdditionalInfo__c,s);
                                            if (s.RecordType.Name == 'Product-Benchmark') cdrMap.put((String)s.Product__c + (String)s.Benchmark__c,s);
                                            if (s.RecordType.Name == 'Product-Child Product') cdrMap.put((String)s.Product__c + (String)s.ChildProduct__c,s);
                                            if (s.RecordType.Name == 'Product-Contact') cdrMap.put((String)s.Product__c + (String)s.Contact__c,s);
                                            
                                        }    
        
        return cdrMap.values();
    }
    
    public static List<CDRQualitativeData__c> getCDRQualitativeDataChild(Id id, Datetime asOfDttm, Boolean dispStaging) {
        
        Map<String,CDRQualitativeData__c> cdrMap = new Map<String,CDRQualitativeData__c>();
        
        String status = dispStaging ? 'Staging' : null;
        
        for (CDRQualitativeData__c s : [SELECT Id, Name, Status__c, RecordType.Name, EffectiveDate__c, HistoricalDate__c,
                                        Product__c, Product__r.Name, Account__c, Account__r.Name,
                                        Contact__c, Contact__r.Name, ChildProduct__c, ChildProduct__r.Name,
                                        Benchmark__c, Benchmark__r.Name,
                                        ChildAccount__c, ChildAccount__r.Name,
                                        AdditionalInfo__c, AdditionalInfo__r.Name
                                        FROM CDRQualitativeData__c
                                        WHERE EffectiveDate__c <= :asOfDttm
                                        AND (   (Status__c = 'Historical' AND HistoricalDate__c >= :asOfDttm)
                                             OR (Status__c = 'Pending Activation')        
                                             OR (Status__c = 'Active'                
                                                 AND (     (   (NextPendingActivationDate__c < :asOfDttm AND HasPendingActivationRow__c = TRUE)
                                                            OR (HasPendingActivationRow__c = FALSE))
                                                      OR  (   (NextStagingDate__c > :asOfDttm AND HasStagingRow__c = TRUE)          
                                                           OR (HasStagingRow__c = FALSE))
                                                     ))
                                             OR (Status__c = :status)                        
                                            )             
                                        AND (ChildProduct__c = :id
                                             OR ChildAccount__c = :id
                                             OR Benchmark__c = :id)
                                        ORDER BY Status__c, SortOrder__c, Name]) {
                                            
                                            if (s.RecordType.Name == 'Firm-Child Firm') cdrMap.put((String)s.Account__c + (String)s.ChildAccount__c,s);
                                            if (s.RecordType.Name == 'Product-Child Product') cdrMap.put((String)s.Product__c + (String)s.ChildProduct__c,s);
                                            if (s.RecordType.Name == 'Product-Benchmark') cdrMap.put((String)s.Product__c + (String)s.Benchmark__c,s);
                                            
                                        }    
        
        return cdrMap.values();
    }
    
    public static List<CDRQualitativeData__c> parseCDRListByRecordType(List<CDRQualitativeData__c> cdr, String recTypeName) {
        
        List<CDRQualitativeData__c> rCDR = new List<CDRQualitativeData__c>();
        
        for (CDRQualitativeData__c c : cdr) {
            if (c.RecordType.Name == recTypeName) rCDR.add(c);
            if (recTypeName == 'Product' && (c.RecordType.Name == 'ETF' || c.RecordType.Name == 'Mutual Fund' || c.RecordType.Name == 'Share Class')) rCDR.add(c);
        }
        
        return rCDR;
        
    }
    
}