public class CDRApprovalSubmissionExt {
    
    public Boolean errorCondition {get;set;} 
    public Profile userProfile = [Select Name from Profile where Id =: userinfo.getProfileid()]; 
    private final CDRQualitativeData__c cdr; 
    
    public string messageError{get;set;}
    
    public CDRApprovalSubmissionExt(ApexPages.StandardController controller) {
        
        this.cdr= (CDRQualitativeData__c)controller.getRecord(); 
        messageError = null;
    }
    
     public PageReference autoRun() { 
         
         errorCondition = false;
         Map<String,CDRQualitativeData__c> mapCDRDatas = new Map<string,CDRQualitativeData__c>();
         
         List<CDRQualitativeData__c> currentRecord = [select id,
                                                              Owner.Id, 
                                                              Name, 
                                                      		  Status__c,
                                                      		  RecordtypeId, 
                                                       		  ParentKey__c, 
                                                      		  EffectiveDate__c from CDRQualitativeData__c where id =:cdr.Id];
        
        if(!currentRecord.IsEmpty()){
            for(CDRQualitativeData__c cdRecord:[select id,
                                                 		Name,
                                                		Status__c,
                                                		ParentKey__c,
                                                		EffectiveDate__c,
                                                		RecordtypeId from CDRQualitativeData__c 
                                                        where ParentKey__c =:currentRecord[0].ParentKey__c and 
                                                		RecordtypeId =:currentRecord[0].RecordtypeId and Id !=: cdr.Id]){
                mapCDRDatas.put(cdRecord.Status__c,cdRecord);
             }
             
             
             for (CDRQualitativeData__c cdr : currentRecord) { 
                 
                 if(cdr.Status__c == 'Draft' && mapCDRDatas.containsKey('Staging')){
                     string ErrMsg = 'Approval will result in this record going to Staging status, which will bump the current Staging record, <a href="/'+mapCDRDatas.get('Staging').Id+'" target="_blank">'+mapCDRDatas.get('Staging').Name+'</a>, to Draft status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Draft' && !mapCDRDatas.containsKey('Draft')){                     
                     string ErrMsg = 'Approval will result in this record going to Staging status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Staging' && mapCDRDatas.containsKey('Pending Activation') && cdr.EffectiveDate__c  > system.today()){                                         
                     string ErrMsg = 'Approval will result in this record going to Pending Activation status, which will bump the current Pending Activation record , <a href="/'+mapCDRDatas.get('Pending Activation').Id+'" target="_blank">'+mapCDRDatas.get('Pending Activation').Name+'</a>, row to Inactive status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Staging' && mapCDRDatas.containsKey('Pending Activation') && cdr.EffectiveDate__c  < system.today()){                     
                     string ErrMsg = 'Approval will result in this record going to Active status, which will bump the current Pending Activation record, <a href="/'+mapCDRDatas.get('Pending Activation').Id+'" target="_blank">'+mapCDRDatas.get('Pending Activation').Name+'</a>, to Inactive status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Staging' && mapCDRDatas.containsKey('Active') && cdr.EffectiveDate__c  < system.today()){                                         
                     string ErrMsg = 'Approval will result in this record going to Active status, which will bump the current Active record, <a href="/'+mapCDRDatas.get('Active').Id+'" target="_blank">'+mapCDRDatas.get('Active').Name+'</a>, to Historical status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Staging' && !mapCDRDatas.containsKey('Staging') && cdr.EffectiveDate__c  < system.today()){
                     string ErrMsg = 'Approval will result in this record going to Active status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Staging' && !mapCDRDatas.containsKey('Staging') && cdr.EffectiveDate__c  > system.today()){                     
                     string ErrMsg = 'Approval will result in this record going to Pending Activation status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Pending Activation'){                     
                     string ErrMsg = 'Approval will result in this record going to Inactive status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                    
                 }else if(cdr.Status__c == 'Active'){
                     string ErrMsg ='Approval will result in this record going to Historical status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                 }else if(cdr.Status__c == 'Historical'){                     
                     string ErrMsg = 'Approval will result in this record going to Inactive status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                 }                 
                 if (cdr.Status__c == 'Draft' || cdr.Status__c == 'Pending Activation' || cdr.Status__c == 'Active') { 
                     string ErrMsg = 'You cannot rollback records in ' + cdr.Status__c + ' status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                             
                     errorCondition = TRUE; 
                 } 
                 
                 if (!errorCondition && cdr.OwnerId != UserInfo.getUserId() && userProfile.Name != 'System Administrator') {      
                	 string ErrMsg = 'Only the Owner or a System Administrator can rollback the status of this record';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                     errorCondition = TRUE; 
                 } else {             
                 if (cdr.Status__c == 'Staging' && mapCDRDatas.containsKey('Draft')) {
                    Map<string,CDRQualitativeData__c> mapRecord = new Map<string,CDRQualitativeData__c>();
                   // mapRecord = existingRecords.get(cdr.ParentKey__c).get('Draft');                   
                    string ErrMsg = 'You cannot rollback this record because there is already a record, <a href="/'+mapCDRDatas.get('Draft').Id+'" target="_blank">'+mapCDRDatas.get('Draft').Name+'</a>, in Draft status';
                    if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                    errorCondition = TRUE;
                }else if(cdr.Status__c == 'Staging'){  
                    string ErrMsg = 'Rollback will result in this record going to Draft status';
                    if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                } 
                if (cdr.Status__c == 'Historical' && mapCDRDatas.containsKey('Active')) {                
                    string ErrMsg = 'You cannot rollback this record because there is already a record, <a href="/'+mapCDRDatas.get('Active').Id+'" target="_blank">'+mapCDRDatas.get('Active').Name+'</a> in Active ';
                    if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                     
                    errorCondition = TRUE;
                }else{
                if (cdr.Status__c == 'Historical') { 
                    List<CDRQualitativeData__c> check = [SELECT Id, Name 
                                                            FROM CDRQualitativeData__c 
                                                            WHERE ParentKey__c = :cdr.ParentKey__c 
                                                            AND EffectiveDate__c > :cdr.EffectiveDate__c 
                                                            AND Status__c = 'Historical']; 
                   if (!check.isEmpty()) { 
                       errorCondition = TRUE;                     
                       string ErrMsg = 'You can only rollback the most recent Historical record';
                       if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                   } else { 
                      string ErrMsg = 'Rollback will result in this record going to Active status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                   } 
                } 
                }
                if (cdr.Status__c == 'Inactive' && mapCDRDatas.containsKey('Historical')) {
                    string ErrMsg = 'You cannot rollback this record because there is already a new record, <a href="/'+mapCDRDatas.get('Historical').Id+'" target="_blank">'+mapCDRDatas.get('Historical').Name+'</a>, in Historical status';
                    if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}
                    errorCondition = TRUE;
                }else if (cdr.Status__c == 'Inactive') { 
                     string ErrMsg = 'Rollback will result in this record going to Historical status';
                     if(messageError != null){messageError =messageError +'<br/>'+ErrMsg;}else{messageError = ErrMsg;}                       
                } 
                } 
           }    
        }
        
        if(messageError != null){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,messageError); 
           ApexPages.addMessage(myMsg); 
        }        
         return null;
     }    
}