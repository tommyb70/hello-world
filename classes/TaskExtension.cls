public class TaskExtension {
    
    private final Task sTask;
    private ApexPages.StandardController stdController;
    
    public String errorMessage { get; set; }
    public String retURL {get; set;}

    //Determine if this is SF1 app
    public Boolean isSF1{
        get  {
            Map<String, String> aIncomeParams = ApexPages.currentPage().getParameters();
            if(String.isNotBlank(aIncomeParams.get('sfdcIFrameHost')) ||
                String.isNotBlank(aIncomeParams.get('sfdcIFrameOrigin')) ||
                aIncomeParams.get('isdtp') == 'p1' ||
                (aIncomeParams.get('retURL') != null && aIncomeParams.get('retURL').contains('projectone') )
            ){
                return true;
            } else {
                return false;
            }
        }
    }
        
    public Boolean IC {get;set;}
    public Boolean Inbound {get;set;}
    public boolean InstitutionalProfile {
        get {
            Boolean Instit = false;
             String Uprofile = [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId()
                    ].Profile.Name;
                if (Uprofile == 'NGAM Sales Institutional')
                    {
                    Instit = true;
                    }
                     system.debug('Userinfo.getUserId()' + Userinfo.getUserId()); 
            return Instit;
        }
    }    
     public boolean  is_ic_inbound { 
          get {
                String UserID =  Userinfo.getUserId();
                IC = false;
                IC = UserHelperClass.IsIC_Inbound(UserID );
                return IC ;
               }
        set;       
     }
    
     public boolean  is_inbound { 
          get {
                String UserID =  Userinfo.getUserId();
                Inbound = false;
                Inbound = UserHelperClass.IsInbound(UserID);
                return Inbound ;
               }
        set;       
     }
            
    
    public TaskExtension(ApexPages.StandardController stdController) {
        this.sTask = (Task)stdController.getRecord();
        this.stdController = stdController;
        system.debug('--------------------------------constructor access');
        String IsIC = ApexPages.currentPage().getParameters().get('isic');
        system.debug('--------------------------------IsIC ' +IsIC);
        if (sTask.ActivityDate == null)
            {
            sTask.ActivityDate = system.today();
            }
        if (sTask.ownerid == null)
            {
            sTask.ownerid = system.UserInfo.getUserId();
            }
        if (sTask.ActivitySource__c == '')
            {
            STask.ActivitySource__c='User Created';  
            }
        if (STask.WhoId == null && ApexPages.currentPage().getParameters().get('who_id') != '')
            {
            STask.WhoId = (id)ApexPages.currentPage().getParameters().get('who_id');
            //STask.RepContact__c = (id)ApexPages.currentPage().getParameters().get('who_id');    
            }
        if (STask.whatid == null && ApexPages.currentPage().getParameters().get('what_id') != '')
            {
            STask.whatid = (id)ApexPages.currentPage().getParameters().get('what_id');
            }
        if (STask.status == null && ApexPages.currentPage().getParameters().get('tsk12') != '')
            {
            STask.status = ApexPages.currentPage().getParameters().get('tsk12');
            }
        if (STask.type == null && ApexPages.currentPage().getParameters().get('type') != '')
            {
            STask.type = ApexPages.currentPage().getParameters().get('type');
            }
            
       if (STask.type == null && ApexPages.currentPage().getParameters().get('type') != ''  )
            {
                STask.type = ApexPages.currentPage().getParameters().get('type');
            }          
       if (STask.ActivityType__c == null && ApexPages.currentPage().getParameters().get('activitytype') != '')
            {
            STask.ActivityType__c = ApexPages.currentPage().getParameters().get('activitytype');
            }
            
       if (STask.ActivitySubType__c == null && ApexPages.currentPage().getParameters().get('activitysubtype') != '')
            {
              STask.ActivitySubType__c = ApexPages.currentPage().getParameters().get('activitysubtype');               
            }            
        if (STask.opportunity__c == null && ApexPages.currentPage().getParameters().get('opp') != '')
            {
            STask.opportunity__c = (id)ApexPages.currentPage().getParameters().get('opp');
            }
        if (ApexPages.currentPage().getParameters().get('retURL') != null)
            {
            retURL = (String)ApexPages.currentPage().getParameters().get('retURL');
            }
        else
            {
            retURL = STask.WhoId;
            }     
                
       system.debug('retURL' + retURL); 
    }
   

    
    public PageReference del() {
        errorMessage = '';
        PageReference NextPage = new PageReference('/' + retURL);
        system.debug(NextPage);
        try {
            if (sTask.Status == 'Open')
                {
                delete sTask ; 
                }
            Else
                {
                 sTask.MarkForDeletion__c=true;
                 system.debug('del' );
         system.debug('isic------------------- ' +  is_ic_inbound ); 
         if( is_ic_inbound  == true)
            {
              STask.type = STask.ActivityType__c; STask.Subject = STask.ActivityType__c;
            }
            else
            {
                     STask.ActivityType__c = STask.type;
                     STask.Subject = STask.type;
            }
                 upsert sTask;   
                }
            return NextPage;
            }
        
        catch(System.Exception ex) {  errorMessage = ex.getMessage();ApexPages.addMessages(ex);return null;}

    }

 


 public PageReference change() {
           // PageReference NewPage; 
           // NewPage = Page.TaskNew;
      System.debug('STask.ActivityType__c ' + STask.ActivityType__c); 
     //Exception ex = new Exception();
     //ex.setMessage('STask.ActivityType__c ' + STask.ActivityType__c);
          //   ApexPages.addMessages(ex);
         return null;        
           
    }    
    
    public PageReference FollowUpActivity() {
            PageReference NewPage; 
            NewPage = Page.TaskNew;
            //newPage.getParameters().put('retURL','/' + retURL);     
            newPage.getParameters().put('tsk12', 'Open');  
            newPage.getParameters().put('what_id', Stask.WhatId);      
            newPage.getParameters().put('who_id', Stask.WhoId);
            newPage.getParameters().put('opp', Stask.opportunity__c);        
            newPage.getParameters().put('nooverride', '1');
        	
            newPage.getParameters().put('', Stask.Subject);
            newPage.getParameters().put('', Stask.Description);
        
            return newPage.setRedirect(true);
    }

    public PageReference UniSave() {
        errorMessage = '';
         system.debug('UniSave' );
         system.debug('isic------------------- ' +  is_ic_inbound  ); 
         
         if(  is_ic_inbound  == true)
            {
               STask.type = STask.ActivityType__c; STask.Subject = STask.ActivityType__c;
               
            }
            else
            {
                     STask.ActivityType__c = STask.type;
                     STask.Subject = STask.type;
            }
            
            if(  STask.Subject == 'Email' ||  STask.ActivitySubType__c == 'Email')
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not select Email as an Activity Type or Activity Sub Type.  They are only created through the Outlook Integration'));   return null;
            }
         if(  is_ic_inbound  == true && is_inbound == false)
         if(    STask.ActivityType__c == 'Servicing' &&  STask.ActivitySubType__c == 'Advisor Web Portal')
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not create Advisor Web Portal actiivity, it is only available to inbound users'));   return null;
            }
        try {
            stask.ActivitySource__c = 'User Created';
            upsert sTask;
            PageReference NextPage = new ApexPages.StandardController(sTask).view();
            NextPage.getParameters().put('retURL','/' +retURL);
            return NextPage;
            //newPage.getParameters().put('retURL','/' +Stask.Id);
            }
        
        catch(System.Exception ex) {
            errorMessage = ex.getMessage(); ApexPages.addMessages(ex); return null;
        }

    }
    
    public PageReference TaskEdit() {    
      system.debug('TaskEdit' );      
         system.debug('isic------------------- ' +  is_ic_inbound ); 
         if( is_ic_inbound  == true)
            {
               STask.type = STask.ActivityType__c;  STask.Subject = STask.ActivityType__c;
               
            }
            else
            {
                     STask.ActivityType__c = STask.type;
                     STask.Subject = STask.type;
            }   
        errorMessage = '';
        PageReference NextPage = new  ApexPages.StandardController(sTask).edit();
        NextPage.getParameters().put('retURL','/' +retURL);
        try {
            return NextPage;
            }
        catch(System.Exception ex) {  errorMessage = ex.getMessage(); return null; }

    }
    
    public PageReference SaveEdit() {
        errorMessage = '';
         system.debug('SaveEdit' );
         system.debug('isic------------------- ' +  is_ic_inbound ); 
         if( is_ic_inbound  == true)
            {
               STask.type = STask.ActivityType__c; STask.Subject = STask.ActivityType__c;
               
            }
            else
            {
                     STask.ActivityType__c = STask.type;
                     STask.Subject = STask.type;
            }
        PageReference BackTo = new PageReference('/'+ retURL);

        try {
            upsert sTask;
            return BackTo;
            }
        
        catch(System.Exception ex) {  errorMessage = ex.getMessage(); ApexPages.addMessages(ex); return null; }

    }
    
    
    public PageReference SaveComplete() {
        errorMessage = '';
        system.debug('SaveComplete' );
         system.debug('isic------------------- ' +  is_ic_inbound ); 
         if( is_ic_inbound  == true)
            {
               STask.type = STask.ActivityType__c; STask.Subject = STask.ActivityType__c;
               
            }
            else
            {
                     STask.ActivityType__c = STask.type;
                     STask.Subject = STask.type;
            }
        PageReference BackTo = new PageReference('/'+ retURL);

        try {
            sTask.Status = 'Completed';
            upsert sTask;
            return BackTo;
            }
        
        catch(System.Exception ex) { errorMessage = ex.getMessage(); ApexPages.addMessages(ex);return null; }

    }
    
    
