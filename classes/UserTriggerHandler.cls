public without sharing class UserTriggerHandler {
    /* In this method, when user record changes and the base-64 encoded Picture__c field is not null, convert the 
* base-64 Picture__c field back to an image blob and post the picture to the user's record.  The base-64 encoded
* data comes from an Informatica cloud integration that pulls add pictures into SFDC.  Note that I tried to do this
* only on change of u.Picture__c, but SFDC wouldn't respond to that if statement */
    public static void setUserPicture(Map<Id,User> userMapNew, Map<Id,User> userMapOld) {
        
        if (!System.isBatch()) {
            
            Set<Id> setPictureIds = new Set<Id>();
            Set<Id> removePictureIds = new Set<Id>();
            
            for (User u : userMapNew.values()) {
                String newValue = u.Picture__c;
                String oldValue = userMapOld.get(u.Id).Picture__c;
                
                system.debug('new: ' + newValue);
                system.debug('old: ' + oldValue);
                
                if (newValue != oldValue) {
                
                if ((u.UserType == 'Standard' || u.UserType == 'CsnOnly') && !String.isblank(u.Picture__c))  {
                    setPictureIds.add(u.Id);
                }
                if ((u.UserType == 'Standard' || u.UserType == 'CsnOnly') && String.isblank(u.Picture__c))  {
                    removePictureIds.add(u.Id);
                }
            }
            }
            
            if (!setPictureIds.isEmpty()) {
                userSetPictureFuture(setPictureIds);
            }
            
            if (!removePictureIds.isEmpty()) {
                userRemovePictureFuture(removePictureIds);
            }
        }
    }
    
    /*In this method if user status changes to inactive then 
*we are going to assign that user to NGAM inactive user profile 
*removing those users from public groups and territories except NGAM */ 
    public static void userInactiveFunctionalities(List<User> Users,map<Id,User> usersMap){ 
        NGAMSettings__c NM = NGAMSettings__c.getOrgDefaults(); 
        set<Id> userIds = new set<Id>(); 
        string InactiveUsersProfileId = Util.getCustomSettingProfileId(NM.ProfileForInactiveUsers__c); 
        for(User us:Users){ 
            if(!us.IsActive && usersMap.get(us.Id).IsActive && us.UserType == 'Standard'){ 
                us.ProfileId = InactiveUsersProfileId != null ? InactiveUsersProfileId : us.ProfileId; 
                userIds.add(us.Id); 
            } 
        } 
        if(!userIds.IsEmpty()){ 
            List<GroupMember> ListGM = [ Select Id from GroupMember where Group.Type IN ('Regular','Case','Lead','Queue','CollaborationGroup') and UserOrGroupID IN:userIds]; 
            if(ListGM.size() > 0 ){ delete ListGM; } 
            userPermissionsetDelete(userIds); 
            userTerritoryDelete(userIds); 
        } 
    } 
    
    @future 
    public static void userPermissionsetDelete(set<Id> userIds){ 
        List<PermissionSetAssignment> lstPSA = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : userIds and Assignee.IsActive =: FALSE AND Assignee.UserType =: 'Standard' AND PermissionSetId IN (SELECT Id 
                                                                                                                                                                                                                FROM PermissionSet WHERE IsOwnedByProfile =false)]; 
        if(!lstPSA.isEmpty()){ delete lstPSA;} 
    } 
    
    @future 
    public static void userTerritoryDelete(set<Id> userIds){ 
        List<UserTerritory__c> lstUT = [select id from UserTerritory__c where user__c IN:userIds and Territory__r.Name != 'NGAM']; 
        if(lstUT.size() > 0 ){ delete lstUT; } 
    } 
    
    public static void SetUserRoleId (list<User> newUsers) { 
        
        for (User usr: newUsers) { 
            System.debug('usr' + usr); 
            if(usr.UserType == 'Standard'){ 
                if ((usr.RoleProxy__c != null) && (usr.RoleProxy__c <> '')){ 
                    System.debug('usr' + usr.RoleProxy__c); 
                    System.debug('usr' + usr.UserRoleid); 
                    usr.UserRoleid = usr.RoleProxy__c; 
                } 
                //if (usr.ProxyProfileId__c <> '') 
                //{ 
                //usr.ProfileId =usr.ProxyProfileId__c; 
                //} 
            }         
        } 
    } 
    
    public static void SetReactivatedDatetime (list<User> newUsers, Map<Id,User> oldUserMap) { 
        
        for (User usr: newUsers) {         
            if(usr.IsActive && oldUserMap.get(usr.Id).IsActive == FALSE) {         
                usr.ReactivatedDatetime__c = Datetime.now();         
            }         
        } 
    } 
    
    @future 
    public static void userSetPictureFuture(set<Id> userIds) { 
        List<User> lstUser = [SELECT Id, Picture__c FROM User WHERE Id IN : userIds];
        for (User u : lstUser) {
            if (!String.isBlank(u.Picture__c)&&!Test.isRunningTest()) {
                Blob b = EncodingUtil.base64Decode(u.Picture__c);
                ConnectApi.PhotoInput pi = new ConnectApi.PhotoInput();
                ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhotoWithAttributes(null, u.Id,  pi, new ConnectApi.BinaryInput(b,'image/jpg','userImage.jpg'));
            }
        }
    } 
    
    @future 
    public static void userRemovePictureFuture(set<Id> userIds) { 
        List<User> lstUser = [SELECT Id, Picture__c FROM User WHERE Id IN : userIds];
        for (User u : lstUser) {
            if (String.isblank(u.Picture__c) && !Test.isRunningTest()) {
                ConnectApi.UserProfiles.deletePhoto(null, u.Id);
            } 
        }
    } 
    
    public static void handleAfterInsertOrUpdate(List<User> lstUsersAll){
        if (System.isFuture()) {
            return;
        }
        
        Set<Id> setIds = new Set<Id>();
        for (Integer i = 0; i < lstUsersAll.size(); i++) {
            setIds.add(lstUsersAll[i].Id);
        }
        List<User> lstFullVersion = [SELECT id, Name, Alias, Profile.Name, FirstName, LastName, KeyInsightListViewId__c FROM User WHERE id IN :setIds];
        List<User> lstUsers = new List<User>();
        for (Integer i = 0; i < lstFullVersion.size(); i++) {

            if( String.isBlank(lstFullVersion[i].KeyInsightListViewId__c) && 
                (lstFullVersion[i].Profile.Name == 'Natixis Retail External' ||
                lstFullVersion[i].Profile.Name == 'Natixis Retail Internal' ||
                lstFullVersion[i].Profile.Name == 'Natixis Institutional' )
            ){
                lstUsers.add(lstFullVersion[i]);
            }

        }
        
        List<Group> grouplist = new List<Group>();
        
        Set<String> groupsName = new Set<String>();
        Map<String, Id> usersNameAndId = new Map<String, Id>();

        for (Integer i = 0; i < lstUsers.size(); i++) {
            String groupName = 'Key Insights-' + lstUsers[i].FirstName + ' ' + lstUsers[i].LastName;
            if(groupName.length() > 39){
                groupName = groupName.substring(0,39);
            }
            Group grp = new Group();
            grp.Name = groupName;
            grp.DoesIncludeBosses = false; 
            grouplist.add(new Group(Name = groupName));
            groupsName.add(groupName);
            usersNameAndId.put(groupName, lstUsers[i].Id);
        }
        if(grouplist.size() > 0){
            upsert grouplist;
        }
        

        List<Group> insertedGroups = [SELECT id, Name, developername FROM Group WHERE name IN : groupsName];
        
        List<Id> groupsIds = new List<Id>();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        for (Integer i = 0; i < insertedGroups.size(); i++) {
            
            groupsIds.add(insertedGroups[i].Id);

            String nameOfUser = insertedGroups[i].Name;

            Id usrId = usersNameAndId.get(nameOfUser);
            
            groupMemberList.add(new GroupMember(UserOrGroupId = usrId, GroupId = insertedGroups[i].Id ));
           
        }
                
        if(!Test.isRunningTest()){
            upsert groupMemberList;
            ListView lwRecord = [select ID,Name,SobjectType,DeveloperName from ListView where SobjectType='Account' and DeveloperName='Key_Insights' limit 1];
            for (Integer i = 0; i < groupsIds.size(); i++) {
                SL_CloneListView.cloneListView(groupsIds[i], lwRecord.ID);
            }
        }
    }
}