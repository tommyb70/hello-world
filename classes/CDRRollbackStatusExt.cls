public class CDRRollbackStatusExt { 

    ApexPages.StandardController GstdController; 
    ApexPages.StandardController stdcontroller; 
    
    private final CDRQualitativeData__c cdr; 
    public Boolean errorCondition {get;set;} 
    
    public Profile userProfile = [Select Name from Profile where Id =: userinfo.getProfileid()]; 
    public Static String userId = UserInfo.getUserId(); 
    
    public Boolean getErrorCondition() { 
        if (errorCondition == null) errorCondition = FALSE; 
        return errorCondition; 
    } 
    
    public CDRRollbackStatusExt(ApexPages.StandardController controller) { 
        GstdController=controller; 
        this.cdr= (CDRQualitativeData__c)controller.getRecord(); 
        system.debug('cdr: ' + cdr); 
        this.stdController = controller; 
        this.errorCondition = getErrorCondition(); 
    } 
    
    // Code we will invoke on page load. 
    public PageReference autoRun() { 
        
        
        for (CDRQualitativeData__c cdr : [select Id, Owner.Id, Name, Status__c, ParentKey__c, EffectiveDate__c from CDRQualitativeData__c where id =:cdr.Id]) { 
            
            if (cdr.Status__c == 'Draft' || cdr.Status__c == 'Pending Activation' || cdr.Status__c == 'Active') { 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Records in ' + cdr.Status__c + ' cannot be rolled back'); 
            ApexPages.addMessage(myMsg); 
            errorCondition = TRUE; 
            } 
            
            if (cdr.OwnerId != UserInfo.getUserId() && userProfile.Name != 'System Administrator') { 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Only the Owner or a System Administrator can rollback the status of this record'); 
            ApexPages.addMessage(myMsg); 
            errorCondition = TRUE; 
            } else { 
           
            
            if (cdr.Status__c == 'Historical') { 
            List<CDRQualitativeData__c> check = [SELECT Id, Name 
            FROM CDRQualitativeData__c 
            WHERE ParentKey__c = :cdr.ParentKey__c 
            AND EffectiveDate__c > :cdr.EffectiveDate__c 
            AND Status__c = 'Historical']; 
            
            system.debug('check: ' + check); 
            
            if (!check.isEmpty()) { 
            errorCondition = TRUE; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You can only rollback the most recent Historical record'); 
            ApexPages.addMessage(myMsg); 
            } 
            } 
            
            } 
            } 
            
        if(errorCondition == false){
        changeStatus();  
        if(errorCondition  == false){
        PageReference pr= stdController.save(); 
        PageReference detailPage = new PageReference('/'+cdr.Id); 
        return detailPage;  
        }
        }
    
        return null;  
    } 
    
    public void changeStatus() { 
    
    try{
        List<CDRQualitativeData__c> cdrToUpdate = new List<CDRQualitativeData__c>(); 
        
        for (CDRQualitativeData__c cdrCS : [select Id, Name, Status__c from CDRQualitativeData__c where id =:cdr.Id]) { 
        
            if (cdrCS.Status__c == 'Staging') { 
                // Approval.UnlockResult ur = Approval.unlock(cdrCS.Id); 
                cdrCS.Status__c = 'Draft'; 
            } 
            
            if (cdrCS.Status__c == 'Historical') { 
                // Approval.LockResult ur = Approval.lock(cdrCS.Id); 
                cdrCS.Status__c = 'Active'; 
            } 
            
            if (cdrCS.Status__c == 'Inactive') { 
                // Approval.LockResult ur = Approval.lock(cdrCS.Id); 
                cdrCS.Status__c = 'Historical'; 
            } 
            
            cdrToUpdate.add(cdrCS); 
        } 
        
        
        update cdrToUpdate; 
        }catch(Exception e){
        
           frameErrorMessage(e.getmessage());
           
        }
       
    } 
    
    public void frameErrorMessage(string ErrorMessage){
    
        if(ErrorMessage.contains('There is another Draft record already; please coordinate updates')){
        ErrorMessage = 'There is another Draft record already; please coordinate updates';
        }
        if(ErrorMessage.contains('There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed')){
        ErrorMessage = 'There is a Pending Activation, Active, or Historical record with a greater Effective Date; inserting into the past is not allowed';
        }
        if(ErrorMessage.contains('There is another row with the exact same Effective Date; please change the Effective Date on this record')){
        ErrorMessage = 'There is another row with the exact same Effective Date; please change the Effective Date on this record';
        }
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,ErrorMessage); 
        ApexPages.addMessage(myMsg); 
        errorCondition  = true;         
        
    }
    
    public PageReference cancelChange() { 
        PageReference detailPage = new PageReference('/'+this.cdr.Id); 
        return detailPage; 
    } 
    
}