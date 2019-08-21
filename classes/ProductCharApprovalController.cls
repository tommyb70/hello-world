public with sharing class ProductCharApprovalController {
    
    public List<SelectOption> typeSelections {get;set;}
    public List<SelectOption> productSelections {get;set;}
    public List<SelectOption> sourceSelections {get;set;}
    public String choiceProduct {get;set;}
    public String choiceType {get;set;}
    public String choiceSource {get;set;}
    public List<wrapProductCharacteristic> wrapProdCharList {get; set;}
    public Boolean anyToApprove {get;set;}
    
    public ProductCharApprovalController(){
        
        this.choiceProduct = 'All';        
        this.choiceType = 'All';
        this.choiceSource = 'All';
        String query = buildQuery();
        this.productSelections = getProductSelections(query);
        this.typeSelections = getTypeSelections(query);
        this.sourceSelections = getSourceSelections(query);
        
    }
    
    
    public List<wrapProductCharacteristic> getProductCharacteristics(String q) {
        
        anyToApprove = FALSE;
        
        List<wrapProductCharacteristic> pcList = new List<wrapProductCharacteristic>();
        
        for (ProductCharacteristic__c pc : Database.query(q)) {
            pcList.add(new wrapProductCharacteristic(pc));    
        }
        
        if (!pcList.isEmpty()) anyToApprove = TRUE;
        
        return pcList;
        
    }
    
    public class wrapProductCharacteristic {
        
        public ProductCharacteristic__c pc {get; set;}
        public Boolean selected {get; set;}
        
        public wrapProductCharacteristic(ProductCharacteristic__c pci) {
            pc = pci;
            selected = false;
        }
        
    }
    
    public PageReference approveSelected() {
        
        List<ProductCharacteristic__c> prodCharToApprove = new List<ProductCharacteristic__c>();
        String errorMessage;
        
        for (wrapProductCharacteristic appr : wrapProdCharList) {
            
            if (appr.selected) {
                appr.pc.Approved__c = TRUE;
                prodCharToApprove.add(appr.pc);
            }
        }
        
        update prodCharToApprove;

        choiceProduct = 'All';        
        choiceType = 'All';
        choiceSource = 'All';

        String query = buildQuery();
        
        sourceSelections = getSourceSelections(query);
        productSelections = getProductSelections(query);
        typeSelections = getTypeSelections(query);
        anyToApprove = FALSE;
        
        return null;                            
        
    }
        
    public List<SelectOption> getProductSelections(String q) {
        
        List<SelectOption> selOpts = new List<SelectOption>();
        Map<Id,String> prodSelMap = new Map<Id,String>();
        selOpts.add(new SelectOption('All','All'));
                
        for (ProductCharacteristic__c pp1 : Database.query(q)) {
            if (!String.isBlank(pp1.Product__r.LegalName__c)) {
                prodSelMap.put(pp1.Product__c,pp1.Product__r.LegalName__c);
            } else {
                prodSelMap.put(pp1.Product__c,pp1.Product__r.Name);
            }
        }
        
        for (Id pId : prodSelMap.keySet()) {
            selOpts.add(new SelectOption(pId, prodSelMap.get(pId)));
        }
        
        return selOpts;
    }       
    
    public List<SelectOption> getSourceSelections(String q) {
        
        List<SelectOption> selOpts = new List<SelectOption>();
        Set<String> inSource = new Set<String>();
//        Map<Id,String> sourceSelMap = new Map<Id,String>();
        selOpts.add(new SelectOption('All','All'));        
        Schema.DescribeFieldResult fieldResult = ProductCharacteristic__c.Source__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (ProductCharacteristic__c i : Database.query(q)) {
            inSource.add(i.Source__c);
        }
        
        for(Schema.PicklistEntry p : ple)
            if (inSource.contains(p.getValue())) selOpts.add(new SelectOption(p.getValue(), p.getValue()));        
        return selOpts;
        
    }           
    
    public List<SelectOption> getTypeSelections(String q) {
        List<SelectOption> selOpts = new List<SelectOption>();
        Set<String> inSource = new Set<String>();
        selOpts.add(new SelectOption('All','All'));        
        Schema.DescribeFieldResult fieldResult = ProductCharacteristic__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for (ProductCharacteristic__c i : Database.query(q)) {
            inSource.add(i.Type__c);
        }
        
        for(Schema.PicklistEntry p : ple)
            if (inSource.contains(p.getValue())) selOpts.add(new SelectOption(p.getValue(), p.getValue()));        
        return selOpts;
    }    
    
    public String buildQuery() {
        
        String q = ' SELECT Id, Name, Type__c, AsOfDate__c, Product__r.LegalName__c, Approved__c, PublishDate__c, Product__r.Name, ' +
            ' SecurityId__c, SecurityName__c, SecurityDescription__c, Rank__c, CouponRate__c, MaturityDate__c, PercentOfPortfolio__c, ' +
            ' Source__c, Level1__c, Level2__c, Level3__c, IndexCharacteristicsDecimal__c, IndexCharacteristicsText__c,  PercentContributionToVolatility__c, ' +
            ' PercentExposure__c, PercentOfIndex__c, ProductCharacteristicsDecimal__c, ProductCharacteristicsText__c ' +            
            ' FROM ProductCharacteristic__c ' +
            ' WHERE Approved__c = FALSE ';
        
        if (choiceProduct == 'All') {
            q = q + ' AND Product__c != null ';
        } else {
            q = q + ' AND Product__c =: choiceProduct ';
        }
        
        if (choiceType == 'All') {
            q = q + ' AND Type__c != null ';
        } else {
            q = q + ' AND Type__c =: choiceType ';
        }
        
        if (choiceSource == 'All') {
            q = q + ' AND Source__c != null ';
        } else {
            q = q + ' AND Source__c =: choiceSource ';
        }        
        
        q = q + ' ORDER BY Type__c, AsOfDate__c, Product__r.LegalName__c, SortOrder__c DESC LIMIT 1000';
        
        return q;
    }
    
    public String go() {
        String query = buildQuery();
        wrapProdCharList = getProductCharacteristics(query);
        
        if (wrapProdCharList.size() == 1000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'First 1,000 Rows Retrieved'));
            return null;
        } 
        return null;
    }

    public String selections() {
        
        String query = buildQuery();
        
        sourceSelections.clear();
        productSelections.clear();
        typeSelections.clear();
        
        sourceSelections = getSourceSelections(query);
        productSelections = getProductSelections(query);
        typeSelections = getTypeSelections(query);
        anyToApprove = FALSE;

        return null;
    }


    
}