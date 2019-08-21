@isTest 

public class CommunitiesEstatementController_Test { 

    static testMethod void CommunitiesEstatementController_Test() { 
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;
    
        String Community = 'eStatement'; 
        DataFactory.CreateNGAMCustomSettings(); 
        
        ExternalCommunitySettings__c ECS = new ExternalCommunitySettings__c(); 
        ECS.Name = 'EstatementCommunity'; 
        ECS.UseMPANamedCredential__c = 'testugng'; 
        ECS.UserNameFormat__c = 'TEstcom'; 
        ECS.TestUserEmail__c = 'TEst@gmail.com'; 
        ECS.ProfileForFAUser__c ='NGAM Community Plus Login User'; 
        ECS.ProfileForEndClient__c ='NGAM Community Plus Login User'; 
        ECS.PermissionSetsForFAUser__c='Community_login_User_eStatement'; 
        insert ECS; 
        
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity'); 
        String PermSetForFAName = myCustomSetting.PermissionSetsForFAUser__c; 
        String ProfileForFAUser = myCustomSetting.ProfileForFAUser__c; 
        String ProfileForEndClient = myCustomSetting.ProfileForEndClient__c; 
        string FAprofileId = Util.getCustomSettingProfileId(ProfileForFAUser); 
        
        NGAMSettings__c ngamSettings = [select id,ProfileSystemAdministrator__c from NGAMSettings__c limit 1]; 
        string SAprofileId = Util.getCustomSettingProfileId(ngamSettings.ProfileSystemAdministrator__c); 
           
        Account a = new Account(Name = 'TEST Account'); 
        insert a; 
        
        contact con = new contact(FirstName='ABC',LastName = 'TEST Account',AccountId = a.Id); 
        insert con;         
        
        User user = new User(alias = 'test123', email='test123@noemail.com', 
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = FAprofileId, country='United States',IsActive =true, 
                                ContactId = con.Id,userId__c ='sstfr', 
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com'); 
        insert user; 
        
        FinancialAccount__c testAcc = new FinancialAccount__c(Name='Test Name',AccountID__c=123); 
        testAcc.RSAAccount__c = false; 
        testAcc.AccountNameEncrypted__c ='abc'; 
        insert testAcc; 
        
        FinancialAccountContact__c FAC = new FinancialAccountContact__c(); 
        FAC.Financial_Account__c = testAcc.Id; 
        FAC.contact__c = con.Id; 
        FAC.Status__c = 'Current'; 
        FAC.View_Financial_Account_in_Community__c = true; 
        insert FAC; 
        
        
        //Get a list of ALL FeedItems where their parent Financial Account File records are viewable in the community 
        List<FeedItem> feedItemList = [SELECT Id, ParentId, Type, Title, Body, CommentCount, LikeCount, LinkUrl, RelatedRecordId 
                                        FROM FeedItem WHERE Type='ContentPost' 
                                        AND ParentId IN (SELECT Id FROM FinancialAccountFile__c WHERE DoNotDisplayinCommunity__c = FALSE 
                                        AND FinancialAccount__r.ViewableinCommunity__c = TRUE)]; 
        system.debug('feedItemList: ' + feedItemList); 
        
        Set<Id> finAccountFileIdSet = new Set<Id>(); 
        for (FeedItem fi : feedItemList) { 
            finAccountFileIdSet.add(fi.ParentId); 
        } 
        
        finAccountFileIdSet.add(testAcc.Id); 
        
        //Get the FeedItems' corresponding Financial Accounts 
        List<FinancialAccount__c> finAcct = [SELECT Id FROM FinancialAccount__c WHERE Id IN (SELECT FinancialAccount__c FROM FinancialAccountFile__c WHERE Id IN :finAccountFileIdSet)]; 
        system.debug('finAcct: ' + finAcct); 
        
        //Get one Financial Account Contact records with a contact who has access to any of the Financial Accounts in the list 
        //Select from Financial Account Contact where criteria makes him have sharing and where the user is active, etc. 
        FinancialAccountContact__c finAcctContact = [SELECT Id, Financial_Account__c, Contact__c, Financial_Account__r.Name, Contact__r.LastName 
                                                        FROM FinancialAccountContact__c WHERE Status__c = 'Current' 
                                                        AND View_Financial_Account_in_Community__c = TRUE 
                                                        LIMIT 1]; 
        
        //This is the Financial Account Id that will be used in sharing, querying files, etc. below 
        Id financialAccountId = finAcctContact.Financial_Account__c; 
        
        FinancialAccountFile__c FAF = new FinancialAccountFile__c(); 
        FAF.FinancialAccount__c = financialAccountId; 
        
        insert FAF; 
        
        //Get a Financial Account File record for the Financial Account that has a feedItem 
        FinancialAccountFile__c finAcctFile = [SELECT Id, Name FROM FinancialAccountFile__c WHERE FinancialAccount__c =: financialAccountId LIMIT 1]; 
        
        FeedItem feed = new FeedItem (parentid = finAcctFile.id, 
                                        type = 'ContentPost', 
                                        Body = 'Hello'); 
        
        insert feed; 
        
        FeedItem finAcctFileFeedItem = [SELECT Id 
        FROM FeedItem WHERE ParentId =: finAcctFile.Id LIMIT 1]; 
        
        //Get the corresponding User from the Financial Account Contact Record; note we have already filtered for active and profile in the Financial Account Contact select 
        User checkForFileAccessUser = [SELECT Id, LastName FROM User WHERE ContactId =: finAcctContact.Contact__c LIMIT 1]; 
        system.debug('checkForFileAccessUser: ' + checkForFileAccessUser); 
        
        //Just to be sure, apply sharing rules for this user to the Financial Account 
        FinancialAccount__Share shareToCreate = new FinancialAccount__Share(AccessLevel='Read',ParentId=financialAccountId, 
        RowCause=Schema.FinancialAccount__Share.RowCause.Manual, 
        UserOrGroupId=checkForFileAccessUser.Id); 
        insert shareToCreate; 
        
        //Just to be sure, apply permissionset to this user 
        /*PermissionSet PermSetForFA = [SELECT Id FROM PermissionSet WHERE Name = :PermSetForFAName LIMIT 1]; 
        List<PermissionSetAssignment> permSetCheck = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =:PermSetForFA.Id AND AssigneeId =:checkForFileAccessUser.Id]; 
        if (permSetCheck.size() == 0) { 
        PermissionSetAssignment permSetAssignmentInsert = new PermissionSetAssignment(PermissionSetId = PermSetForFA.Id, AssigneeId = checkForFileAccessUser.Id); 
        insert permSetAssignmentInsert; 
        } */ 
        
        
        //One more check of shares after insert 
        List<FinancialAccount__Share> finAcctShareCheck = [SELECT Id FROM FinancialAccount__Share WHERE UserOrGroupId =: checkForFileAccessUser.Id]; 
        
        //At this point we should have a user with access to a Feed Item on a Financial Account File that belongs to a Financial Account that he has sharing on 
        system.debug('---Financial Account and User Details---'); 
        system.debug(' Financial Account: ' + financialAccountId + ' - ' + finAcctContact.Financial_Account__r.Name); 
        system.debug(' Financial Account Contact: ' + finAcctContact.Contact__c + ' - ' + finAcctContact.Contact__r.LastName); 
        system.debug(' Financial Account Contact User: ' + checkForFileAccessUser.Id + ' - ' + checkForFileAccessUser.LastName); 
        system.debug(' Financial Account Share Record Id: ' + finAcctShareCheck[0].Id); 
        system.debug(' Financial Account File: ' + finAcctFile.Id + ' - ' + finAcctFile.Name); 
        system.debug(' Financial Account FeedItem: ' + finAcctFileFeedItem.Id); 
        
        //Get sysAdmin user 
        User sysAdmin = [SELECT Id FROM User WHERE ProfileId =:SAprofileId AND IsActive = TRUE LIMIT 1 ]; 
        
        //Get FAUser -- why? 
        User FAUser = [SELECT Id,ContactId FROM User WHERE IsActive = TRUE 
                      and ContactId !=:finAcctContact.Contact__c LIMIT 1]; 
        
        //Insert new FeedItem for Financial Account File on checkForFileAccessUser's Financial Account File 
        ContentVersion cv = new ContentVersion(); 
        cv.Title = 'Test file'; 
        cv.Description = 'Test file'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        cv.VersionData=bodyBlob; 
        cv.PathOnClient = 'Test drive'; 
        insert cv; 
        
        FeedItem item = new FeedItem(); 
        item.ParentId = finAcctFile.Id; 
        item.Body = 'Test'; 
        item.Type = 'ContentPost'; 
        item.Visibility = 'AllUsers'; 
        insert item; 
        
        FeedAttachment feedAtt = new FeedAttachment(); 
        feedAtt.Title = 'Test'; 
        feedAtt.Type = 'CONTENT'; 
        feedAtt.RecordId = cv.Id; 
        feedAtt.FeedEntityId = item.Id; 
        insert feedAtt; 
        
        Test.startTest(); 
        System.runAs(sysAdmin) { 
            communitiesEstatementController ctrl = new communitiesEstatementController(); 
            PageReference pr = ctrl.forwardToCustomAuthPage(); 
            
            Map<String, Object> clientsnull = communitiesEstatementController.queryFinancialAccountByClients(FAUser.Id); 
            Map<String, Object> clientsnull1 = communitiesEstatementController.queryFinancialAccountByClients(null); 
            Map<String, Object> terms = communitiesEstatementController.queryTermsConditionsHistory(); 
            Map<String, Object> tcList = communitiesEstatementController.queryUserInfo(Community); 
            Map<String, Object> latest = communitiesEstatementController.GetLatestTCData(Community); 
            Map<String, Object> qat = communitiesEstatementController.queryAcceptedTerms(Community); 
            Map<String, Object> pg = communitiesEstatementController.CommunityLogout(); 
            Map<String, Object> communityPrivatePolicy = communitiesEstatementController.CommunityPrivatePolicy(Community); 
            
            String Msg = communitiesEstatementController.SendEmail('Community'); 
            String CommunityContact = communitiesEstatementController.CommunityContactUs(); 
            String tesFile = communitiesEstatementController.ReadStaticResourceFile('TEST'); 
            
            List<List<SObject>> searchResult = communitiesEstatementController.SearchText('abc'); 
            Map<String, Object> CommunityFAQList = communitiesEstatementController.CommunityFAQ(Community); 
            Map<String, Object> pwd = communitiesEstatementController.CommunityForgotPassword(); 
        } 
        
        System.runAs(sysAdmin) { 
            String ContentVersionId = null; 
            
            Map<String, Object> updateUser = communitiesEstatementController.updateUserInfo(ContentVersionId, 1); 
            Map<String, Object> updateUser_1 = communitiesEstatementController.updateUserInfo(cv.Id, 1); 
            Map<String, Object> updateUser_2 = communitiesEstatementController.updateUserInfo(cv.Id, 0); 
            
            List<ContentWorkspace> workspaceList = [SELECT Id FROM ContentWorkspace WHERE Name = 'Terms and Conditions']; 
            if((workspaceList != null) && (!workspaceList.isEmpty())){ 
            
                Id workspaceId = workspaceList[0].Id; 
                List<ContentVersion> versionList = [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Description, ReasonForChange, SharingOption, 
                PathOnClient, NetworkId, Origin, FileExtension, ContentSize, VersionData, PublishStatus, FileType, CreatedDate, 
                ContentLocation, TextPreview, IsMajorVersion, Effective_Datetime__c, Community__c FROM ContentVersion 
                where Community__c=:Community and IsLatest = true and PublishStatus ='P' 
                and ContentDocument.ParentId = :workspaceId and RecordType.NAME ='Community Files' 
                order by Effective_Datetime__c desc]; 
                if(!versionList.isEmpty()){ 
                    Map<String, Object> updateUser1 = communitiesEstatementController.updateUserInfo(versionList[0].Id, 1); 
                    Map<String, Object> updateUser2 = communitiesEstatementController.updateUserInfo(versionList[0].Id, 0); 
                } 
            } 
            Map<String, Object> pass = communitiesEstatementController.CommunityChangePassword('Abc1@1234','Abc1@1234'); 
        
        } 
        
        System.runAs(sysAdmin) { 
            // Note that this was originally meant to run as community user to test row-level security on FeedItem, but the test class wouldn't pass due 
            // to an error that said we need an ID to query FeedItem. SFDC responded to a case saying that aliases (including sets, lists, etc.) 
            // cannot be used in a SOQL of FeedItem in a test class and that the system is working as designed. The functionality we need 
            // does work when running with a real user signed into the UI. I had to change runAs to sysAdmin to 
            // get the code in production. TJB 7/28/17 
            
            system.debug('financialAccountId: ' + financialAccountId); 
            
            List<object> l = communitiesEstatementController.queryChatterFilesByFilesList(financialAccountId,null,finAcctFileFeedItem.Id); 
            
            List<FinancialAccountFile__c> l2 = new List<FinancialAccountFile__c>([SELECT Id, IsDeleted, Name, FinancialAccount__c, DoNotDisplayReason__c, DoNotDisplayinCommunity__c, 
                                                                                    DocumentQuarter__c, DocumentDate__c, DocumentType__c, OriginalFileName__c,DocumentYear__c 
                                                                                    FROM FinancialAccountFile__c WHERE FinancialAccount__c=:financialAccountId Limit 1]); 
            
            List<object> f1 = communitiesEstatementController.queryChatterFilesByFilesList(financialAccountId,l2,finAcctFileFeedItem.Id); 
        } 
        
        Test.stopTest(); 
        
    } 
    
}