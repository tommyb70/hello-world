public class communitiesEstatementController {
 
    public PageReference forwardToCustomAuthPage() {
        if(UserInfo.getUserType() == 'Guest'){
            return new PageReference('/CustomCommunitiesLoginPage');
        }
        else{
            return null;
        }
    }
    
    /*
   @remoteAction
    public static   Map<String,Object> queryFinancialAccount(String accountId)
    {
        Id UserId = Userinfo.getUserId();       
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        List<Object> accounts = new List<Object>( ); 
        List<FinancialAccount__c> faList = new List<FinancialAccount__c>();      
        
        system.debug ('-----------------------Query Users');                                      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            
            if(accountId != null)    
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                    ( select Contact__r.Name,Name from Financial_Account_Contact__r where Type__c = 'End Client' and ( Status__c = 'Current') ) 
                    ,( select Id,Name,DocumentDate__c, DoNotDisplayReason__c from FinancialAccountFiles__r  where DoNotDisplayReason__c = 'false' ) 
                    FROM FinancialAccount__c where Id=:accountId ] ); 
            }
            else
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                    ( select Contact__r.Name,Name from Financial_Account_Contact__r 
                     where 
                      Status__c = 'Current'  ) 
                    , ( select Id,Name,DocumentDate__c,DoNotDisplayReason__c from FinancialAccountFiles__r 
                       where DoNotDisplayReason__c = 'false' order by CreatedDate desc  ) 
                    FROM FinancialAccount__c ] ); 
            }
            
        }
        
        for(FinancialAccount__c fa : faList)
        {
            // Map<Id,ContentVersion> fileList =  queryChatterFiles(fa.Id);
            List<FinancialAccountFile__c> finalList = new List< FinancialAccountFile__c>();
            Map<String, Object> acc = new Map<String, Object>();
            // List<Object> files = new List<Object>();
            List<Object> clients = new List<Object>();
            List<object> files =  queryChatterFilesByFilesList(fa.Id,fa.FinancialAccountFiles__r);                              
            for (FinancialAccountContact__c fc : fa.Financial_Account_Contact__r) 
            {
                Map<String, Object> c = new Map<String, Object>();
                c.put('ContactName' , fc.Contact__r.Name);
                clients.Add(c);                 
            }        
            acc.put('AccountName',fa.Name);
            acc.put('Files', files);
            acc.put('Clients', clients);
            accounts.add(acc);
        }
        
        result.put('Accounts', accounts);
        result.put('Count', accounts.size());
        result.put('result',true);    
        System.debug( JSON.serialize(result));
        return result;
        
    }*/
    
    
    
    
    @remoteAction
    public static   Map<String,Object>  queryFinancialAccountByClients(Id UserId)
    {
        if( UserId == null)  UserId = Userinfo.getUserId();     
        // UserId= '00529000000gEkm';
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        List<Object> endClientList = new List<Object>( ); 
        Map<String, Object> TempList = new Map<String, Object>();
        Map<Id,FinancialAccount__c> faList = new Map<Id,FinancialAccount__c>();      
        
        system.debug ('-----------------------Query Users---------');                                      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            List<Contact> contact = new List<Contact>([ SELECT Id,Name  FROM Contact where Id=:u.ContactId] );
            if(!contact .isEmpty())
            {
                // get the finnacial contact list
                Map<Id,FinancialAccountContact__c> clients = new Map<Id,FinancialAccountContact__c>([ SELECT Id, Name, Contact__r.Name, 
                                                                                                     Contact__r.Id, Financial_Account__c,
                                                                                                     Contact__c, 
                                                                                                     Type__c, Status__c, 
                                                                                                     View_Financial_Account_in_Community__c,
                                                                                                     ContactName__c 
                                                                                                     From  FinancialAccountContact__c 
                                                                                                     where Contact__r.Id=:u.ContactId
                                                                                                     and Status__c = 'Current' and View_Financial_Account_in_Community__c = True ]);
                List<Id> accountIds = new List<Id>();
                for(FinancialAccountContact__c c : clients.values())
                {
                    accountIds.add(c.Financial_Account__c);
                }
                
                if(accountIds != null)      // Type__c = 'End Client' and
                {
                    faList = new Map<Id,FinancialAccount__c>([
                        SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                        ( select Contact__r.Name,Name from Financial_Account_Contact__r where   Status__c = 'Current' and View_Financial_Account_in_Community__c = True ) 
                        ,  ( select Id,Name,DocumentDate__c, DoNotDisplayReason__c,DocumentQuarter__c ,DocumentYear__c from FinancialAccountFiles__r  where DoNotDisplayinCommunity__c =false 
                           ) 
                        FROM FinancialAccount__c where  ViewableinCommunity__c = true and  Id in:accountIds ] ); 
                }
                else
                {
                    faList = new Map<Id,FinancialAccount__c>([
                        SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                        ( select Contact__r.Name,Name from Financial_Account_Contact__r where  ( Status__c = 'Current') and View_Financial_Account_in_Community__c = True ) 
                        ,( select Id,Name,DocumentDate__c, DoNotDisplayReason__c,DocumentYear__c,DocumentQuarter__c from FinancialAccountFiles__r   where DoNotDisplayinCommunity__c =false ) 
                        FROM FinancialAccount__c  where ViewableinCommunity__c = true ] ); 
                }
                
                
                Map<String, List<Object>> accounts = new Map<String, List<Object>>();
                for(FinancialAccountContact__c endclient : clients.values())
                {
                    
                    if(faList.containsKey(endclient.Financial_Account__c))
                    {
                        FinancialAccount__c fa = faList.get(endclient.Financial_Account__c);
                        System.debug('queryChatterFiles - fa ' + JSON.serialize(fa));
                        List<object> finalFiles =  queryChatterFilesByFilesList(fa.Id,fa.FinancialAccountFiles__r,null);
                        List<FinancialAccountFile__c> finalList = new List< FinancialAccountFile__c>();
                        Map<String, Object> acc = new Map<String, Object>();
                        
                        List< Object> clientsList = new List<Object>();
                        
                        System.debug('queryChatterFiles - finalfiles' + JSON.serialize(finalfiles));
                        System.debug('queryChatterFiles - fa.FinancialAccountFiles__r ' + fa.FinancialAccountFiles__r.size());
                        /*

for (FinancialAccountFile__c ff : fa.FinancialAccountFiles__r) 
{

System.debug('ff.Id' + ff.Id);
if(fileList.containsKey(ff.Id))    
{
Map<String, Object> f = new Map<String, Object>();
ContentVersion c= fileList.get(ff.id);  
f.put('FileName', c.Title);
f.put('FileId', c.Id);
f.put('FileUrl', '/sfc/servlet.shepherd/version/download/'+c.Id);
f.put('FileDate', ff.DocumentDate__c);
files.Add(f);
System.debug('_________ACCOUNT_______MAP_______________File 1');
System.debug(JSON.serialize(f));
System.debug('_________ACCOUNT_______MAP_______________File 2');
System.debug(JSON.serialize(files));

}
}    */        
                        for (FinancialAccountContact__c fc : fa.Financial_Account_Contact__r) 
                        {
                            Map<String, Object> c = new Map<String, Object>();
                            c.put('ContactName' , fc.Contact__r.Name);
                            c.put('ContactId' , fc.Id);
                            clientsList.Add(c);                 
                        }        
                        acc.put('AccountName',fa.Name);
                        acc.put('AccountTitle',fa.AccountTitleEncrypted__c);
                        acc.put('FilesList', finalFiles);
                        System.debug('_________ACCOUNT_______MAP_______________File');
                        System.debug(JSON.serialize(acc));
                        // acc.put('clients', clientsList);
                        
                        if(accounts.containsKey(endclient.Contact__r.Id))
                        {
                            List<Object> accList1 = accounts.get(endclient.Contact__r.Id);
                            accList1.add(acc);
                            accounts.remove(endclient.Contact__r.Id);
                            accounts.put(endclient.Contact__r.Id,accList1);
                            System.debug('_________ACCOUNT_______MAP_______________accList');
                            System.debug(JSON.serialize(accList1));
                            System.debug('_________ACCOUNT_______MAP_________' + JSON.serialize(acc) );
                            
                        }
                        else
                        {  
                            List<Object> accList = new List<Object>();
                            accList.Add(acc);
                            accounts.put(endclient.Contact__r.Id,accList);
                            System.debug('_________ACCOUNT_______MAP_______________accList 1');
                            System.debug(JSON.serialize(accList));
                        }
                    }
                }
                System.debug('_________ACCOUNTS_______MAP');
                System.debug(JSON.serialize(accounts));
                // Make one unified list of conatcts of client
                for(FinancialAccountContact__c endclient : clients.Values())
                {
                    System.debug('_________End Client_______MAP');
                    System.debug(endclient.Contact__r.Id);
                    //endclient.
                   // if(endclient.Type__c == 'End Client')
                    {
                        if( !TempList.containsKey(endclient.Contact__r.Id))
                        {
                            if(accounts.containsKey(endclient.Contact__r.Id))
                            {
                                List<Object> accList = accounts.get(endclient.Contact__r.Id);
                                Map<String, Object> clList = new Map<String, Object>();
                                clList.put('ClientId', endclient.Contact__r.Id);
                                clList.put('ClientName', endclient.Contact__r.Name);
                                clList.put('Accounts', accList);
                                endClientList.Add(clList);
                                TempList.put(endclient.Contact__r.Id,clList);
                                System.debug(JSON.serialize(clList));
                                System.debug(JSON.serialize(accList));
                            }
                        }
                    }
                }
            }
        }
        
        result.put('ClientList', endClientList);
        result.put('Count', endClientList.size());
        result.put('result',true);  
        System.debug('endClientList ' + JSON.serialize(endClientList));
        System.debug(JSON.serialize(result));
        return result;
        // return JSON.serialize(result);
    }
    
    
    
    
    
    
    // @remoteAction
     /*
  public static  Map<Id,ContentVersion> queryChatterFiles(String accountId)
    {
        Id UserId = Userinfo.getUserId();       
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        
        List<FinancialAccount__c> faList = new List<FinancialAccount__c>(); 
        Map<Id,ContentVersion> filelist = new Map<Id,ContentVersion>();
        Map<Id,ContentVersion> FileListByFAF = new Map<Id,ContentVersion>();
        
        List<ContentVersion> cvList = new List<ContentVersion>();      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            if(accountId != null)    
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                    
                    ( select FinancialAccount__c, DocumentDate__c, DocumentType__c from FinancialAccountFiles__r where DoNotDisplayinCommunity__c =false) 
                    FROM FinancialAccount__c where Id=:accountId ] ); 
            }
            else
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                    ( select  FinancialAccount__c, DocumentDate__c, DocumentType__c from FinancialAccountFiles__r where DoNotDisplayinCommunity__c=false) 
                    FROM FinancialAccount__c  ] ); 
            }
            
            Map<Id, FinancialAccountFile__c> fafiles = new Map<Id, FinancialAccountFile__c>();
            for (FinancialAccount__c f : faList)
            {    
                for (FinancialAccountFile__c c : f.FinancialAccountFiles__r) 
                {
                    fafiles.put(c.Id , c );  
                }
                
            }
            
            Map<Id,FeedItem> feedlist = new Map<Id,FeedItem>([
                Select Id, ParentId, Type, Title, Body, CommentCount, LikeCount, LinkUrl, RelatedRecordId From FeedItem  
                where type='ContentPost' and ParentId in:fafiles.keySet()
            ] ); 
            
            Set<Id> feedid = feedlist.keySet();
            // feedid.
           
            
            
            Map<Id,FeedAttachment> Attlist = new Map<Id,FeedAttachment>([
                SELECT Id, FeedEntityId, Type, RecordId, Title, Value FROM FeedAttachment 
                where FeedEntityId in:feedlist.keySet()
            ] );
            
            
            
            Map<Id,FeedAttachment> FeedAttachmentIds = new Map<Id,FeedAttachment>();
            for (FeedAttachment a : Attlist.values())
            {
                FeedAttachmentIds.put(a.RecordId,a) ;
            }
            
            filelist = new Map<Id,ContentVersion>([
                SELECT Id,ContentDocumentId, VersionNumber, Title, Description, PathOnClient,
                FileType, ContentSize, FileExtension, VersionData, Origin FROM ContentVersion
                where Id in:FeedAttachmentIds.keySet()
            ] );
            
            Map<Id,ContentVersion> temp = new Map<Id,ContentVersion>();
            for (ContentVersion c : filelist.values())
            {    
                Id AttRecordId = c.Id;
                System.debug('AttRecordId ' + AttRecordId);
                if(FeedAttachmentIds.containsKey(AttRecordId))
                {
                    
                    FeedAttachment fa = FeedAttachmentIds.get(AttRecordId);
                    Id FeedItemId = fa.FeedEntityId;
                    System.debug('FeedItemId ' + FeedItemId);
                    if(feedlist.containsKey(FeedItemId))
                    {
                        
                        FeedItem fi = feedlist.get(FeedItemId);
                        Id FinancialFileid = fi.ParentId;
                        System.debug('FinancialFileid ' + FinancialFileid);
                        if(!FileListByFAF.containsKey(FinancialFileid))
                            FileListByFAF.put(FinancialFileid,c);
                    }
                    
                    System.debug('FileListByFAF ');
                    System.debug( JSON.serialize(FileListByFAF));
                    
                }
                
            }
            
            
            
            
        } 
        
        result.put('Files', FileListByFAF);
        result.put('Count', FileListByFAF.size());
        result.put('result',true);
        
        //  ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.Files);
        
        
        // return items.items.size();    
        System.debug( 'FILE LIST');   
        System.debug( JSON.serialize(FileListByFAF));
        return FileListByFAF;
        // return JSON.serialize(result);
        
    }*/
   
    /*
    public static  List<object> queryChatterFilesByAccount(String accountId)
    {
        Id UserId = Userinfo.getUserId();       
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        
        List<FinancialAccount__c> faList = new List<FinancialAccount__c>(); 
        Map<Id,ContentVersion> filelist = new Map<Id,ContentVersion>();
        Map<Id,ContentVersion> FileListByFAF = new Map<Id,ContentVersion>();
        List<object> filesObject = new List<Object>();
        
        List<ContentVersion> cvList = new List<ContentVersion>();      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            if(accountId != null)    
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
           
                    ( select FinancialAccount__c, DocumentDate__c, DocumentType__c from FinancialAccountFiles__r ) 
                    FROM FinancialAccount__c where ViewableinCommunity__c = true and  Id=:accountId ] ); 
            }
            else
            {
                faList = new List<FinancialAccount__c>([
                    SELECT Id, Name,    EndClients__c,  AccountNameEncrypted__c, AccountTitleEncrypted__c, AccountShortName__c, AccountType__c, 
                    ( select  FinancialAccount__c, DocumentDate__c, DocumentType__c from FinancialAccountFiles__r ) 
                    FROM FinancialAccount__c   where ViewableinCommunity__c = true ] ); 
            }
            
            Map<Id, FinancialAccountFile__c> fafiles = new Map<Id, FinancialAccountFile__c>();
            for (FinancialAccount__c f : faList)
            {    
                for (FinancialAccountFile__c c : f.FinancialAccountFiles__r) 
                {
                    fafiles.put(c.Id , c );  
                }
                
            }
            if(fafiles != null && !fafiles.isEmpty())
            {
                Map<Id,FeedItem> feedlist = new Map<Id,FeedItem>([
                    Select Id, ParentId, Type, Title, Body, CommentCount, LikeCount, LinkUrl, RelatedRecordId From FeedItem  
                    where type='ContentPost' and ParentId in:fafiles.keySet()
                ] ); 
                
                Set<Id> feedid = feedlist.keySet();
                
                Map<Id,FeedAttachment> Attlist = new Map<Id,FeedAttachment>([
                    SELECT Id, FeedEntityId, Type, RecordId, Title, Value FROM FeedAttachment 
                    where FeedEntityId in:feedlist.keySet()
                ] );
                
                
                
                Map<Id,FeedAttachment> FeedAttachmentIds = new Map<Id,FeedAttachment>();
                for (FeedAttachment a : Attlist.values())
                {
                    FeedAttachmentIds.put(a.RecordId,a) ;
                }
                
                filelist = new Map<Id,ContentVersion>([
                    SELECT Id,ContentDocumentId, VersionNumber, Title, Description, PathOnClient,
                    FileType, ContentSize, FileExtension, VersionData, Origin FROM ContentVersion
                    where Id in:FeedAttachmentIds.keySet()
                ] );
                
                Map<Id,ContentVersion> temp = new Map<Id,ContentVersion>();
                
                for (ContentVersion c : filelist.values())
                {    
                    Id AttRecordId = c.Id;
                    System.debug('AttRecordId ' + AttRecordId);
                    if(FeedAttachmentIds.containsKey(AttRecordId))
                    {
                        
                        FeedAttachment fa = FeedAttachmentIds.get(AttRecordId);
                        Id FeedItemId = fa.FeedEntityId;
                        System.debug('FeedItemId ' + FeedItemId);
                        if(feedlist.containsKey(FeedItemId))
                        {
                            
                            FeedItem fi = feedlist.get(FeedItemId);
                            Id FinancialFileid = fi.ParentId;
                            
                            if(fafiles.containsKey(FinancialFileid))
                            {
                                Map<String, Object> f = new Map<String, Object>();
                                
                                f.put('FileName', c.Title);
                                f.put('FileId', c.Id);
                                f.put('FileUrl', '/sfc/servlet.shepherd/version/download/'+c.Id);
                                f.put('FileDate', fafiles.get(FinancialFileid).DocumentDate__c);
                                filesObject.Add(f);
                            }
                            
                            
                            System.debug('FinancialFileid ' + FinancialFileid);
                            if(!FileListByFAF.containsKey(FinancialFileid))
                                FileListByFAF.put(FinancialFileid,c);
                        }
                        
                        System.debug('FileListByFAF ');
                        System.debug( JSON.serialize(FileListByFAF));
                        
                    }
                    
                }
                
                
                
                
            } 
        }
        
        
        //  ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.Files);
        
        
        System.debug( 'FILE LIST');   
        System.debug( JSON.serialize(filesObject));
        return filesObject;
    }  
*/
    
    
    
   
    public static  List<object> queryChatterFilesByFilesList(String accountId,
                                                             List<FinancialAccountFile__c> accountFiles, Id FeedItemId)
    {
        
        Map<Id,ContentVersion> filelist = new Map<Id,ContentVersion>();       
        List<object> filesObject = new List<Object>();        
        List<ContentVersion> cvList = new List<ContentVersion>();
        if(accountFiles != null)
        System.debug(' accountFiles ' + accountFiles.size() );
        if(accountFiles == null || accountFiles.isEmpty()) return filesObject;        
        Map<Id, FinancialAccountFile__c> fafiles = new Map<Id, FinancialAccountFile__c>();
    Map<Id,FeedItem> feedlist = new Map<Id,FeedItem>();

        
        for (FinancialAccountFile__c c : accountFiles) 
        {     fafiles.put(c.Id , c );  }
        
        system.debug('fafiles Map: ' + fafiles);
        
        if (feedItemId != null) {
            
            for(feeditem fil : [
                Select Id, ParentId, Type, Title, Body, CommentCount, LikeCount, LinkUrl, RelatedRecordId From FeedItem  
                where type='ContentPost' and Id =: feedItemId
            ])
            {
                feedList.put(fil.Id, fil);
            }
        } else {
            for(feeditem fil : [
                Select Id, ParentId, Type, Title, Body, CommentCount, LikeCount, LinkUrl, RelatedRecordId From FeedItem  
                where type='ContentPost' and ParentId IN :fafiles.keySet()
            ]) {
                feedList.put(fil.Id, fil);
            } 
        }
        
        
        
        
        
 
        String communityId = Network.getNetworkId();
        
        for (Id feedElementId : feedlist.keySet())
        {
            Id FinancialFileid = feedlist.get(feedElementId).ParentId;
            Map<String, Object> fileInfo = new Map<String, Object>();
            if(fafiles.containsKey(FinancialFileid))
            {
                fileInfo.put('FileDate', fafiles.get(FinancialFileid).DocumentDate__c);    
                fileInfo.put('DocumentYear', fafiles.get(FinancialFileid).DocumentYear__c ); 
                fileInfo.put('DocumentQuarter', fafiles.get(FinancialFileid).DocumentQuarter__c);  
                
            }
            fileInfo.put('FeedItemId', feedElementId);
            fileInfo.put('FileAccountFileId',FinancialFileid);
            
            ConnectApi.FeedElement el = ConnectApi.ChatterFeeds.getFeedElement(communityId,feedElementId );
            ConnectApi.FeedElementCapabilities cap =   el.capabilities;
            ConnectApi.FilesCapability fl = cap.files;
            List <ConnectApi.Content>  file_list = fl.Items;
            
            System.debug('ConnectApi.Content ' + el);
            for (ConnectApi.Content l : file_list)
            {
                System.debug('ConnectApi.Content Url ' + l.downloadUrl);
                
                fileInfo.put('FileUrl', l.downloadUrl);
                fileInfo.put('FileName', l.title);
                fileInfo.put('FileId', l.Id);
                fileInfo.put('FileDesc', l.description);
                fileInfo.put('FileExtension', l.fileExtension);
                fileInfo.put('FileType', l.fileType);
                fileInfo.put('FileSize', l.fileSize);
                fileInfo.put('FileMimeType', l.mimeType);
                
                System.debug('ConnectApi.Content Url ' + fileInfo);
                filesObject.Add(fileInfo); 
            }
        }
        
        /* Set<Id> feedid = feedlist.keySet();
Map<Id,FeedAttachment> Attlist = new Map<Id,FeedAttachment>([
SELECT Id, FeedEntityId, Type, RecordId, Title, Value FROM FeedAttachment 
where FeedEntityId in:feedlist.keySet()
] );
Map<Id,FeedAttachment> FeedAttachmentIds = new Map<Id,FeedAttachment>();
for (FeedAttachment a : Attlist.values())
{
FeedAttachmentIds.put(a.RecordId,a) ;


}

filelist = new Map<Id,ContentVersion>([
SELECT Id,ContentDocumentId, VersionNumber, Title, Description, PathOnClient,
FileType, ContentSize, FileExtension, VersionData, Origin FROM ContentVersion
where Id in:FeedAttachmentIds.keySet()
] );

Map<Id,ContentVersion> temp = new Map<Id,ContentVersion>();

for (ContentVersion c : filelist.values())
{    
Id AttRecordId = c.Id;
Map<String, Object> f1 = new Map<String, Object>();    
f1.put('ContentId', c.Id);                            
filesObject.Add(f1);
System.debug('AttRecordId ' + AttRecordId);
if(FeedAttachmentIds.containsKey(AttRecordId))
{

FeedAttachment fa = FeedAttachmentIds.get(AttRecordId);
Id FeedItemId = fa.FeedEntityId;
System.debug('FeedItemId ' + FeedItemId);
if(feedlist.containsKey(FeedItemId))
{

FeedItem fi = feedlist.get(FeedItemId);
Id FinancialFileid = fi.ParentId;

if(fafiles.containsKey(FinancialFileid))
{
Map<String, Object> f = new Map<String, Object>();
f.put('FileName', c.Title);
f.put('FileId', c.Id);
f.put('FileUrl', '/sfc/servlet.shepherd/version/download/'+c.Id);
f.put('FileDate', fafiles.get(FinancialFileid).DocumentDate__c);                            
filesObject.Add(f);
}

}
}  */              
        
        
        
        System.debug( '-----------------------filesObject');
        System.debug( JSON.serialize(filesObject));
        return filesObject;
    }
    
    
    
    
    
    
    @remoteAction
    public static  Map<String, Object> queryTermsConditionsHistory()
    {
        Id UserId = Userinfo.getUserId();    
        String UserName = Userinfo.getUserName();
        Map<String, Object> result = new Map<String, Object>();
        List<TermsConditionsHistory__c> TcList = new List<TermsConditionsHistory__c>([   SELECT Id,  Name,TermsConditionsAccepted__c,TermsConditionsEffective__c ,
                                                                                      TCFileDownLoadUrl__c,ContentVersionId__c,TermsConditionsDeclined__c
                                                                                      FROM TermsConditionsHistory__c where User__c=:UserId order by TermsConditionsAccepted__c desc] );
        if(TcList != null && TcList.size() > 0)
        {
            List<object> TcHistoryList = new List<Object>(); 
            for (TermsConditionsHistory__c t : TcList) 
            {  
                Map<String, Object> tcInfo = new Map<String, Object>();
                tcInfo.put('TermsConditionsDeclined', t.TermsConditionsDeclined__c);
                tcInfo.put('LastUpdateDate', t.TermsConditionsAccepted__c);
                tcInfo.put('FileDownloadUrl', t.TCFileDownLoadUrl__c);
                tcInfo.put('EffectiveDate', t.TermsConditionsEffective__c);
                tcInfo.put('FileVersionId', t.ContentVersionId__c);
                tcInfo.put('UserName', UserName);
                TcHistoryList.Add(tcInfo); 
            }
            
            result.put('TCHistory', TcHistoryList);
            result.put('Count', TcHistoryList.size());
            result.put('result',true);
        }
        else
        {
            result.put('ErrorMessage', 'No Terms & Co');
            result.put('Count', 0);
            result.put('result',false);            
        }
        return result; 
    }
    
    
    public  static  Map<String,Object> GetLatestTCData(String Community) {
        
        Map<String,Object> result = new Map<String,Object> ();
        List<ContentWorkspace> workspaceList = [SELECT Id FROM ContentWorkspace WHERE Name = 'Terms and Conditions'];
        if((workspaceList == null) || (workspaceList.isEmpty()))
        {
            result.put('ErrorMessage', 'No Library named found ,  Terms and Conditions ');
            result.put('result',false);
            return result;
        }
        Id workspaceId = workspaceList[0].Id;
        List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Description, ReasonForChange, SharingOption, 
                                             PathOnClient, NetworkId, Origin, FileExtension, ContentSize, VersionData, PublishStatus, FileType, CreatedDate, 
                                             ContentLocation, TextPreview, IsMajorVersion, Effective_Datetime__c, Community__c FROM ContentVersion 
                                             where Community__c=:Community and IsLatest = true and PublishStatus ='P'
                                             and ContentDocument.ParentId = :workspaceId and RecordType.NAME ='Community Files'
                                             order by Effective_Datetime__c desc];
        
        if(!versionList.isEmpty())
        {
            System.debug('Attachment body : '+ versionList[0].VersionData);
            System.debug('Attachment body : '+ versionList[0].Title);
            result.put('FileData', versionList[0].VersionData.toString());
            result.put('FileType', versionList[0].FileType);
            result.put('EffectiveDatetime', versionList[0].Effective_Datetime__c);
            result.put('Community', versionList[0].Community__c );
            result.put('ContentDocumentId', versionList[0].ContentDocumentId) ; 
            result.put('ContentVersionId', versionList[0].Id) ; 
            result.put('Count', 1);
            result.put('result',true);
        }
        else
        {
            result.put('ErrorMessage', 'No Terms and Condition file');
            result.put('result',false);
        }
        
        return  result;
    }
    
    @remoteAction
    public static  Map<String, Object> queryUserInfo(String Community)
    {
        if(Community == null)Community ='eStatement';
        Id UserId = Userinfo.getUserId();  
       // UserId = '00523000000Za79AAC';
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT Id, Username,LastName,TermsConditionsLastAccepted__c,
                                                 TermsConditionFileVersionID__c,TermsandConditionsLastDeclined__c,
                                                 FirstName, Name, IsPortalEnabled, PortalRole, UserName__c, Email, ContactId,Contact.RecordTYpeId,
                                                 Contact.RecordType.Name FROM User where Id=:UserId] );
        
        
        Boolean IsNeededTermConditions = false;
        Boolean IsNeededDeclined = true;
        if ( (contactUser != null) && !contactUser.isEmpty())
        {
             Map<String,Object> tc =  GetLatestTCData(Community);
             Map<String,Object> DeclinedTerms =  CommunityTermsandConditionsDeclinesText  (Community);
           // if(contactUser[0].TermsConditionFileVersionID__c !=  null)
           // {
            //Map<String,Object> tc =  GetLatestTCData(Community);
            if( tc  !=  null)
            {
                if( tc.get('result') == true)
                {
                    DateTime effectiveDate = ( DateTime) tc.get('EffectiveDatetime');
                    // 
                    string ContentVersionId = (String) tc.get('ContentVersionId');
                    String userAccptedId = contactUser[0].TermsConditionFileVersionID__c;
                    DateTime acceptedDate = contactUser[0].TermsConditionsLastAccepted__c;
                    if( userAccptedId == null) IsNeededTermConditions = true;
                    else
                    {
                        if(ContentVersionId != userAccptedId )
                        {
                            // if ( effectiveDate > acceptedDate) 
                            IsNeededTermConditions = true;
                        }
                    }
                }
            }
            //}
            //else  // Terms conditions did not aceepted
            //{
              /* if  (( contactUser[0].TermsConditionsLastAccepted__c ==  null ) ||
                   (contactUser[0].TermsConditionFileVersionID__c == null)) //
                    
                {
                    // first time loggged in
                     IsNeededTermConditions = true;
                }
                else
                {
                    if (contactUser[0].TermsandConditionsLastDeclined__c != null)
                    IsNeededDeclined = true;
                }*/
                
          //  }
            
            result.put('UserName', contactUser[0].Name);
            result.put('FirstName', contactUser[0].FirstName);
             result.put('LastName', contactUser[0].LastName);
             result.put('Contact.RecordTypeId', contactUser[0].Contact.RecordTYpeId);
             result.put('Contact.RecordType.Name', contactUser[0].Contact.RecordType.Name);
            result.put('UserTCAcceptedDate', contactUser[0].TermsConditionsLastAccepted__c);
            result.put('UserEmail', contactUser[0].Email);           
            result.put('IsNeededTermConditions',IsNeededTermConditions);
            if(IsNeededTermConditions) result.put('TermsCondition',tc);
            result.put('DeclinedTerms',DeclinedTerms);
            result.put('Count', 1);
            result.put('result',true);
        }
        else
        {
            result.put('ErrorMessage', 'No User Found');
            result.put('Count', 0);
            result.put('result',false);            
        }
        return result;
    }
    
    
    /* @remoteAction
    public static  Map<String, Object> updateUserInfoV1(String ContentVersionId)
    {
        Map<String, Object> result = new Map<String, Object>();
        if(ContentVersionId == null)
        {
            result.put('ErrorMessage', 'Invalid Contect Version ID');
            result.put('Count', 0);
            result.put('result',false);
            return result;
        }
        Id UserId = Userinfo.getUserId();       
        
        List<User> contactUser = new List<User>([ SELECT Id,Name, TermsConditionsLastAccepted__c,
                                                 TermsConditionFileVersionID__c,TermsandConditionsLastDeclined__c,
                                                 ContactId FROM User where Id=:UserId] );
        
        
        Boolean IsNeededTermConditions = false;
        
        if ( (contactUser != null) && !contactUser.isEmpty())
        {
            
            User u = new User();
            u.Id = contactUser[0].Id;
        
            u.TermsConditionsLastAccepted__c =datetime.now();
            u.TermsConditionFileVersionID__c = ContentVersionId;
       
            
            update u;
            
            result.put('UserId', u.Id);           
            result.put('Count', 1);
            result.put('result',true);
            
            
            TermsConditionsHistory__c updateHistory = new TermsConditionsHistory__c();
            
            
            
            updateHistory.User__c = contactUser[0].Id;
           
            updateHistory.TermsConditionsAccepted__c = u.TermsConditionsLastAccepted__c;
            List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Effective_Datetime__c, Community__c FROM ContentVersion 
                                                 where Id=:ContentVersionId and IsLatest = true and PublishStatus ='P'
                                                 order by Effective_Datetime__c desc];
            
            updateHistory.ContentVersionId__c = ContentVersionId;
            if((versionList != null) && (!versionList.isEmpty()))updateHistory.TermsConditionsEffective__c = versionList[0].Effective_Datetime__c;  
       
                      
            insert updateHistory;
            

           
        }
        else
        {
            result.put('ErrorMessage', 'No User Found');
            result.put('Count', 0);
            result.put('result',false);            
        }
        return result;
    }*/
    
    @remoteAction
    public static  Map<String, Object> updateUserInfo(String ContentVersionId, Integer AcceptedTerms)
    {
        Map<String, Object> result = new Map<String, Object>();
         String Msg = ' User';
        if(ContentVersionId == null)
        {
            result.put('ErrorMessage', 'Invalid Contact Version ID');
            result.put('Count', 0);
            result.put('result',false);
            return result;
        }
        Id UserId = Userinfo.getUserId();       
        
        List<User> contactUser = new List<User>([ SELECT Id,Name, TermsConditionsLastAccepted__c,
                                                 TermsConditionFileVersionID__c,TermsandConditionsLastDeclined__c,
                                                 ContactId FROM User where Id=:UserId] );
        
        
        Boolean IsNeededTermConditions = false;
        
        if ( (contactUser != null) && !contactUser.isEmpty())
        {
            
            User u = new User();
            u.Id = contactUser[0].Id;
            if(AcceptedTerms == 1)
           {
            u.TermsConditionsLastAccepted__c =datetime.now();
            u.TermsConditionFileVersionID__c = ContentVersionId;
             u.TermsandConditionsLastDeclined__c = null;
            }
            else
            {
                u.TermsandConditionsLastDeclined__c =datetime.now();
                 u.TermsConditionFileVersionID__c = null;
                 u.TermsConditionsLastAccepted__c = null;
              //  u.IsActive = false;
            }
            
            update u;
            
            result.put('UserId', u.Id);           
            result.put('Count', 1);
            result.put('result',true);
            
            
            TermsConditionsHistory__c updateHistory = new TermsConditionsHistory__c();
            
            
            
            updateHistory.User__c = contactUser[0].Id;
            if(AcceptedTerms == 1)
        {
            updateHistory.TermsConditionsAccepted__c = u.TermsConditionsLastAccepted__c;
             u.TermsandConditionsLastDeclined__c =null;
            List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Effective_Datetime__c, Community__c FROM ContentVersion 
                                                 where Id=:ContentVersionId and IsLatest = true and PublishStatus ='P'
                                                 order by Effective_Datetime__c desc];
            
            updateHistory.ContentVersionId__c = ContentVersionId;
            if((versionList != null) && (!versionList.isEmpty()))updateHistory.TermsConditionsEffective__c = versionList[0].Effective_Datetime__c;  
        }
            else
            {
            List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Effective_Datetime__c, Community__c FROM ContentVersion 
                                                 where Id=:ContentVersionId and IsLatest = true and PublishStatus ='P'
                                                 order by Effective_Datetime__c desc];
            
            updateHistory.ContentVersionId__c = ContentVersionId;
            if((versionList != null) && (!versionList.isEmpty()))updateHistory.TermsConditionsEffective__c = versionList[0].Effective_Datetime__c;  
                u.TermsandConditionsLastDeclined__c =datetime.now();
                updateHistory.TermsConditionsDeclined__c = u.TermsandConditionsLastDeclined__c;
                u.TermsConditionFileVersionID__c = null;
                 u.TermsConditionsLastAccepted__c=null;
            }
                      
            insert updateHistory;
            
            // Send the email
            if(AcceptedTerms != 1)
            {               
                Msg = ' User ' +  u.Name + ' has not accepted the Terms and Conditions';
                SendEmail(Msg);
            }
        }
        else
        {
            result.put('ErrorMessage', 'No User Found');
            result.put('Count', 0);
            result.put('result',false);            
        }
        return result;
    }
    
    
    public static String SendEmail(String Msg)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('dat@ngam.natixis.com');
            mail.setSenderDisplayName('NGAM SFDC');
            mail.setSubject(Msg);
        return Msg;
                       
        
    }
    
    @remoteAction
    public static  Map<String, Object> queryAcceptedTerms(String Community)
    {
        if(Community == null)Community ='eStatement';
        Id UserId = Userinfo.getUserId();       
        Map<String, Object> result = new Map<String, Object>();
        List<User> contactUser = new List<User>([ SELECT Id, Username,LastName,TermsConditionsLastAccepted__c,
                                                 TermsConditionFileVersionID__c,
                                                 FirstName, Name, IsPortalEnabled, PortalRole, UserName__c, Email, 
                                                 ContactId FROM User where Id=:UserId] );
        
        
        Boolean IsNeededTermConditions = false;
        if ( (contactUser != null) && !contactUser.isEmpty())
        {
            
            Map<String,Object> tc =  GetLatestTCData(Community);
            if( result !=  null)
            {
                if( tc.get('result') == true)
                {
                    
                    result.put('TermsCondition',tc);
                    result.put('Count', 1);
                    result.put('result',true);
                }
                else
                {
                    result.put('ErrorMessage', 'No TermsConditions Found');
                    result.put('Count', 0);
                    result.put('result',false);   
                }
            }
            
            else
            {
                result.put('ErrorMessage', 'No TermsConditions Found');
                result.put('Count', 0);
                result.put('result',false);   
            }
            
        }
        else
        {
            result.put('ErrorMessage', 'No User Found');
            result.put('Count', 0);
            result.put('result',false);            
        }
        return result;
    }
    
    
    
    @remoteAction
    public static  Map<String, Object> CommunityChangePassword(  String NewPassword, 
                                                               String VerifyNewPAssword)
    {
        Id UserId = Userinfo.getUserId();
        String UserName = Userinfo.getUserName();
        Map<String, Object> result = new Map<String, Object>();            
       boolean success = true;         
        boolean passwordExpired =  Site.isPasswordExpired();
        System.debug(' Password expired' + passwordExpired);
        PageReference pf ;
         ResetPasswordResult rpr =  System.resetPassword(UserId, true);
        System.debug(' result = rpr.password ' + rpr.getPassword());
        System.setPassword(UserId,newPassword);
   
        result.put('result',success); 
        return result;
    }
    
     @remoteAction
    public static  Map<String, Object> CommunityForgotPassword()
    {
        Id UserId = Userinfo.getUserId();
        String UserName = Userinfo.getUserName();
        Map<String, Object> result = new Map<String, Object>();            
         boolean success = Site.forgotPassword(UserName);  
        result.put('result',success); 
        return result;
    }
    
    @remoteAction
    public static Map<String, Object> CommunityLogout()
    {      
        PageReference pageRef = new PageReference('/secur/logout.jsp');
        pageRef.setRedirect(true);
        Map<String, Object> result = new Map<String, Object>();   
        result.put('result',true); 
        result.put('logoutUrl','/secur/logout.jsp'); 
        result.put('PageReference',pageRef);  
        return result;
    }
    
    @remoteAction
    public static String  CommunityContactUs()
    {
        Id UserId = Userinfo.getUserId();       
        return  ReadStaticResourceFile('CommunityPrivatePolicy');
    }
    
     @remoteAction
    public static  Map<String,Object> CommunityTermsandConditionsDeclinesText(String Community)
    {
        if(Community == null)Community ='eStatement';
        Id UserId = Userinfo.getUserId();
        return  GetCommunityTermsandConditionsDeclinesText(Community);
    }
    
    public  static  Map<String,Object> GetCommunityTermsandConditionsDeclinesText(String Community) {
        
        Map<String,Object> result = new Map<String,Object> ();
        
        List<ContentWorkspace> workspaceList = [SELECT Id FROM ContentWorkspace WHERE Name = 'Terms and Conditions Declined'];
        if((workspaceList == null) || (workspaceList.isEmpty()))
        {
            result.put('ErrorMessage', 'No Library named found , Terms and Conditions Declined ');
            result.put('result',false);
            return result;
        }
        Id workspaceId = workspaceList[0].Id;
        List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Description, ReasonForChange, SharingOption, 
                                             PathOnClient, NetworkId, Origin, FileExtension, ContentSize, VersionData, PublishStatus, FileType, CreatedDate, 
                                             ContentLocation, TextPreview, IsMajorVersion, Effective_Datetime__c, Community__c FROM ContentVersion 
                                             where Community__c=:Community and IsLatest = true and PublishStatus ='P'
                                             and ContentDocument.ParentId = :workspaceId and RecordType.NAME ='Community Files'
                                             order by Effective_Datetime__c desc];
        
        if(!versionList.isEmpty())
        {
            System.debug('Attachment body : '+ versionList[0].VersionData);
            System.debug('file title : '+ versionList[0].Title);
            result.put('Title', versionList[0].Title);
            result.put('FileData', versionList[0].VersionData.toString());
            result.put('FileType', versionList[0].FileType);
            result.put('EffectiveDatetime', versionList[0].Effective_Datetime__c);
            result.put('Community', versionList[0].Community__c );
            result.put('ContentDocumentId', versionList[0].ContentDocumentId) ; 
            result.put('ContentVersionId', versionList[0].Id) ; 
            result.put('Count', 1);
            result.put('result',true);
        }
        else
        {
            result.put('ErrorMessage', 'No file In library');
            result.put('result',false);
        }
        
        return  result;
    }
    
    
    
    
    @remoteAction
    public static  Map<String,Object> CommunityPrivatePolicy(String Community)
    {
        if(Community == null)Community ='eStatement';
        Id UserId = Userinfo.getUserId();
        return  GetLatestPrivatePolicyData(Community);
    }
    
    public  static  Map<String,Object> GetLatestPrivatePolicyData(String Community) {
        
        Map<String,Object> result = new Map<String,Object> ();
        
        List<ContentWorkspace> workspaceList = [SELECT Id FROM ContentWorkspace WHERE Name = 'Privacy Policies'];
        if((workspaceList == null) || (workspaceList.isEmpty()))
        {
            result.put('ErrorMessage', 'No Library named found ,  Privacy Policies ');
            result.put('result',false);
            return result;
        }
        Id workspaceId = workspaceList[0].Id;
        List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Description, ReasonForChange, SharingOption, 
                                             PathOnClient, NetworkId, Origin, FileExtension, ContentSize, VersionData, PublishStatus, FileType, CreatedDate, 
                                             ContentLocation, TextPreview, IsMajorVersion, Effective_Datetime__c, Community__c FROM ContentVersion 
                                             where Community__c=:Community and IsLatest = true and PublishStatus ='P'
                                             and ContentDocument.ParentId = :workspaceId and RecordType.NAME ='Community Files'
                                             order by Effective_Datetime__c desc];
        
        if(!versionList.isEmpty())
        {
            System.debug('Attachment body : '+ versionList[0].VersionData);
            System.debug('file title : '+ versionList[0].Title);
            result.put('Title', versionList[0].Title);
            result.put('FileData', versionList[0].VersionData.toString());
            result.put('FileType', versionList[0].FileType);
            result.put('EffectiveDatetime', versionList[0].Effective_Datetime__c);
            result.put('Community', versionList[0].Community__c );
            result.put('ContentDocumentId', versionList[0].ContentDocumentId) ; 
            result.put('ContentVersionId', versionList[0].Id) ; 
            result.put('Count', 1);
            result.put('result',true);
        }
        else
        {
            result.put('ErrorMessage', 'No file In library');
            result.put('result',false);
        }
        
        return  result;
    }
    
    
    /* @remoteAction
    public static  Map<String,Object> CommunityFAQcamelCase(String Community)
    {
        if(Community == null)Community ='eStatement';
        Map<String,Object> result = new Map<String,Object> ();
      
        List<Object> FAQList = new List<Object> ();
        Map<String, List<Object>> FAQMap = new Map<String, List<Object>>(); 
        Id UserId = Userinfo.getUserId();
        // query Freq asked questions
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        
        system.debug ('-----------------------Query Users---------');                                      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            List<Contact> c = new List<Contact>([ SELECT Id,Name,RecordType.Name  FROM Contact where Id=:u.ContactId] );
            String RecordTypeName  = '';
            if( c != null && !c.isEmpty())
                RecordTypeName = c[0].RecordType.Name ;
            List<FAQ__c> FAQListAll = new List<FAQ__c>([SELECT Id, Name, RecordTypeId,RecordType.Name,AllContactRecordTypes__c, ContactRecordType__c, CommunityName__c, Active__c, Question__c, 
                                                        Answer__c, HeaderText__c, SortOrder__c, Header__c FROM FAQ__c
                                                        where CommunityName__c  ='eStatement' 
                                                        and Active__c = true 
                                                        and (AllContactRecordTypes__c =true or
                                                        ContactRecordType__c =:RecordTypeName )                                                      
                                                        order by RecordType.Name, SortOrder__c  ] );
            if(!FAQListAll .isEmpty())
            {
                //  query fAQ questions
                for (FAQ__c f : FAQListAll)
                {
                    System.debug('Question : '+ f.Question__c);
                    System.debug('Answer : '+f.Answer__c);
                    Map<String,Object> FAQ = new Map<String,Object> ();
                  //  if(f.RecordType != null) FAQ.put('RecordTypeName', f.RecordType.Name); else FAQ.put('RecordTypeName', null);
             
                    FAQ.put('contactRecordType', f.ContactRecordType__c); 
                    FAQ.put('question', f.Question__c);
                    FAQ.put('answer', f.Answer__c);
                    FAQ.put('headerText', f.HeaderText__c);
                    FAQ.put('sortOrder', f.SortOrder__c);
                    FAQ.put('header', f.Header__c);
                    FAQList.add(FAQ);
                    
                    
                }
            }
            
           
            
           
        }
        result.put('faqList', FAQList) ; 
        result.put('count', FAQList.size());
        result.put('result',true);
        return result;
    }*/
    
    @remoteAction
    public static  Map<String,Object> CommunityFAQ(String Community)
    {
        if(Community == null)Community ='eStatement';
        Map<String,Object> result = new Map<String,Object> ();
      
         List<Object> FAQList = new List<Object> ();
        Id UserId = Userinfo.getUserId();
        // query Freq asked questions
        List<User> contactUser = new List<User>([ SELECT ContactId  FROM User where Id=:UserId] );
        
        system.debug ('-----------------------Query Users---------');                                      
        if(!contactUser.isEmpty())
        {                
            User u = contactUser[0];
            List<Contact> c = new List<Contact>([ SELECT Id,Name,RecordType.Name  FROM Contact where Id=:u.ContactId] );
            String RecordTypeName  = '';
            if( c != null && !c.isEmpty())
                RecordTypeName = c[0].RecordType.Name ;
            List<FAQ__c> FAQListAll = new List<FAQ__c>([SELECT Id, Name, RecordTypeId,RecordType.Name,AllContactRecordTypes__c, ContactRecordType__c, CommunityName__c, Active__c, Question__c, 
                                                        Answer__c, HeaderText__c, SortOrder__c, Header__c FROM FAQ__c
                                                        where CommunityName__c  ='eStatement' 
                                                        and Active__c = true and RecordType.Name='Header'
                                                        and (AllContactRecordTypes__c =true or
                                                        ContactRecordType__c =:RecordTypeName )                                                                                                              
                                                        order by RecordType.Name,SortOrder__c ] );
            if(!FAQListAll .isEmpty())
            {
                //  query fAQ questions
                for (FAQ__c f : FAQListAll)
                {
                    System.debug('Question : '+ f.Question__c);
                    System.debug('Answer : '+f.Answer__c);
                    Map<String,Object> header = new Map<String,Object> ();
                    if(f.RecordType != null) header.put('RecordTypeName', f.RecordType.Name); else header.put('RecordTypeName', null);
                  
                    header.put('ContactRecordType', f.ContactRecordType__c); 
                    header.put('Question', f.Question__c);
                    header.put('Answer', f.Answer__c);
                    header.put('HeaderText', f.HeaderText__c);
                    header.put('SortOrder', f.SortOrder__c);
                    header.put('Header', f.Header__c);
                    List<Object> QaList = new List<Object> ();
                    // create to sort FAQ
                    List<FAQ__c> FAQListAQ = new List<FAQ__c>([SELECT Id, Name, RecordTypeId,RecordType.Name,AllContactRecordTypes__c, ContactRecordType__c, CommunityName__c, Active__c, Question__c, 
                                                        Answer__c, HeaderText__c, SortOrder__c, Header__c FROM FAQ__c
                                                        where CommunityName__c  ='eStatement' 
                                                        and Active__c = true and RecordType.Name='FAQ'
                                                        and Header__c =:f.Id
                                                        and (AllContactRecordTypes__c =true or
                                                        ContactRecordType__c =:RecordTypeName )                                                                                                              
                                                        order by RecordType.Name,SortOrder__c ] );
                    for (FAQ__c qa : FAQListAQ)
                {
                    System.debug('Question : '+ qa.Question__c);
                    System.debug('Answer : '+qa.Answer__c);
                    Map<String,Object> FAQ = new Map<String,Object> ();
                    if(f.RecordType != null) FAQ.put('RecordTypeName', qa.RecordType.Name); else qa.put('RecordTypeName', null);
                  
                    FAQ.put('ContactRecordType', qa.ContactRecordType__c); 
                    FAQ.put('Question', qa.Question__c);
                    FAQ.put('Answer', qa.Answer__c);
                    FAQ.put('HeaderText', qa.HeaderText__c);
                    FAQ.put('SortOrder', qa.SortOrder__c);
                    FAQ.put('Header', qa.Header__c);
                    QaList.add(FAQ);
                }
                    
                    header.put('QaList', QaList);
                    FAQList.add(header);
                }
            }
            
           /* if(!c.isEmpty())
            {
                if(c[0].RecordType != null)
                {
                    List<FAQ__c> FAQListClient = new List<FAQ__c>([SELECT Id, Name, RecordTypeId,RecordType.Name,AllContactRecordTypes__c, ContactRecordType__c, CommunityName__c, Active__c, Question__c, Answer__c, HeaderText__c, SortOrder__c, Header__c FROM FAQ__c
                                                             where CommunityName__c  ='eStatement' and Active__c = true and ContactRecordType__c =:c[0].RecordType.Name order by SortOrder__c]  );
                    if(!FAQList .isEmpty())
                    {
                        //  query fAQ questions
                        for (FAQ__c f : FAQListClient)
                        {
                           System.debug('Question : '+ f.Question__c);
                           System.debug('Answer : '+f.Answer__c);
                            Map<String,Object> FAQ = new Map<String,Object> ();
                            if(f.RecordType != null) FAQ.put('RecordTypeName', f.RecordType.Name); else FAQ.put('RecordTypeName', null);
                            FAQ.put('ContactRecordType', f.ContactRecordType__c); 
                            FAQ.put('Question', f.Question__c);
                            FAQ.put('Answer', f.Answer__c);
                            FAQ.put('HeaderText', f.HeaderText__c);
                            FAQ.put('SortOrder', f.SortOrder__c);
                            FAQ.put('Header', f.Header__c);
                           FAQList.add(FAQ);

                        }
                    }
                }
            }  */
            
           
        }
        result.put('FAQList', FAQList) ; 
        result.put('Count', FAQList.size());
        result.put('result',true);
        return result;
    }
    
    @remoteAction
    public static  String ReadStaticResourceFile(String SRFileName)
    {
        String fileBody ='';
        List<StaticResource> srList = [SELECT Id, Body FROM StaticResource WHERE Name=:SRFileName]; 
        
        if(!srList.isEmpty())
        {
        if(srList[0] != null ) 
            
        {
            StaticResource sr = srList[0];
            if(sr.Body != null)fileBody = sr.Body.toString(); 
        }
        }
        return fileBody;
        
    }
    
    @remoteAction
    public static   List<List<SObject>> SearchText(String SearchText)
    {
        
        List<List<SObject>> searchList = [FIND :SearchText IN ALL FIELDS RETURNING FinancialAccount__c (Id, Name)];        
        return  searchList;
        
    }
    
    
    
}