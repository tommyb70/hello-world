/** 
* @author Pratibha Potluri 
* @Created Date: 08/30/2018 
* @description : controller class for BenchmarkPerformanceApproval vf page. 
**/ 

public class BenchmarkPerformanceApprovalController { 
    
    
    // Method to show benchMarkApproval Product Legal Names as Picklist Options 
    public PageReference BenchmarkSelections() { 
        String query = buildQuery(); 
        benchMarkSelections.clear(); 
        benchMarkSelections = getBenchmarkSelections(query); 
        anyToApprove = FALSE; 
        
        return null; 
    } 
    
    // Method to show asOfDates as Picklist Options 
    public PageReference asOfDateSelections() { 
        String query = buildQuery(); 
        asOfDates.clear(); 
        asOfDates = getasOfDates(query); 
        anyToApprove = FALSE; 
        
        return null; 
    } 
    
    // Method to Frame benchMarkApproval asOfDates as Picklist Options by Quering Benchmark Performance Records 
    public List<SelectOption> getasOfDates(String q) { 
        
        List<SelectOption> selOpts = new List<SelectOption>(); 
        selOpts.add(new SelectOption('All','All')); 
        set<string> duplicateDates = new set<string>(); 
        
        for (BenchmarkPerformanceApproval__c pp1 : Database.query(q)) { 
            if (pp1.asOfDate__c != null /*&& lastDateofMonth(pp1.asOfDate__c)*/) { 
                string asOfDate = string.valueof(pp1.asOfDate__c); 
                //string asOfDateLabel = Util.formatDateyyyyMMdd(pp1.asOfDate__c);
                string asOfDateLabel = pp1.asOfDate__c.format();
                if(!duplicateDates.contains(asOfDate)){ 
                    selOpts.add(new SelectOption(asOfDate,asOfDateLabel)); 
                    duplicateDates.add(asOfDate); 
                } 
            } 
        } 
        return selOpts; 
    } 
    
    // Method to Frame benchMarkApproval Product Legal Names as Picklist Options by Quering Benchmark Performance Records 
    public List<SelectOption> getBenchmarkSelections(String q) { 
        
        List<SelectOption> selOpts = new List<SelectOption>(); 
        Map<Id,String> prodSelMap = new Map<Id,String>(); 
        selOpts.add(new SelectOption('All','All')); 
        
        for (BenchmarkPerformanceApproval__c pp1 : Database.query(q)) { 
            if (!String.isBlank(pp1.Benchmark__r.LegalName__c) && pp1.asOfDate__c != null /*&& lastDateofMonth(pp1.asOfDate__c)*/) { 
                prodSelMap.put(pp1.Benchmark__c,pp1.Benchmark__r.LegalName__c); 
            } 
        } 
        for (Id pId : prodSelMap.keySet()) { 
            selOpts.add(new SelectOption(pId, prodSelMap.get(pId))); 
        } 
        return selOpts; 
    } 
    
