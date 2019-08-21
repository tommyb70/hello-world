public with Sharing  class FinancialAccountNewController {
    
    public FinancialAccount__c acc{get; set;}
    String accId;
    ApexPages.StandardController  stdCon;
    public String requestLabel;
    public Boolean Continued { get; set; }
    public String errorMessage { get; set; }
    public String retURL {get; set;}
    public string URL{get;set;}
    public String result{get;set;}
    public  List<FAAccountDetailResponse> ResponseList{get;set;}
    public FAAccountDetailResponse selectedRecord{get;set;}
    public String selectedId{get;set;}
    public  Map<String, FAAccountDetailResponse> responseMap{get;set;}
    Map<String,Id> alreadyExistMap = new  Map<String,Id>();
    public boolean hasRecords {get;set;}
    
    public FinancialAccountNewController(ApexPages.StandardController stdController) {
        stdCon = stdController;
        accId=ApexPages.CurrentPage().getparameters().get('id');     // access the account id from url
        if(accId != null && accId!='')           acc= (FinancialAccount__c)stdController.getRecord();
        else acc=new FinancialAccount__c();  
    }
    
    
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    
    public void showMessage() {
        if(errorLevel == 'WARNING') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, messageName));
        }
    }
    
    public List<SelectOption> responseRecords {
        get{
            
            if ( (responseMap != null) && (responseMap.size() > 0))
            {
                List<SelectOption> options = new List<SelectOption>();
                /* options.add(new SelectOption('','-- Select an Account ---'));*/
                
                integer i=0;
                Boolean Showdisbale = true;
                if(responseMap.size() > 100)Showdisbale= false;
                String FirstID  = null;
                List<FAAccountDetailResponse> l = responseMap.values();
                l.sort();
                for(FAAccountDetailResponse f : l)
                {
                    if(alreadyExistMap.containsKey(String.valueOf(f.accountId)) )
                    {
                        options.add(new SelectOption( String.valueOf(f.accountId),f.accountName+'  '+f.accountTitle, Showdisbale)); 
                    }
                    else
                    {
                        options.add(new SelectOption( String.valueOf(f.accountId),f.accountName+'  '+f.accountTitle));   
                        if(i==0)FirstID=String.valueOf(f.accountId);
                        i++;
                    }
                    
                    if(i>100)break;
                }
                hasRecords = true;
                if(selectedId==null && FirstID != null){ selectedId=FirstID;  populateResponse(); }
                return options;
                
            }
            hasRecords = false;
            return null;
            
        }
        set;
        
    }
    
    
    
    // Method to start the Continuation Webservice
    public Object getData() {
        // Create continuation with a timeout
        Continuation con = new Continuation(30);
        // Set callback method
        con.continuationMethod='processResponse';
        // Call webservice using Continuation
        requestLabel = FinancialAccountGetAccountWSCCallout.getData(con,acc.AccountNameEncrypted__c, 5,URL);    
        Continued = false;     
        return con; 
    }
    
    public void resetForm()
    {
        FinancialAccount__c temp = acc;
        acc = new FinancialAccount__c();
        responseMap = new Map<String, FAAccountDetailResponse>();
        acc.AccountNameEncrypted__c = temp.AccountNameEncrypted__c;
    }
    // Method to start the Continuation Webservice
    public void getDataSync() {
        try
        {
            String val =  acc.AccountNameEncrypted__c ;
            resetForm();
            if(val.length() < 3) 
            {
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'There not enough characters in search and you may get limit exceeed warning.');
                //ApexPages.addMessage(myMsg);
                System.debug('Error : ' + myMsg );
                //return;
            }
            
            
            String result =  FinancialAccountGetAccountWSCCallout.getDataSync(acc.AccountNameEncrypted__c);
            processRequest(result);
        }
        catch(System.Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Could not get data ');
            ApexPages.addMessage(myMsg);
            System.debug('Error : ' + ex.getMessage() );
        }
    }
    
    
    public void populateResponse() 
    {
        if ( (selectedId != null) && (responseMap.containsKey(selectedId)))
        {
            selectedRecord = responseMap.get(selectedId);
            
            if(selectedRecord != null)
            {
                if(alreadyExistMap.containsKey(selectedId))  acc.Id = alreadyExistMap.get(selectedId);
                acc.AccountId__c =  selectedRecord.accountId;
                acc.Name = selectedRecord.accountName;
                if( acc.Name.length() > 3)acc.Name = selectedRecord.accountName.left(3);
                if( selectedRecord.accountName.length() >  4)acc.Name = acc.Name + selectedRecord.accountName.right(4);
                
                acc.AccountNameEncrypted__c =  selectedRecord.accountName;
                acc.AccountTitleEncrypted__c =  selectedRecord.accountTitle;
                acc.AccountType__c = selectedRecord.accountType;
                acc.Sponsor__c = selectedRecord.sponsor;
                acc.Program__c = selectedRecord.program;
                acc.Manager__c = selectedRecord.manager;
                acc.LifecycleStep__c = selectedRecord.lifeCycleStep;
                if(selectedRecord.inceptionValue != null)
                    acc.InceptionValue__c = double.valueof(selectedRecord.inceptionValue);
                if(selectedRecord.inceptionDate != null)
                {
                    DateTime t = DateTime.newInstance(selectedRecord.inceptionDate);
                    if(t != null)
                        acc.InceptionDate__c = Date.newInstance(t.year(), t.month(), t.day()) ;
                }
                acc.ModelOrStrategyName__c= selectedRecord.modelName;
                acc.ModelDescription__c = selectedRecord.modelDescription;
                acc.DCFA_Name__c = selectedRecord.faName;
                if(selectedRecord.firstTradeDate != null)   
                {
                    DateTime f = DateTime.newInstance(selectedRecord.firstTradeDate);
                    if(f != null)
                        acc.FirstTradeDate__c = Date.newInstance(f.year(), f.month(), f.day()) ;
                }
                if(selectedRecord.firstTradeValue != null)
                    acc.FirstTradeValue__c = double.valueof(selectedRecord.firstTradeValue);
                if(selectedRecord.terminationDate != null)
                {
                    DateTime te = DateTime.newInstance(selectedRecord.terminationDate);
                    if(te != null)
                        acc.TerminationDate__c = Date.newInstance(te.year(), te.month(), te.day()) ;
                }
                if(selectedRecord.terminationValue != null)
                    acc.TerminationValue__c = double.valueof(selectedRecord.terminationValue);              
                System.debug('results: ' + selectedRecord); 
                acc.ViewableinCommunity__c = true;
            }
        }
        
    }
    
    
    public void processRequest(String result) 
    {
        System.debug('result: ' + result);   
        ResponseList =  FAAccountDetailResponse.parse(result);
        responseMap = new Map<String, FAAccountDetailResponse>();
        List<Integer> accountIds = new List<Integer>();
        for(FAAccountDetailResponse r : ResponseList)
        {
            accountIds.Add(r.accountId);
        }
        List<FinancialAccount__c> alreadyExist = [SELECT Id,  AccountId__c
                                                  FROM FinancialAccount__c where AccountId__c IN:accountIds];
        alreadyExistMap = new  Map<String,Id>();
        for(FinancialAccount__c f : alreadyExist)
        {
            alreadyExistMap.put(String.valueOf(f.AccountId__c),f.Id);
        }
        
        for(FAAccountDetailResponse r : ResponseList)
        {
            if( !responseMap.containsKey(String.valueOf(r.accountId)))
            {
                // if((alreadyExistMap != null) && (alreadyExistMap.size()>0) && (!alreadyExistMap.containsKey(r.accountId)))                
                responseMap.put( String.valueOf(r.accountId), r);
            }
            
        }
        boolean hasExceededLimits = false;
        if(responseMap != null && responseMap.size()>0) {
            hasRecords = true;if(responseMap.size()>100)hasExceededLimits= true;
        } else hasRecords= false;
        if(hasRecords == false) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No records found, Please try again with new search! ');
            ApexPages.addMessage(myMsg);
            System.debug('Error : ' + myMsg );
        }
        if(hasExceededLimits == true) {
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Search found more than 100 records, please refine your search to get smaller dataset.');
            ApexPages.addMessage(myMsg1);
            System.debug('Error : ' + myMsg1 );
        }
        
    }
    
    
    // Callback method 
    public Object processResponse() {
        HttpResponse response = Continuation.getResponse(this.requestLabel);
        System.debug('response: ' + response);
        result = response.getBody();
        processRequest(result); 
        Continued = true;
        return null;
    }    
    
    public PageReference save() {
        
        if (String.IsBlank(selectedId)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot save this record because an account has not been selected.  Fetch, select an account, or Cancel.  Note that it is possible that this account already exists.');
            ApexPages.addMessage(myMsg);
        } else {
            try
            {
                if(accId != null && accId!='')   update acc;
                else    insert acc; 
                
                PageReference NextPage = new ApexPages.StandardController(acc).view();
                NextPage.getParameters().put('retURL','/' +retURL);
                return NextPage;
            }
            catch(System.Exception ex) {
                errorMessage = ex.getMessage(); ApexPages.addMessages(ex); return null;
            }
        }
        return null;   
    }
    
    public PageReference Cancel()
    {
        // PageReference returnPage = ApexPages.currentPage().getHeaders().get('Referer');
        // a2N/o
        PageReference pg = new PageReference('/a2N/o');
        String retUrl =  ApexPages.currentPage().getParameters().get('retURL');
        if( retUrl != null)  pg = new PageReference(retUrl);
        return pg;
    }
    
    
    
    
}