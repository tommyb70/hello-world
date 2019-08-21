global class CommunitiesInactivateUserBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    // This Batch job inactivates users:
    //  - who do not any financial accounts associated with them and who are not part of any other community
    //  - who have not logged in for x days where x is set in Custom Settings
    //  - who have declined T&C
    
    Public integer Count = 0;
    public String query = ' SELECT Id, Username,isActive, LastName, FirstName, Name, ContactId, AccountId, PortalRole, IsPortalEnabled FROM User where IsPortalEnabled = true and isActive =true  ';
    
    // Get info from Custom setting
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    static string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
    static string PortalUserName = myCustomSetting.PotalUserName__c;
    static string PermissionSetForEndClient =   myCustomSetting.PemissionSetForEndClient__c;
    static string ProfileForFAUser =  myCustomSetting.ProfileForFAUser__c;
    static String PermissionSetsForFAUser = myCustomSetting.PermissionSetsForFAUser__c;
    static Integer InactivateDaysForUserLogin = (Integer)myCustomSetting.InactivateDaysForUserLogin__c;
    
    Public String msg = '';
    Public String logmsg = '';
    
    static String EmailSenderAddress = myCustomSetting.CommunitySenderEmail__c;
    static String ExternalEmailTemplateDevName = myCustomSetting.ExternalEmailTemplate__c;  
    static String CommunityInternalSender = myCustomSetting.CommunityInternalSender__c;
    static String CommunitySenderDisplayName = myCustomSetting.CommunitySenderDisplayName__c;
    static String CompareNDays = '1';
    
    //static List<FinancialAccountContact__c> facToInactivate = new List<FinancialAccountContact__c>();
    
    global CommunitiesInactivateUserBatch() {
        System.Debug('CommunitiesInactivateUserBatch - Update Potal Users Inactive');
        try
        {
            CompareNDays = myCustomSetting.BatchUserJobNumberOfDays__c;
        }
        catch(Exception ex)
        {
            CompareNDays='1';
        }
        
        query = query.replace('@Ndays', CompareNDays);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        System.Debug('CommunitiesInactivateUserBatch Synching  for InActivating Community Users - Using Query');          
        System.Debug('Query - ' + query);      
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
        system.debug('scope: ' + scope);
        
        List<String> temp = new List<String>();
        List<PermissionSetAssignment> AssignmentToDelete = new List<PermissionSetAssignment>();		
        Map<Id,PermissionSetAssignment> AssignmentToDeleteMap = new Map<Id,PermissionSetAssignment>();
        
        Map<id,User> UserIds = new Map<id,User>();
        Map<id,User> ContactIds = new Map<id,User>();        
        for (User u : scope)
        {
            if(!UserIds.containsKey(u.Id)) UserIds.put(u.Id,u);
            if(!ContactIds.containsKey(u.ContactId)) ContactIds.put(u.ContactId,u); 
        }
        
        // Create msg to include in the log table
        logmsg = 'ContactIds Ids Count ' +  ContactIds.size();
        System.Debug(logmsg);
        
        logmsg = 'UserIds Ids Count ' +  UserIds.size();
        System.Debug(logmsg);
        
        Map<Id,PermissionSetAssignment> permAssignmentsFA = new Map<Id,PermissionSetAssignment>();
        Map<Id,PermissionSetAssignment> permAssignmentsEC = new Map<Id,PermissionSetAssignment>();
        Map<Id,PermissionSetAssignment> permAssignmentsOther = new Map<Id,PermissionSetAssignment>();
        
        List<PermissionSetAssignment> pSA = [SELECT PermissionSet.Name,PermissionSet.Id,Assignee.Id,Id 
                                             FROM PermissionSetAssignment
                                             WHERE AssigneeId in: UserIds.keySet()];
        
        for (PermissionSetAssignment pSS : pSA) {
            
            system.debug('pSS: ' + pSS.PermissionSet.Name);
            system.debug('PermissionSetForEndClient: ' + PermissionSetForEndClient);
            system.debug('PermissionSetsForFAUser: ' + PermissionSetsForFAUser);
            
            
            if (pSS.PermissionSet.Name == PermissionSetForEndClient) {
                permAssignmentsEC.put(pSS.Assignee.Id,pSS);
            }
            
            if (pSS.PermissionSet.Name == PermissionSetsForFAUser) {
                permAssignmentsFA.put(pSS.Assignee.Id,pSS);
            }
            
            if (pSS.PermissionSet.Name != PermissionSetsForFAUser &&
                pSS.PermissionSet.Name != PermissionSetForEndClient &&
                pSS.PermissionSet.Name.left(3) != 'X00') {
                    permAssignmentsOther.put(pSS.Assignee.Id,pSS);    
                }
            
        }
        
        List<User> UsersToUdpate = new List<User>(); 
        Map<Id,User> UsersToUdpateMap = new Map<Id,User>(); 
        List<Id> AssignmentToRemove = new List<Id>(); 
        
        // Inactivate User that has no Current, Viewable Financial Account Contact records
        Set<Id> currentFAC = new Set<Id>();
        AggregateResult[] gFAC = [SELECT Contact__c, Count(Id) FROM FinancialAccountContact__c
                                  WHERE Status__c = 'Current'
                                  AND View_Financial_Account_in_Community__c = TRUE
                                  GROUP BY Contact__c];
        
        for (AggregateResult ar : gFAC)  {
            currentFAC.add((Id)ar.get('Contact__c'));
        }
        
        system.debug('currentFAC: ' + currentFAC);
        
        for (User u : scope) {
            
            Boolean OtherCommunities = FALSE;
            if (permAssignmentsOther.containsKey(u.Id)) OtherCommunities = TRUE;
            
            system.debug('User Id: ' + u.Id);
            system.debug('Contact Id: ' + u.ContactId);
            
            if (!currentFAC.contains(u.ContactId)) {
                system.debug('No Current FAC');
                if (permAssignmentsEC.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsEC.get(u.Id));
                if (permAssignmentsFA.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsFA.get(u.Id));
                if(!OtherCommunities)
                {
                    User n = new User(id=u.Id, IsActive=false, ActiveUserProxy__c = false, CommunityStatus__c = 'Inactive: No Financial Accounts', Comments__c ='No active Financial Accounts, Updated to Inactive ' + system.now());
                    if(UsersToUdpateMap.containsKey(n.Id) == false) 
                    {
                        system.debug('Adding User: ' + n.Id);
                        UsersToUdpateMap.put(n.Id,u);
                        UsersToUdpate.add(n); 
                    }
                }
                
            }
        }
        
        // Declined Terms and have not accepted since decline
        Map<Id,User> TermsDeclinedList = new map<Id,User>([SELECT Id, Username,isActive, LastName, FirstName, Name, ContactId, AccountId, PortalRole, 
                                                           IsPortalEnabled 
                                                           FROM User 
                                                           WHERE IsPortalEnabled = TRUE
                                                           AND isActive = TRUE 
                                                           AND TermsandConditionsLastDeclined__c != null
                                                           AND TermsConditionsAcceptAfterDecline__c = FALSE]);
        
        for (User u : TermsDeclinedList.values()) 
        {    
            if (permAssignmentsEC.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsEC.get(u.Id));
            if (permAssignmentsFA.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsFA.get(u.Id));
            User n =  new User(id=u.Id, IsActive=false, ActiveUserProxy__c = false ,CommunityStatus__c = 'Inactive: Declined Terms and Conditions',Comments__c ='Declined Terms and conditions, Updated to Inactive, ' + system.now());
            if(!UsersToUdpateMap.containsKey(n.Id)) {
                UsersToUdpateMap.put(n.Id,u);
                UsersToUdpate.add(n); 
            }
        }        
        
        // Haven't logged in
        if(InactivateDaysForUserLogin > 0)
        {
            Date d = System.today() - InactivateDaysForUserLogin;
            String CommentText = 'Inactivating user who has not logged in for ' + InactivateDaysForUserLogin +' days';
            Map<Id,User> NotLoggedIn = new Map<Id,User>([SELECT Id, CreatedDate, Username,LastName,FirstName, lastloginDate
                                                         FROM User 
                                                         WHERE  IsActive = TRUE
                                                         AND IsPortalEnabled = TRUE
                                                         AND CreatedDate < :d
                                                         AND (ReactivatedDateTime__c < :d OR ReactivatedDateTime__c = null)
                                                         AND (LastLoginDate = null OR lastloginDate < : d)]); 
            
            for (User u : NotLoggedIn.values()) {
                Boolean OtherCommunities = FALSE;
                if (permAssignmentsOther.containsKey(u.Id)) OtherCommunities = TRUE;
                { 
                    if (permAssignmentsEC.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsEC.get(u.Id));
                    if (permAssignmentsFA.containsKey(u.Id)) AssignmentToDeleteMap.put(permAssignmentsEC.get(u.Id).Id, permAssignmentsFA.get(u.Id));
                    if(!OtherCommunities)
                    {
                        User n =  new User(id=u.Id, ActiveUserProxy__c = false,IsActive=false, CommunityStatus__c = 'Inactive: User Did Not Log In',Comments__c = CommentText + system.now());
                        if(!UsersToUdpateMap.containsKey(n.Id)) 
                        {UsersToUdpateMap.put(u.Id,u);
                         UsersToUdpate.add(n); }   
                    }
                    
                }
            }
        }
        
        for (User rePS : UsersToUdpate) {
        }
        
        if ( !UsersToUdpate.isEmpty())
        {
            msg = 'Inactivate Users  Count for Today' +  UsersToUdpate.size();
            System.Debug(msg);update UsersToUdpate;
        } 
        
        for (PermissionSetAssignment atd : AssignmentToDeleteMap.values()) {
            AssignmentToDelete.add(atd);
        }
        
        if(!AssignmentToDelete.isEmpty())
        { 
            msg = 'Total Permission sets Needs to be removed  for Today' +  AssignmentToDelete.size();
            System.Debug(msg);Database.delete(AssignmentToDelete,false); 
        }
        
/*        Set<Id> financialAccountContactsSet = new Set<Id>();
        List<User> finAcctUser = [SELECT Id, ContactId FROM User WHERE Id IN :UsersToUdpate];
        
        for (User uti : finAcctUser) {
            financialAccountContactsSet.add(uti.ContactId);
        }
        
        facToInactivate = [SELECT Id FROM FinancialAccountContact__c WHERE Contact__c IN :financialAccountContactsSet
                           AND Status__c != 'Inactivated'];
        for (FinancialAccountContact__c f : facToInactivate) {
            f.Status__c = 'Inactivated';
        }*/
        
        if (UsersToUdpate.size() > 0) {
            msg = '<p>Inactivated users : ' + UsersToUdpate.size() +  '</p><p>PermissionAssignmentToRemoved : ' + AssignmentToRemove.size() + '</p>';
            String TempMsg = '<br/><table  border= "1" >';
            TempMsg = TempMsg + '<tr><th> User Id  </th><th> User Name </th><th> Reason For Deactivation </th></tr>';
            for (User u: UsersToUdpate)
            {   User old = UsersToUdpateMap.get(u.Id);
             TempMsg = TempMsg + '<tr><td>' +u.Id + '</td><td>' + old.FirstName + ' ' + old.LastName + '</td><td>' +u.CommunityStatus__c + '</td></tr>';
            }             
            TempMsg = TempMsg + '</table><br/>';
            msg = msg +TempMsg;
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
        
        Datetime d = Datetime.now().addDays(-1);
        
        List<User> InactivatedUsers = [SELECT Id, Username,isActive, LastName, FirstName, Name, 
                                       ContactId, AccountId, PortalRole, IsPortalEnabled 
                                       FROM User 
                                       WHERE IsPortalEnabled = TRUE 
                                       AND isActive = FALSE
                                       AND LastModifiedDate >: d];
        Set<Id> IUContactIdSet = new Set<Id>();
        
        for (User u : InactivatedUsers) {
            IUContactIdSet.add(u.ContactId);
        }
        
        List<FinancialAccountContact__c> FACToInactivate = [SELECT Id FROM FinancialAccountContact__c 
                                                            WHERE Contact__c IN :IUContactIdSet
                                                            AND Status__c != 'Inactivated'];
        
        for (FinancialAccountContact__c f : FACToInactivate) {
            f.Status__c = 'Inactivated';
        }
        
        system.debug('FACToInactivate: ' + FACToInactivate);

        update FACToInactivate;
        
        try{
            
            System.debug('query : ' + query );      
            //String logMsg = msg;
            if(logMsg.length() > 250)logMsg=logMsg.substring(1,250);
            ApexActivitiesStatsLogger.logMessage('CommunitiesEstatementInactivateUserBatch', 'CommunitiesEstatementInactivateUserBatch', logMsg, query, '', 'User,FinacialAccountContact__c');
            System.debug('sending finish Email : ' ); 
            system.debug('msg: ' + msg);
            if (!String.isblank(msg)) {
                SendFinishEmail(msg,'Inactivate User batch job ');
            }
            
        } catch (Exception e) {
            System.debug('CommunitiesEstatementInactivateUserBatch - Exception: ' + e);            
        }         
    }
    
}