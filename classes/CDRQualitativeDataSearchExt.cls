public class CDRQualitativeDataSearchExt {

    public boolean showData {get;set;}    
    public string query{get;set;}   
    
    /** Variables defined to show the status as multi picklist**/
    
    public Set<String> statusoriginalvalues{get;set;}
    Public List<string> statusLeftSelected{get;set;}
    Public List<string> statusRightSelected{get;set;}
    Public Set<string> statusLeftvalues{get;set;}
    Public Set<string> statusRightvalues{get;set;}
    
    /** Method fires when recordtype changes and will query the respective fields based on recordtype
    and show as picklist on UI **/
    
    public void recordStatusChange() {
        showData = false;
        LstCDRData = new List<CDRQualitativeData__c>();
        if(CDRData.RecordtypeId != null){
            Recordtype rt = [select id,name from Recordtype where Id=:CDRData.RecordtypeId limit 1];
            recordtypeName = rt.name;
            AdditionalInfoOptions = new list<selectoption>();
            benchmarkOptions = new list<selectoption>();
            contactOptions = new list<selectoption>();
            firmOptions = new list<selectoption>();
            ChildAccountOptions = new list<selectoption>();
            productOptions = new list<selectoption>();
            ChildProductOptions = new list<selectoption>();
            
            AdditionalInfoIds = new set<Id>();
            benchmarkIds = new set<Id>();
            contactIds = new set<Id>();
            firmIds = new set<Id>();
            ChildAccountIds = new set<Id>();
            productIds = new set<Id>();
            ChildProductIds = new set<Id>();
            
            AdditionalInfoOptions.add(new selectoption('All','All'));
            benchmarkOptions.add(new selectoption('All','All'));
            contactOptions.add(new selectoption('All','All'));
            firmOptions.add(new selectoption('All','All'));
            ChildAccountOptions.add(new selectoption('All','All'));
            productOptions.add(new selectoption('All','All'));
            ChildProductOptions.add(new selectoption('All','All'));
            
            
            set<Id> dupIds = new set<Id>();
          
            for(CDRQualitativeData__c cdr:[select id,name,Product__c,Account__c,
                                                  Contact__c,AdditionalInfo__c,ChildAccount__c,
                                                  Benchmark__c,ChildProduct__c,Product__r.Name,
                                                  Account__r.Name,Contact__r.Name,AdditionalInfo__r.Name,
                                                  ChildAccount__r.Name,Benchmark__r.Name,
                                                  ChildProduct__r.Name from  CDRQualitativeData__c 
                                                  where RecordtypeId =:CDRData.RecordtypeId]){                                           
            
                if((recordtypeName  == 'Additional Info' || recordtypeName  == 'Benchmark-Additional Info' || recordtypeName  == 'Contact-Additonal Info'
                    || recordtypeName  == 'Firm-Additional Info' || recordtypeName == 'Product-Additional Info') && !dupIds.contains(cdr.AdditionalInfo__c)){
                    dupIds.add(cdr.AdditionalInfo__c);
                    AdditionalInfoOptions.add(new selectoption(cdr.AdditionalInfo__c,cdr.AdditionalInfo__r.Name));
                    AdditionalInfoIds.add(cdr.AdditionalInfo__c);
                }
                
                if((recordtypeName  == 'Benchmark' || recordtypeName  == 'Benchmark-Additional Info' || recordtypeName == 'Product-Benchmark' ) 
                    && !dupIds.contains(cdr.Benchmark__c)){
                    dupIds.add(cdr.Benchmark__c);
                    benchmarkOptions.add(new selectoption(cdr.Benchmark__c,cdr.Benchmark__r.Name));
                    benchmarkIds.add(cdr.Benchmark__c);
                }
                
                if((recordtypeName  == 'Contact' || recordtypeName  == 'Contact-Additonal Info' || recordtypeName == 'Firm-Contact'
                    || recordtypeName == 'Product-Contact') && !dupIds.contains(cdr.Contact__c)){
                    dupIds.add(cdr.Contact__c);
                    contactOptions.add(new selectoption(cdr.Contact__c,cdr.Contact__r.Name));
                    contactIds.add(cdr.Contact__c);
                }
                
                if((recordtypeName  == 'Firm'  || recordtypeName  == 'Firm-Additional Info' || recordtypeName == 'Firm-Contact' 
                    || recordtypeName == 'Firm-Product' || recordtypeName  == 'Firm-Child Firm') && !dupIds.contains(cdr.Account__c)){
                    dupIds.add(cdr.Account__c);
                    firmOptions.add(new selectoption(cdr.Account__c,cdr.Account__r.Name));
                    firmIds.add(cdr.Account__c);
                }
                
                if(recordtypeName  == 'Firm-Child Firm' && !dupIds.contains(cdr.ChildAccount__c)){
                   dupIds.add(cdr.ChildAccount__c);
                   ChildAccountOptions.add(new selectoption(cdr.ChildAccount__c,cdr.ChildAccount__r.Name));
                   ChildAccountIds.add(cdr.ChildAccount__c);
                }
                
                if((recordtypeName  == 'Firm-Product' ||  recordtypeName == 'Mutual Fund' || recordtypeName == 'Product-Additional Info' ||
                    recordtypeName == 'Product-Benchmark' || recordtypeName  == 'Product-Child Product' || recordtypeName == 'Product-Contact' ||
                    recordtypeName == 'Share Class' || recordtypeName  == 'ETF') && !dupIds.contains(cdr.Product__c)){
                    dupIds.add(cdr.Product__c);
                    productOptions.add(new selectoption(cdr.Product__c,cdr.Product__r.Name));
                    ProductIds.add(cdr.Product__c);
                }
                
                if(recordtypeName  == 'Product-Child Product' && !dupIds.contains(cdr.ChildProduct__c)){
                    dupIds.add(cdr.ChildProduct__c);
                    ChildProductOptions.add(new selectoption(cdr.ChildProduct__c,cdr.ChildProduct__r.Name));
                    ChildProductIds.add(cdr.ChildProduct__c);
                }            
            }        
        }
    }
    
    /** Method to search CDR Data based on the selection of Recordtype ,status, and respective fields based on Recordtype selection **/
    
    public Void Search() {
        
        if(recordtypeName == null || recordtypeName  == ''){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Recordtype'));
        }else{ 
            LstCDRData = new List<CDRQualitativeData__c>();            
            query = 'select id,name from CDRQualitativeData__c WHERE Status__c != null ';
            if(!StatusRightvalues.IsEmpty()){
                Integer i = 0;
                query = query + ' AND (';
                for(string status:StatusRightvalues){
                    if(i == 0){query = query + ' status__c = \''+status+'\'';}
                    if(i !=0){query = query + ' OR status__c = \''+status+'\'';}
                    i++;
                }
                query = query +')';
            }
            if(recordtypeName != null ){
               query = query + ' And Recordtype.Name = \''+recordtypeName+'\'';
            }
            
            if((recordtypeName  == 'Additional Info' || recordtypeName  == 'Benchmark-Additional Info' || recordtypeName  == 'Contact-Additonal Info'
                || recordtypeName  == 'Firm-Additional Info' || recordtypeName == 'Product-Additional Info') && AdditionalInfoOptionsSelection != null ){
                string filterQuery = AdditionalInfoOptionsSelection != 'All' ? ' And AdditionalInfo__c = \''+AdditionalInfoOptionsSelection+'\'' : ' And AdditionalInfo__c IN: AdditionalInfoIds';
                query = query + filterQuery;
            }
                   
            if((recordtypeName  == 'Benchmark' || recordtypeName  == 'Benchmark-Additional Info' || recordtypeName == 'Product-Benchmark' ) && BenchmarkOptionsSelection != null ){
                string filterQuery =  BenchmarkOptionsSelection != 'All' ? ' And Benchmark__c  = \''+BenchmarkOptionsSelection+'\'' : ' And Benchmark__c In:BenchmarkIds';
                query = query + filterQuery;
            }
                   
            if((recordtypeName  == 'Contact' || recordtypeName  == 'Contact-Additonal Info' || recordtypeName == 'Firm-Contact'
                || recordtypeName == 'Product-Contact') && contactOptionsSelection != null){
                string filterQuery = contactOptionsSelection  != 'All' ? ' And Contact__c = \''+contactOptionsSelection+'\'' : ' And Contact__c In:contactIds'; 
                query = query + filterQuery ;
            }
            
            if((recordtypeName  == 'Firm'  || recordtypeName  == 'Firm-Additional Info' || recordtypeName == 'Firm-Contact' || recordtypeName == 'Firm-Product'
                || recordtypeName  == 'Firm-Child Firm') && firmOptionsSelection != null){
                string filterQuery = firmOptionsSelection  != 'All' ? ' And Account__c = \''+firmOptionsSelection+'\'' : ' AND Account__c In:firmIds';
                query = query + filterQuery ; 
            }
            
            if(recordtypeName  == 'Firm-Child Firm' && ChildAccountOptionsSelection != null){
               string filterQuery = ChildAccountOptionsSelection  != 'All' ? ' And ChildAccount__c = \''+ChildAccountOptionsSelection+'\'' : ' And ChildAccount__c In:ChildAccountIds';
               query = query + filterQuery ; 
            }
            
            if((recordtypeName  == 'Firm-Product' ||  recordtypeName == 'Mutual Fund' || recordtypeName == 'Product-Additional Info' ||
                recordtypeName == 'Product-Benchmark' || recordtypeName  == 'Product-Child Product' || recordtypeName == 'Product-Contact' ||
                recordtypeName == 'Share Class' || recordtypeName  == 'ETF') && productOptionsSelection != null){
                string filterQuery = productOptionsSelection != 'All' ? ' And product__c = \''+productOptionsSelection+'\'' : ' ANd Product__c In:productIds';
                query = query + filterQuery ;
            }
            
            if(recordtypeName  == 'Product-Child Product' && ChildProductOptionsSelection != null){
               string filterQuery = ChildProductOptionsSelection  != 'All' ? ' And ChildProduct__c = \''+ChildProductOptionsSelection+'\'' : ' And ChildProduct__c In:ChildProductIds';
               query = query + filterQuery ; 
            }  
            system.debug('query ==='+query );
            LstCDRData = Database.Query(query); 
            showData = false;
            if(!lstCDRData.IsEmpty()){ showData = true;}
        }
    }
    
    /** variabled defined to store recordtype related fields info **/       
    public list<selectoption> productOptions{get;set;}
    public string productOptionsSelection{get;set;} 
    
    public list<selectoption> firmOptions{get;set;}
    public string firmOptionsSelection{get;set;} 
    
    public list<selectoption> AdditionalInfoOptions{get;set;}
    public string AdditionalInfoOptionsSelection{get;set;} 
    
    public list<selectoption> benchmarkOptions{get;set;}
    public string benchmarkOptionsSelection{get;set;}
    
    public list<selectoption> ContactOptions{get;set;}
    public string ContactOptionsSelection{get;set;}
    
    public list<selectoption> ChildAccountOptions{get;set;}
    public string ChildAccountOptionsSelection{get;set;}
    
    public list<selectoption> ChildProductOptions{get;set;}
    public string ChildProductOptionsSelection{get;set;}
    
    public CDRQualitativeData__c CDRData{get;set;}
    public List<CDRQualitativeData__c> LstCDRData{get;set;}
    public list<selectoption> recordtypeValues{get;set;}
    public string recordtypeName{get;set;}
    
    public set<Id> AdditionalInfoIds{get;set;}
    public set<Id> benchmarkIds{get;set;}
    public set<Id> contactIds{get;set;}
    public set<Id> firmIds{get;set;}
    public set<Id> ChildAccountIds{get;set;}
    public set<Id> productIds{get;set;}
    public set<Id> ChildProductIds{get;set;}
            
    public CDRQualitativeDataSearchExt(){
        showData = false;
        CDRData = new CDRQualitativeData__c();
        LstCDRData = new List<CDRQualitativeData__c>();
        recordtypeValues = new list<selectoption>();
        recordtypeValues.add(new selectoption('','-None-'));
        
        /** Query to show recordtypes of CDR to show as Picklist **/
        for(Recordtype rt:[select id,name from recordtype where SobjectType =:'CDRQualitativeData__c']){
            recordtypeValues.add(new selectoption(rt.Id,rt.Name));
        }
         
        statusoriginalvalues = new Set<String>();
        
        /** Getting CDR Status picklist values to show as multi select picklist **/
        
        schema.DescribeFieldResult fd = CDRQualitativeData__c.Status__c.getdescribe();
        list<schema.picklistentry> pc = fd.getpicklistvalues();
        for(schema.picklistentry f: pc){
            statusoriginalvalues.add(f.getvalue());
        }
        
        statusLeftSelected = new List<string>();
        statusRightSelected = new List<string>();
        statusLeftvalues = new Set<String>();
        statusRightvalues = new Set<String>();
        
        statusLeftvalues.addAll(statusoriginalValues);
        
        recordStatusChange();
    }
    
    /** Method to define the unselected status values **/
    public List<SelectOption> getStatusunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(StatusLeftvalues);
        tempList.sort();
        for(string s : tempList)
        options.add(new SelectOption(s,s));
        return options;
    }
    
     /** Method to define the selected status values **/
    public List<SelectOption> getStatusSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(StatusRightvalues);
        tempList.sort();
        for(String s : tempList)
        options1.add(new SelectOption(s,s));
        return options1;
    }
    
     /** Method to store the Selected status values **/
     public PageReference StatusSelectclick(){
        StatusRightSelected.clear();
        for(String s : StatusLeftSelected){
            StatusLeftvalues.remove(s);
            StatusRightvalues.add(s);
        }
        return null;
     }
     
     /** Method to store the UnSelected status values **/
     
    public PageReference StatusUnselectclick(){
        StatusLeftSelected.clear();
        for(String s : StatusRightSelected){
            StatusRightvalues.remove(s);
            StatusLeftvalues.add(s);
        }
        return null;
    }
    
}