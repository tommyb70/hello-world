global class CommunitiesNotifyNewStatementsBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    // This Batch job inactivate the users whcih does not any accounts assocuated with them
    Public integer Count = 0;
    
    // Get info from Custom setting
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    
    static string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
    static string PortalUserName = myCustomSetting.PotalUserName__c;
    
    static string PermissionSetForEndClient =   myCustomSetting.PemissionSetForEndClient__c;
    static string ProfileForFAUser =  myCustomSetting.ProfileForFAUser__c;
    static String PermissionSetsForFAUser = myCustomSetting.PermissionSetsForFAUser__c;
    static String EmailSenderAddress = myCustomSetting.CommunitySenderEmail__c;
    static String ExternalEmailTemplateDevName = myCustomSetting.ExternalEmailTemplate__c;  
    static String CommunityInternalSender = myCustomSetting.CommunityInternalSender__c;
    static String CommunitySenderDisplayName = myCustomSetting.CommunitySenderDisplayName__c;
    static String CompareNDays = '1';
    static string CCEmailsAddress = myCustomSetting.BatchJobCCemails__c;
    static Boolean BatchNotifyFASendAllorNone = myCustomSetting.BatchNotifyFASendAllorNone__c;
    public String query = ' SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, FinancialAccount__c, DoNotDisplayReason__c, DoNotDisplayinCommunity__c, DocumentDate__c, DocumentType__c, OriginalFileName__c FROM FinancialAccountFile__c where DoNotDisplayinCommunity__c != true  and  createddate >= LAST_N_DAYS:@Ndays ';
    
    Public String msg = '';
    
    public Map<String, List<String>> m = new Map<String,  List<String>>();
    
    global CommunitiesNotifyNewStatementsBatch() {
        System.Debug('CommunityNotifyNewStatements - Notify users for new statements');       
        CompareNDays = myCustomSetting.BatchNotifyFAJobNumberOfDays__c;       
        query = query.replace('@Ndays', CompareNDays);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        System.Debug('CommunityNotifyNewStatements Synching New Statements Users - Using Query');          
        System.Debug('Query - ' + query);      
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<FinancialAccountFile__c> scope) {
        
        List<String> temp = new List<String>();
        Id emailTemplateId;  
        try {emailTemplateId = [select id, name from EmailTemplate where developername = : ExternalEmailTemplateDevName].id;}
        catch (Exception e) { throw new emailException ('Unable to locate EmailTemplate using name: ' + ExternalEmailTemplateDevName +   ' refer to Setup | Communications Templates ' + ExternalEmailTemplateDevName); }
        
        
        Map<id,List<FinancialAccountFile__c>> FAccountList = new Map<id,List<FinancialAccountFile__c>>();        
        for (FinancialAccountFile__c  c : scope)
        {
            if(!FAccountList.containsKey(c.FinancialAccount__c))
            {
                List<FinancialAccountFile__c> tempList = new List<FinancialAccountFile__c>();
                tempList.Add(c);
                FAccountList.put(c.FinancialAccount__c,tempList);
            }
            else
            {
                List<FinancialAccountFile__c> tempList1 = FAccountList.get(c.FinancialAccount__c);
                tempList1.Add(c);
                FAccountList.remove(c.FinancialAccount__c);
                FAccountList.put(c.FinancialAccount__c,tempList1);
                
            }
        }
        System.Debug('FAccountList - ' + FAccountList.size());   
        for (Id  c : FAccountList.keySet())
        {
            System.Debug('FAccountList - ' + c); 
        }
        // query Fiancial account for new upated files
        Map<id,FinancialAccount__c> FAMaps =  new Map<Id,FinancialAccount__c>([
            SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
            ( select Contact__r.Id, Contact__r.VestMarkEmail__c, Contact__r.Name,Name from Financial_Account_Contact__r where   Status__c = 'Current'
             and View_Financial_Account_in_Community__c = True ) 
            , ( select Id,Name,DocumentDate__c, DoNotDisplayReason__c,DocumentQuarter__c ,DocumentYear__c from FinancialAccountFiles__r  where DoNotDisplayReason__c != 'true'
              ) 
            FROM FinancialAccount__c where Id in:FAccountList.keySet()] );
        
        Map<id,List<FinancialAccount__c>> emailList = new Map<id,List<FinancialAccount__c>>();
        Map<id,Contact> contactMap = new Map<id,Contact>();
        for (FinancialAccount__c  a : FAMaps.values())
        {
            for (FinancialAccountContact__c fc : a.Financial_Account_Contact__r) 
            {
                if(!contactMap.containsKey(fc.Contact__r.id))
                    contactMap.put(fc.Contact__r.id, fc.Contact__r);
                if(!emailList.containsKey(fc.Contact__r.id))
                {
                    List<FinancialAccount__c> tempList2 = new List<FinancialAccount__c>();
                    tempList2.Add(a);
                    emailList.put(fc.Contact__r.id,tempList2);
                }
                else
                {
                    List<FinancialAccount__c> tempList3 = emailList.get(fc.Contact__r.id);  
                    tempList3.Add(a);  emailList.remove(fc.Contact__r.id);   emailList.put(fc.Contact__r.id,tempList3);
                }
            }
            
        }
        
        Map<id,User> usermap =  new Map<Id,USer>([  SELECT Id, Name, Email ,ContactId FROM User where ContactId in:emailList.keySet()] );  
        List<Messaging.SingleEmailMessage>  emailMessageList = new List<Messaging.SingleEmailMessage>();       
        String TempMsg='';        
        for (Id contactId  : emailList.keySet())
        {
            List<FinancialAccount__c> tempList4 = emailList.get(contactId);
            // compose email msg and send the email          
            for (User  u : usermap.values())
            { 
                if(u.ContactId == contactId)
                {                  
                    List<String> ToAddress = new List<String>();
                    ToAddress.add(u.Email);
                    List<String> CCAddress =null;
                    if(!String.isBlank(CCEmailsAddress)) CCAddress = CCEmailsAddress.split(';');		
                    System.debug('Sending Email to : ' + u.Email);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(ToAddress);
                    email.setCcAddresses(CCAddress);
                    email.setTargetObjectId(u.Id);    
                    email.setTemplateId(emailTemplateId);
                    //email.set(FromEmail);
                    email.setReplyTo(EmailSenderAddress);
                    email.setSenderDisplayName(CommunitySenderDisplayName);   
                    email.setSaveAsActivity(false);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users                    
                    System.debug(LoggingLevel.INFO,'** entered sendTemplatedEmail, to:' + ToAddress + ' cc:' + CCAddress +  ' templateId:' + emailTemplateId 
                                 + ' tagetObjId:' + u.Id  + ' FromEmail:' + EmailSenderAddress +  + ' UserId:' + u.Id  );
                    emailMessageList.Add(email);  
                }
            }                       
        }         
        Messaging.SendEmailResult[] results =   CommunitiesEmailHelper.sendTemplatedEmailByList(emailMessageList,BatchNotifyFASendAllorNone);        
        Map<id,String> errorList =  new Map<Id,String>();
        if (results !=  null && results.size() > 0) {
            for (Messaging.SendEmailResult  r : results)
            { 
                if(!r.isSuccess())
                {                   
                    System.Debug('errors - ' + r.getErrors()); 
                    for(Messaging.SendEmailError er :r.getErrors())
                    {
                        if(!errorList.containsKey(er.getTargetObjectId())) errorList.put(er.getTargetObjectId(), er.getMessage());
                        else                        
                            errorList.put(er.getTargetObjectId(), errorList.get(er.getTargetObjectId()) + ' '+  er.getMessage());
                        
                    }
                }
            }                           
        }      
        if (usermap !=  null && usermap.size() > 0) {
            msg = msg + '<p>Sent notification to Community Members, Total Count - ' + usermap.size() +  '</p>';
            //  msg = msg + '<br/><p>Please note that emails were successfully submitted for delivery for this list. It does not mean the intended recipients received the email, as there could have been a problem with the email address or it could have bounced or been blocked by a spam blocker. </p>';
            TempMsg = '<br/><table  border= "1" >';
            TempMsg = TempMsg + '<tr><th> Contact Id </th><th> Contact Name </th><th> Email Sent to </th></tr>';
            for (User  u : usermap.values())
            { 
                if(contactMap.containsKey(u.ContactId))
                    TempMsg = TempMsg + '<tr><td> ' +contactMap.get(u.ContactId).Id + ' </td><td> ' + contactMap.get(u.ContactId).Name + ' </td><td> ' + u.Email + ' </td></tr>';
            }             
            TempMsg = TempMsg + '</table><br/>';
            msg = msg +TempMsg;
        } 
        
        if (errorList !=  null && errorList.size() > 0) {
            msg = '<p>Errors in submitting the emails for delivery: ' + errorList.size() +  '</p>';
            TempMsg = '<br/><table  border= "1" >' + '<tr><th> User Id  </th><th> User Email Address </th><th> Error Msg  </th></tr>';
            for (Id  key : errorList.keySet())
            {               
                if(userMap.containsKey(key)) TempMsg = TempMsg + '<tr><td> ' +key + ' </td><td> ' +  + ' </td>' + userMap.get(key).Email  +'<td> ' +errorList.get(key) + ' </td></tr>'; 
            }
        }
    }
    
    public  Static  void SendFinishEmail(String msg,string subject)
    {
        if (msg != null) {
            List<String> toAddresses = CommunityInternalSender.Split(',');            
            CommunitiesEmailHelper.sendEmail(toAddresses, null, EmailSenderAddress, CommunitySenderDisplayName, msg, subject,true);
        }
    }    
    global void finish(Database.BatchableContext BC) {
        try{
            System.debug('query : ' + query );
            SendFinishEmail(msg,'New Statement Notifications Sent to Community Members');            
        }  
        catch (Exception e) {
            System.debug('CommunityNotifyNewStatements - Exception: ' + e);            
        }        
    }
}