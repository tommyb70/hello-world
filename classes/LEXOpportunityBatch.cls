global class LEXOpportunityBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String query;
    
    global Database.querylocator start(Database.BatchableContext BC){   
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) { 
        
        system.debug('scope: ' + scope);
        
        Map<String,String> recTypeNamePricebookNameMap = new Map<String,String>();
        Map<String,Id> pricebookNameIdMap = new Map<String,Id>();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        List<PricebookEntry> PBEToInsert = new List<PricebookEntry>();
        List<PricebookEntry> standardPBEToInsert = new List<PricebookEntry>();
        List<OpportunityLineItem> OLIToInsert = new List<OpportunityLineItem>();
        List<OpportunityContactRole> OCRToInsert = new List<OpportunityContactRole>();
        Map<Id,List<String>> opptyFunding = new Map<Id,List<String>>();
        Map<Id,List<String>> opptyFee = new Map<Id,List<String>>();
        
        for (Funding__c f : [SELECT Opportunity__c, EstimatedFundDate__c, FundingValue__c, Type__c 
                             FROM Funding__c
                             WHERE Opportunity__c IN :scope
                             ORDER BY Opportunity__c, EstimatedFundDate__c]) {
                                 if (opptyFunding.containsKey(f.Opportunity__c)) {
                                     List<String> t = opptyFunding.get(f.Opportunity__c);
                                     List<String> args = new String[]{'0','number','###,###,##0'};
                                         String fv = f.FundingValue__c != null ? '$' + String.format(f.FundingValue__c.format(), args) : 'X';
                                     String funding = f.EstimatedFundDate__c != null ? f.EstimatedFundDate__c.format() + ': ' + fv : null;
                                     t.add(funding);
                                     opptyFunding.put(f.Opportunity__c,t);
                                 } else {
                                     List<String> t = new List<String>();
                                     List<String> args = new String[]{'0','number','###,###,##0'};
                                         String fv = f.FundingValue__c != null ? '$' + String.format(f.FundingValue__c.format(), args) : 'X';
                                     String funding = f.EstimatedFundDate__c != null ? f.EstimatedFundDate__c.format() + ': ' + fv : null;
                                     t.add(funding);
                                     opptyFunding.put(f.Opportunity__c,t);
                                 }
                             }
        
        for (FeeStructure__c fs : [SELECT Opportunity__c, Bps__c, RangeFrom__c, RangeTo__c 
                                   FROM FeeStructure__c
                                   WHERE Opportunity__c IN :scope
                                   ORDER BY Opportunity__c, RangeFrom__c]) {
                                       if (opptyFee.containsKey(fs.Opportunity__c)) {
                                           List<String> t = opptyFee.get(fs.Opportunity__c);
                                           List<String> args = new String[]{'0','number','###,###,##0'};
                                               String fsf = fs.RangeFrom__c != null ? '$' + String.format(fs.RangeFrom__c.format(), args) : 'X';
                                           String fst = fs.RangeTo__c != null ? '$' + String.format(fs.RangeTo__c.format(), args) : 'X';
                                           String fees = fsf + ' to ' + fst + ': ' + fs.Bps__c;
                                           t.add(fees);
                                           opptyFee.put(fs.Opportunity__c,t);
                                       } else {
                                           List<String> t = new List<String>();
                                           List<String> args = new String[]{'0','number','###,###,##0'};
                                               String fsf = fs.RangeFrom__c != null ? '$' + String.format(fs.RangeFrom__c.format(), args) : 'X';
                                           String fst = fs.RangeTo__c != null ? '$' + String.format(fs.RangeTo__c.format(), args) : 'X';
                                           String fees = fsf + ' to ' + fst + ': ' + fs.Bps__c;
                                           t.add(fees);
                                           opptyFee.put(fs.Opportunity__c,t);
                                       }
                                   }
        
        
        
        for (Pricebook2 pb : [SELECT Name, Id FROM Pricebook2]) {
            pricebookNameIdMap.put(pb.Name, pb.Id); 
        }
        
        // map all oppty record types to pricebook names
        recTypeNamePricebookNameMap.put('AIA','AIA');
        recTypeNamePricebookNameMap.put('Empower Leads','Retail');
        recTypeNamePricebookNameMap.put('InstSubAdv','Institutional');
        recTypeNamePricebookNameMap.put('Manually Created','Retail');
        recTypeNamePricebookNameMap.put('Standard','Retail');
        recTypeNamePricebookNameMap.put('NSFF','NSFF');
        recTypeNamePricebookNameMap.put('Sales PRCG CPE Request','Retail');
        
        Map<String,Id> pricebook2Product2ProductEntryIdMap = new Map<String,Id>();
        for (PricebookEntry pbe : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry]) {
            pricebook2Product2ProductEntryIdMap.put((String)pbe.Pricebook2Id + (String)pbe.Product2Id, pbe.Id); 
        }
        
        Id standardPricebookId = pricebookNameIdMap.get('Standard Price Book');
        
        Map<String,PriceBookEntry> productCMapStandard = new Map<String,PriceBookEntry>();
        Map<String,PriceBookEntry> productCMap = new Map<String,PriceBookEntry>();
        
        for (Opportunity o : scope) {
            if (o.Product__c != null && !pricebook2Product2ProductEntryIdMap.containsKey((String)standardPricebookId + (String)o.Product__c)) {
                productCMapStandard.put((String)standardPricebookId + (String)o.Product__c,new PriceBookEntry(Pricebook2Id = standardPricebookId, Product2Id = o.Product__c, UnitPrice = 0, IsActive = TRUE));
            }
        }
        insert productCMapStandard.values();
        
        for (Opportunity o : scope) {
            
            String pricebook2Name = recTypeNamePricebookNameMap.get(o.RecordType.Name);
            Id pricebookId = pricebookNameIdMap.get(pricebook2Name);
            
            o.Pricebook2Id = o.HasOpportunityLineItem == FALSE ? pricebookId : o.Pricebook2Id;
            
            if (o.Product__c != null && !pricebook2Product2ProductEntryIdMap.containsKey((String)pricebookId + (String)o.Product__c)) {
                productCMap.put((String)pricebookId + (String)o.Product__c,new PriceBookEntry(Pricebook2Id = pricebookId, Product2Id = o.Product__c, UnitPrice = 0, IsActive = TRUE));
            }
        }
        insert productCMap.values();
        update scope;
        
        for (PricebookEntry pbe : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry]) {
            pricebook2Product2ProductEntryIdMap.put((String)pbe.Pricebook2Id + (String)pbe.Product2Id, pbe.Id); 
        }
        
        Map<Id,Id> OpptyLineItemMap = new Map<Id,Id>();
        
        for (OpportunityLineItem oli : [SELECT Id, OpportunityId, PricebookEntryId 
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId IN :scope]) {
                                            OpptyLineItemMap.put(oli.OpportunityId, oli.PricebookEntryId);
                                        }

        Map<Id,Set<Id>> OpptyContactRoleMap = new Map<Id,Set<Id>>();

        for (OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId 
                                        	FROM OpportunityContactRole
                                        	WHERE OpportunityId IN :scope]) {
                                                if (opptyContactRoleMap.containsKey(ocr.OpportunityId)) {
                                                    Set<Id> t = OpptyContactRoleMap.get(ocr.OpportunityId);
                                                    t.add(ocr.ContactId);
                                                    opptyContactRoleMap.put(ocr.OpportunityId, t);
                                                } else {
                                                    Set<Id> t = new Set<Id>();
                                                    t.add(ocr.ContactId);
                                                    opptyContactRoleMap.put(ocr.OpportunityId, t);
                                                }
                                                
                                        }
                                       
        for (Opportunity o : scope) {
            String pricebook2Name = recTypeNamePricebookNameMap.get(o.RecordType.Name);
            system.debug(pricebook2Name);
            Id pricebookId = pricebookNameIdMap.get(pricebook2Name);
            Id pricebookEntryId = pricebook2Product2ProductEntryIdMap.get((String)pricebookId + (String)o.Product__c);
            system.debug(pricebookEntryId);
            List<String> oliFundingList = opptyFunding.containsKey(o.Id) ? opptyFunding.get(o.Id) : new List<String>();
            String oliFunding = oliFundingList.isEmpty() ? null : String.join(oliFundingList,';  \n');
            List<String> oliFeesList = opptyFee.containsKey(o.Id) ? opptyFee.get(o.Id) : new List<String>();
            String oliFees = oliFeesList.isEmpty() ? null : String.join(oliFeesList,';  \n');
            
            if (o.Product__c != null && !OpptyLineItemMap.containsKey(o.Id)) {
                OLIToInsert.add(new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pricebookEntryId, 
                                                        UnitPrice = o.Amount, Funding__c = oliFunding, FeeStructure__c = oliFees)); 
            }
            if (o.RepContact__c != null && !OpptyContactRoleMap.get(o.Id).contains(o.RepContact__c)) {
                OCRToInsert.add(new OpportunityContactRole(OpportunityId = o.Id, ContactId = o.RepContact__c, IsPrimary = TRUE, Role = 'Unknown'));
            }
        }
        
        insert OLIToInsert;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}