public PageReference upload() {
        errorMessage = '';
        try {
            PageReference NewPage; 
            NewPage = Page.Attachments;
            newPage.getParameters().put('nooverride', '1');
            newPage.getParameters().put('id', Stask.id);
            newPage.getParameters().put('retURL','/' +retURL);
            return newPage;
            }
        
        catch(System.Exception ex) {
            errorMessage = ex.getMessage();
            return null;
        }

    }

    @RemoteAction
    public static Map<String, String> jsRemote(Map<String, String> aIncome) {
        Map<String, String> aResult = new Map<String, String>();
        String sEvt  = aIncome.get('event');
        if (sEvt == 'upload') {
            aResult.put('url', TaskExtension.JSUpload(aIncome.get('id'), aIncome.get('retURL')));
        } else if(sEvt == 'followup') {
            aResult.put('url', TaskExtension.JSFollowUpActivity(aIncome.get('id')));
        } else if(sEvt == 'del') {
            aResult.put('url', TaskExtension.JSDel(aIncome.get('id')));
        }
        return aResult;

    }
    
    
    private static String JSUpload(String sId, String sRetURL){
        PageReference NewPage; 
        NewPage = Page.Attachments;
        newPage.getParameters().putAll(new Map<String, String> {
            'nooverride' => '1',
            'id' => sId,
            'retURL' => '/' + sRetURL
        });
        return newPage.getUrl();
    }

    private static String JSFollowUpActivity(String sId) {
        ID nId = (ID)sId;
        Task oT = [SELECT WhatId, What.name, WhoId, Who.name, opportunity__c, opportunity__r.name, activitydate FROM Task WHERE id=:nId LIMIT 1];
        PageReference NewPage; 
        NewPage = Page.TaskNew;
            //newPage.getParameters().put('retURL','/' + retURL);     
        Map<String, String> aData = new Map<String, String>{
            'status' => 'Open',
            'whatid' => oT.WhatId,
            'whatid_text' => oT.What.name,
            'whoid' => oT.WhoId,
            'whoid_text' => oT.Who.name,
            'opportunity__c' => oT.opportunity__c,
            'opportunity__c_text' => oT.opportunity__r.Name,
            'activitydate' => Datetime.newInstance(oT.activitydate.year(), oT.activitydate.month(), oT.activitydate.day()).format('yyy-MM-dd')
        };
        newPage.getParameters().putAll(new Map<String, String>{
            'predefine' => JSON.serialize(aData),
            'somefield' => 'lalala',
            'nooverride' => '1'
            
        });  
        return newPage.getUrl();
    }

    private static String JSDel(String sId) {
        ID nId = (ID)sId;
        Task oT = [SELECT status, MarkForDeletion__c FROM Task WHERE id=:nId LIMIT 1];

        if (oT.Status == 'Open') {
            delete oT ; 
        } else {
            oT.MarkForDeletion__c = true;
            upsert oT;   
        }
        return '/00T/';

    }
    
 

}