    public BenchmarkPerformanceApproval__c BPA{get;set;} 
    public List<SelectOption> benchMarkSelections {get;set;} // SelectOption to hold LegalNames as Picklist 
    public string benchMarkSelection {get;set;} // string to hold the selected legal name 
    public List<SelectOption> asOfDates {get;set;} // select option List to hold asOfDates as Picklist 
    public string selectedDate{get;set;} // String to hold the selected asOfDate 
    public boolean anyToApprove { get; set; } // boolean variable to show the list of rows or not 
    public Date AsofDate{get;set;} 
    
    
    // Method which process the selected benchMarkApproval records to Approve ( update Approved field to true) 
    public PageReference approveSelected() {  
        
        List<BenchmarkPerformanceApproval__c> benchmarkApprovalsToApprove = new List<BenchmarkPerformanceApproval__c>(); 
        
        String errorMessage; 
        
        for (wrapBenchmarkPerformance appr : wrapBencPerfList) { 
            if (appr.selected) { 
                appr.bp.Approved__c = TRUE; 
                benchmarkApprovalsToApprove.add(appr.bp); 
            } 
        } 
        
        if(!benchmarkApprovalsToApprove.IsEmpty()){ 
            try{ 
                staticBooleanVariables.benchmarkPerformanceError = true;
                update benchmarkApprovalsToApprove; 
            }Catch(Exception e){ 
                
                if(e.getMessage().contains('No Product Performance Record found')){ 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No Product Performance Record found')); 
                    return null; 
                }else{ 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage())); 
                    return null; 
                } 
            } 
        } 
        
        String query = buildQuery(); 
        go(); 
        return null; 
    } 
    
    // Medthod to Query the benchMarkApproval records based on the picklist selections of legal name and asOfDate 
    public PageReference go() { 
        
        AsofDate = BPA.AsofDate__c; 
        String query = buildQuery(); 
        wrapBencPerfList = getbenchmarkPerformances(query); 
        
        if (wrapBencPerfList.size() == 1000){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'First 1,000 Rows Retrieved')); 
            return null; 
        } 
        return null; 
    } 
    
    public List<wrapBenchmarkPerformance> wrapBencPerfList{get; set;} // List of Wrapper class 
    
    //Constructor to Intialist all the varibales defined 
    public BenchmarkPerformanceApprovalController(){ 
        
        wrapBencPerfList = new List<wrapBenchmarkPerformance>(); 
        BPA = new BenchmarkPerformanceApproval__c(); 
        BPA.AsOfDate__c = system.today(); 
        this.benchMarkSelection = 'All'; 
        benchMarkSelections = new List<SelectOption>(); 
        asOfDates = new List<SelectOption>(); 
        String query = buildQuery(); 
        
        benchMarkSelections.clear(); 
        asOfDates.clear(); 
        
        benchMarkSelections = getBenchmarkSelections(query); 
        asOfDates = getasOfDates(query); 
        anyToApprove = FALSE; 
    } 
    
    // Method to Query and frame Wrapper Class list data to show on UI 
    public List<wrapBenchmarkPerformance> getbenchmarkPerformances(String q) { 
        anyToApprove = FALSE; 
        List<wrapBenchmarkPerformance> pcList = new List<wrapBenchmarkPerformance>(); 
        
        List<BenchmarkPerformanceApproval__c> lstBPARecords = new List<BenchmarkPerformanceApproval__c>();
        lstBPARecords = Database.query(q);
        
        set<Id> benchmarkIds = new set<Id>();
        set<Date> inceptionDates = new set<Date>();
        
        for (BenchmarkPerformanceApproval__c pcb : lstBPARecords) { 
            
            if(pcb.Benchmark__c != null){benchmarkIds.add(pcb.Benchmark__c);}
            if(pcb.InceptionDate__c != null){inceptionDates.add(pcb.InceptionDate__c);}
        }
        
        List<product2> lstchildBenchMarks = new List<product2>();
        system.debug('benchmarkIds===='+benchmarkIds);
        system.debug('inceptionDates===='+inceptionDates);
        if(!benchmarkIds.IsEmpty()){
            
            lstchildBenchMarks = [select id,InceptionDate__c,ParentProduct__r.PrimaryBenchmark__c, ParentProduct__r.SecondaryBenchmark__c, ParentProduct__r.TertiaryBenchmark__c,
                                  ShareClass__c, TradingSymbol__c, LegalNamewithTicker__c 
                                  from product2 where (ParentProduct__r.PrimaryBenchmark__c  In:benchmarkIds or 
                                                       ParentProduct__r.SecondaryBenchmark__c In:benchmarkIds or ParentProduct__r.TertiaryBenchmark__c In:benchmarkIds)
                                  and InceptionDate__c In:inceptionDates and InceptionDate__c != null 
                                  ORDER BY LegalNamewithTicker__c]; 
            
        }
        
        system.debug('lstchildBenchMarks ==='+lstchildBenchMarks );
        for (BenchmarkPerformanceApproval__c pc : lstBPARecords) { 
            
            pc.Tickers__c = null;
            
            for(product2 prodRecords:lstchildBenchMarks){
                
                system.debug('prodRecords.InceptionDate__c ==='+prodRecords.InceptionDate__c );
                system.debug('pc.InceptionDate__c ==='+pc.InceptionDate__c );
                system.debug('prodRecords.ParentProduct__c ==='+prodRecords.ParentProduct__c );
                system.debug('pc.Benchmark__r.PrimaryBenchmark__c ==='+pc.Benchmark__r.PrimaryBenchmark__c );
                
                if(prodRecords.InceptionDate__c == pc.InceptionDate__c) { 
                    if (prodRecords.ParentProduct__r.PrimaryBenchmark__c == pc.Benchmark__c) {
                        
                        if( pc.Tickers__c == null){
                            pc.Tickers__c = prodRecords.LegalNamewithTicker__c + ' (Primary)' + '\r\n';
                        } else {
                            pc.Tickers__c = pc.Tickers__c + prodRecords.LegalNamewithTicker__c + ' (Primary)' + '\r\n';
                        }
                        
                    } 
                    
                    if (prodRecords.ParentProduct__r.SecondaryBenchmark__c == pc.Benchmark__c) {
                        
                        if( pc.Tickers__c == null){
                            pc.Tickers__c = prodRecords.LegalNamewithTicker__c + ' (Secondary)' + '\r\n';
                        } else {
                            pc.Tickers__c = pc.Tickers__c + prodRecords.LegalNamewithTicker__c + ' (Secondary)' + '\r\n';
                        }
                        
                    } 
                    
                    if (prodRecords.ParentProduct__r.TertiaryBenchmark__c == pc.Benchmark__c) {
                        
                        if( pc.Tickers__c == null){
                            pc.Tickers__c = prodRecords.LegalNamewithTicker__c + ' (Tertiary)' + '\r\n';
                        } else {
                            pc.Tickers__c = pc.Tickers__c + prodRecords.LegalNamewithTicker__c + ' (Tertiary)' + '\r\n';
                        }
                        
                    } 
                    
                }
            }
            
            system.debug('pc.Tickers__c ==='+pc.Tickers__c );
            
            pcList.add(new wrapBenchmarkPerformance(pc)); 
        } 
        
        if (!pcList.isEmpty()) anyToApprove = TRUE; 
        return pcList; 
    } 
    
    
    //Wrapper class 
    public class wrapBenchmarkPerformance { 
        public BenchmarkPerformanceApproval__c bp {get; set;} 
        public Boolean selected {get; set;} 
        public wrapBenchmarkPerformance(BenchmarkPerformanceApproval__c bpi) { 
            bp = bpi; 
            selected = false; 
        } 
    } 
    
    // Method to query the benchMarkApproval records 
    public String buildQuery() { 
        
        String q = ' SELECT Id, Name, X10Year__c, X1DayGross__c, Benchmark__r.PrimaryBenchmark__c,X1DayNet__c, X1DayPriceChange__c, X1Month__c, X1Year__c,QTD__c,SinceInception__c,TotalGross__c, ' + 
            'X3Month__c,X3Year__c,X5Year__c,Approved__c,AsOfDate__c,Benchmark__c,Benchmark__r.LegalName__c,Tickers__c,ExternalID__c,InceptionDate__c,MTD__c,Price__c,TotalNet__c,YTD__c ' + 
            ',Benchmark__r.SecondaryBenchmark__c,Benchmark__r.TertiaryBenchmark__c FROM BenchmarkPerformanceApproval__c ' + 
            ' WHERE Approved__c = FALSE '; 
        
        if (benchMarkSelection == 'All') { 
            q = q + ' AND Benchmark__c != null '; 
        } else { 
            q = q + ' AND Benchmark__c=: benchMarkSelection'; 
        } 
        
        if(selectedDate != null && selectedDate != '' && selectedDate != 'All') { 
            AsofDate = Date.valueof(selectedDate); 
            q = q + ' AND AsOfDate__c =: AsofDate '; 
        } 
        q = q + ' ORDER BY Benchmark__r.LegalName__c,AsOfDate__c DESC LIMIT 1000'; 
        return q; 
    } 
    
    // Method to check asOfDate is the lastday of the month or not 
    /* public boolean lastDateofMonth(Date currentDate){ 

boolean lastDate = false; 
Integer numberOfDays = Date.daysInMonth(currentDate.year(), currentDate.month()); 
Date lastDayOfMonth = Date.newInstance(currentDate.year(), currentDate.month(), numberOfDays); 

if(currentDate == lastDayOfMonth){ 
lastDate = true; 
} 
return lastDate; 
} */
}