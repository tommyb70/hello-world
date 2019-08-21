global class CommunitiesReactivateUserBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    // This Batch job inactivates the users that do not any accounts associated with them
    Public integer Count = 0;
    
    // Get info from Custom setting
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    static string UserNameFormat = myCustomSetting.UserNameFormat__c;
    static string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
    static string PortalUserName = myCustomSetting.PotalUserName__c;
    static string PermissionSetForEndClient =   myCustomSetting.PemissionSetForEndClient__c;
    static string ProfileForFAUser =  myCustomSetting.ProfileForFAUser__c;
    static String PermissionSetsForFAUser = myCustomSetting.PermissionSetsForFAUser__c;
    static Integer InactivateDaysForUserLogin = (Integer)myCustomSetting.InactivateDaysForUserLogin__c;
    static String ProfileForEndClient = myCustomSetting.ProfileForEndClient__c;
    static String EmailSenderAddress = myCustomSetting.CommunitySenderEmail__c;
    static String ExternalEmailTemplateDevName = myCustomSetting.ExternalEmailTemplate__c;  
    static String CommunityInternalSender = myCustomSetting.CommunityInternalSender__c;
    static String CommunitySenderDisplayName = myCustomSetting.CommunitySenderDisplayName__c;
    static String UseTestEmail = myCustomSetting.UseTestEmail__c;
    static String TestUserEmail = myCustomSetting.TestUserEmail__c;
    static String CompareNDays = '1';
    
    public String query = 'SELECT Id, Financial_Account__c, Contact__c, Type__c, Status__c, View_Financial_Account_in_Community__c FROM FinancialAccountContact__c WHERE Status__c = \'Current\' AND View_Financial_Account_in_Community__c = TRUE';
    
    List<FinancialAccount__Share> sharesToCreate = new List<FinancialAccount__Share>();
    List<PermissionSetAssignment> PA = new List<PermissionSetAssignment>();
    Public String msg = '';
    
    global CommunitiesReactivateUserBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        System.Debug('Query - ' + query);      
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<FinancialAccountContact__c> scope) {
        
        Map<Id,String> facType = new Map<Id,String>();
        for (FinancialAccountContact__c t : scope) {
            facType.put(t.Contact__c, t.Type__c);
        }
        
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        Map<Id,Id> createdUserMap = new Map<Id,Id>();
        Map<String,Id> profPermSetIdMap = new Map<String,Id>();
        Profile FAProfile = [SELECT Name, Id FROM Profile WHERE name=:ProfileForFAUser LIMIT 1];  
        Profile EndClientProfile = [SELECT Name, Id FROM profile WHERE name=:ProfileForEndClient LIMIT 1]; 
        PermissionSet FAPS = [SELECT Name, Id FROM PermissionSet WHERE name=:PermissionSetsForFAUser LIMIT 1];
        PermissionSet ECPS = [SELECT Name, Id FROM PermissionSet WHERE name=:PermissionSetForEndClient LIMIT 1];
        
        profPermSetIdMap.put(FAProfile.Name, FAProfile.Id);
        profPermSetIdMap.put(EndClientProfile.Name, EndClientProfile.Id);
        profPermSetIdMap.put(FAPS.Name, FAPS.Id);
        profPermSetIdMap.put(ECPS.Name, ECPS.Id);
        
        List<PermissionSetAssignment> permSetToAssign = New List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permSetToAssignR = New List<PermissionSetAssignment>();
        List<User> usersToUpdate = new List<User>();
        List<User> usersToCreate = new List<User>();
        
        Set<Id> contactSet = new Set<Id>();
        Set<Id> financialAccountSet = new Set<Id>();
        Set<Id> contactAlreadyUserSet = new Set<Id>();
        Set<Id> inActiveUserSet = new Set<Id>();
        Set<Id> ActiveUserSet = new Set<Id>();

        for (FinancialAccountContact__c facSet : scope) {
            contactSet.add(facSet.Contact__c);
            financialAccountSet.add(facSet.Financial_Account__c);
        }

        // Reactivate Users
        List<User> contactAlreadyUser = new List<User>([SELECT ContactId, IsActive, FirstName, LastName, Id FROM User
                                                        WHERE IsPortalEnabled = TRUE
                                                        AND ContactId in :contactSet]);
        
        for (User uAA : contactAlreadyUser) {
            contactAlreadyUserSet.add(uAA.ContactId);
            contactUserMap.put(uAA.ContactId,uAA.Id);
        }
        
        Date d = System.today() - InactivateDaysForUserLogin;

        system.debug('d: ' + d);
		        
        List<User> userToActivate = new List<User>([SELECT ContactId, IsActive, FirstName, LastName, Id FROM User
                                                    WHERE IsPortalEnabled = TRUE
                                                    AND ContactId in :contactSet
                                                    // Inactivated users now have their CommunityStatus__c set to Inactive so these criteria are unnessary.
                                                    // When an internal user resets the Finanical Account Contact to Current this job automatically removes the
                                                    // TermsandConditionsLastDeclined__c to null and we don't care about the LastLoginDate for reactivation.
                                                    //AND (TermsandConditionsLastDeclined__c = null 
                                                    //     OR TermsConditionsAcceptAfterDecline__c = TRUE)
                                                    //AND ((LastLoginDate = null AND CreatedDate < :d) OR lastloginDate < : d)
                                                    AND IsActive = FALSE]);
        
        for (User uTa : userToActivate) {
            inActiveUserSet.add(uTa.ContactId);
            uTa.IsActive = TRUE;
            uTa.CommunityStatus__c = 'Active';
            uTa.Comments__c = uta.Comments__c + '-Reactivated ' + Datetime.now();
            uTa.TermsandConditionsLastDeclined__c = null;
            uTa.TermsConditionsLastAccepted__c = null;
            uTa.TermsConditionFileVersionID__c = null;
            usersToUpdate.add(uTa);
        }
        
        system.debug('usersToUpdate: ' + usersToUpdate);
        
        if (usersToUpdate.size() > 0) {
            update usersToUpdate;
        }
        
        // Recreate Permission Sets
        List<PermissionSetAssignment> cps = [SELECT Id,PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :usersToUpdate]; 
        Map<Id,Id> cpsMapFA = new Map<Id,Id>();
        Map<Id,Id> cpsMapEC = new Map<Id,Id>();
        
        for (PermissionSetAssignment pa : cps) {
            
            if (pa.PermissionSetId == profPermSetIdMap.get(PermissionSetsForFAUser)) {
                cpsMapFA.put(pa.AssigneeId,pa.PermissionSetId);
            } else {
                cpsMapEC.put(pa.AssigneeId,pa.PermissionSetId);
            }
            
        }
        
        
        for (User psa : usersToUpdate) {
            
            if (facType.get(psa.ContactId) == 'Financial Advisor' && !cpsMAPFA.containsKey(psa.Id)) {
                PermissionSetAssignment permassign = new PermissionSetAssignment(PermissionSetId = profPermSetIdMap.get(PermissionSetsForFAUser), AssigneeId=psa.Id);
                permSetToAssignR.add(permassign);            
            }
            
            if (facType.get(psa.ContactId) == 'End Client' && !cpsMAPEC.containsKey(psa.Id)) {
                PermissionSetAssignment permassign = new PermissionSetAssignment(PermissionSetId = profPermSetIdMap.get(PermissionSetForEndClient), AssigneeId=psa.Id);
                permSetToAssignR.add(permassign);            
            }
        }
        
        system.debug('permSetToAssignR: '+ permSetToAssignR);
        if (!permSetToAssignR.isEmpty()){
            insert permSetToAssignR;            
        }
        
        
        // Create Users
        for (Contact contactNewUsers : [SELECT Id, IsDeleted, AccountId, LastName, Salutation, FirstName, Name, 
                                        RecordTypeId, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                        MailingCountry, MailingStateCode, MailingCountryCode, MailingLatitude, MailingLongitude, 
                                        MailingGeocodeAccuracy, Phone, Fax, MobilePhone, HomePhone, Email, Title, Status__c, VestMarkEmail__c 
                                        FROM Contact 
                                        WHERE Id IN :contactSet 
                                        AND Id NOT IN :contactAlreadyUserSet]) {
                                            
                                            Id profileId = (facType.get(contactNewUsers.Id) == 'Financial Advisor') ? profPermSetIdMap.get(ProfileForFAUser) : profPermSetIdMap.get(ProfileForEndClient);
                                            String username = GetUniqueUsername(contactNewUsers.FirstName,contactNewUsers.LastName);
                                            String userId = GetUserId(contactNewUsers.FirstName,contactNewUsers.LastName);
                                            
                                            String Email = TestUserEmail;
                                            if (UseTestEmail != 'Y') {Email = contactNewUsers.VestMarkEmail__c;}
                                            if (Email == null) {Email = contactNewUsers.Email;}
                                            
                                            User nCU = new User(contactId=contactNewUsers.Id, 
                                                                username=username, 
                                                                IsActive=TRUE,
                                                                firstname=contactNewUsers.FirstName,
                                                                lastname=contactNewUsers.LastName, 
                                                                email= Email,
                                                                communityNickname = contactNewUsers.LastName + '_'+getRandomNumber(),
                                                                alias = UserID, 
                                                                UserID__c  = username, 
                                                                profileid = profileId, 
                                                                emailencodingkey='UTF-8',
                                                                languagelocalekey='en_US', 
                                                                localesidkey='en_US', 
                                                                timezonesidkey='America/Los_Angeles',
                                                                CommunityStatus__c = 'Active');  
                                            usersToCreate.add(nCU); 
                                        }
        if (usersToCreate.size() > 0) {
			insert usersToCreate;
        }
        
        for (User cUMap : usersToCreate) {
            createdUserMap.put(cUMap.ContactId,cUMap.Id);
        }            
        
        // Create Permission Sets
        for (User psa : usersToCreate) {
            Id permSetId = (facType.get(psa.ContactId) == 'Financial Advisor') ? profPermSetIdMap.get(PermissionSetsForFAUser) : profPermSetIdMap.get(PermissionSetForEndClient);            
            PermissionSetAssignment permassign = new PermissionSetAssignment (PermissionSetId = permSetId, AssigneeId = psa.Id);
            permSetToAssign.add(permassign);
        }
        
        if (permSetToAssign.size() > 0) {
            Database.DMLOptions dlo = new Database.DMLOptions();
			dlo.EmailHeader.triggerUserEmail = true;
            database.insert(permSetToAssign, dlo);
        }
        
        for (User cuMap : usersToCreate) {
            contactUserMap.put(cuMap.ContactId,cuMap.Id);
        }
        
        // Financial Account Shares
        List<FinancialAccount__Share> alreadySharedList = [SELECT Id,UserOrGroupId,ParentId FROM FinancialAccount__Share 
                                                           WHERE UserOrGroupId IN (SELECT Id FROM User WHERE ContactId in :contactSet)
                                                           AND ParentId IN (SELECT Id FROM FinancialAccount__c where Id in :financialAccountSet)];
        Map<String,String> sharedMap = new Map<String,String>();
        for (FinancialAccount__Share ash : alreadySharedList) {
            sharedMap.put((String)ash.ParentId+':'+(String)ash.UserOrGroupId,'foo');
        } 
         
        
        for (FinancialAccountContact__c fac : scope) {
            if (contactUserMap.containsKey(fac.Contact__c) && !sharedMap.containsKey(fac.Financial_Account__c+':'+fac.Contact__c)) {
                FinancialAccount__Share cs = new FinancialAccount__Share(AccessLevel='Read',ParentId=fac.Financial_Account__c,
                                                                         RowCause=Schema.FinancialAccount__Share.RowCause.Manual,
                                                                         UserOrGroupId=contactUserMap.get(fac.Contact__c));
                sharesToCreate.add(cs);  
            }
        }
        
        system.debug('sharesToCreate: ' + sharesToCreate);
        
        // Prepare email and Share list
        String TempMsg = '';
        if (usersToUpdate.size()>0){ 
            TempMsg = TempMsg + '<br/><table  border= "1" >';
            TempMsg = TempMsg + '<tr><th> Reactivated </th></tr>';
            TempMsg = TempMsg + '<tr><th> Contact Id  </th><th> User Name </th></tr>';
            for (User uTA : userToActivate)
            {
                TempMsg = TempMsg + '<tr><td>' +uTA.ContactId + '</td><td>' +uTA.FirstName + ' ' + uTA.LastName + '</td></tr>';
            }   
            TempMsg = TempMsg + '</table><br/><br/>';
        }
        
        if (usersToCreate.size()>0){
            TempMsg = TempMsg + '<br/><table  border= "1" >';
            TempMsg = TempMsg + '<tr><th> Created </th></tr>';
            TempMsg = TempMsg + '<tr><th> Contact Id  </th><th> User Name </th></tr>';
            for (User uTA : usersToCreate)
            {
                TempMsg = TempMsg + '<tr><td>' +uTA.ContactId + '</td><td>' +uTA.FirstName + ' ' + uTA.LastName + '</td></tr>';
            }   
            TempMsg = TempMsg + '</table><br/>';
        }
        msg = TempMsg;
    }
    
    public static String GetUniqueUsername(String FN,String LN )
    {
        String username = '';
        String UserID = GetUserID(FN,LN);
        Integer count = 1;
        Boolean exist = true;
        while (exist == true && count < 20) {
            System.debug(count);
            // if(FN != null)  UserID = FN.trim().deleteWhitespace().leftpad(1).replace('  ','f');
            // if(LN != null)  UserID = UserID + LN.trim().deleteWhitespace().leftpad(1).replace('  ','l'); 
            String random =   string.valueof(getRandomNumber()).deleteWhitespace();
            System.debug('random' + random);
            random = random.leftPad(5).replace(' ','0').substring(0,5);
            System.debug('random' + random);
            username =  UserNameFormat.replace('{0}',  UserID );
            username = username.replace('{1}', random);
            // check user name exist
            List<User> users = [SELECT Id,Name,ContactId,IsPortalEnabled FROM User where Username=:username];
            if(!users.isEmpty())
            {
                exist = true;
                System.debug('INFO - ' + username + ' already exist');
            }
            else
            {
                exist = false;
                System.debug('INFO ' + username + ' is new user name.');
            }
            count++;
        }
        
        return username;
    }
    
    
    public  Static  void SendFinishEmail(String msg,string subject)
    {
        If (msg != '') {
            List<String> toAddresses = CommunityInternalSender.Split(',');            
            CommunitiesEmailHelper.sendEmail(toAddresses, null, EmailSenderAddress, CommunitySenderDisplayName, msg, subject,true);
        }
    }
    
    public static Integer getRandomNumber(){
        Double d = math.random() * 100000000;
        return d.intValue();
    }
    
    public static String GetUserID(String FN,String LN )
    {
        String UserID = '';
        if(FN != null)  
            UserID = FN.trim().deleteWhitespace().leftpad(1).replace('  ','f').substring(0,1);
        else UserID = 'f';
        if(LN != null) 
            UserID = UserID + LN.trim().deleteWhitespace().leftpad(1).replace('  ','l').substring(0,1); 
        else
            UserID = UserID +'l';
        System.debug(UserID + ' UserID');  
        return UserID;  
    }
    
    
    global void finish(Database.BatchableContext BC) {
        system.debug('sharesToCreate finish: ' + sharesToCreate);
        
        if (sharesToCreate.size() > 0) {
            insert sharesToCreate;
        }
        SendFinishEmail(msg,'Activate Portal User Batch Job');
    }
    
    
    
    
}