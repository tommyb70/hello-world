public class Util {
    
    //---------------------------------------------------------------------------------
    //Contents:
    // getCustomSettingProfileId(String) takes a profile name and returns the Id
    // getUserTerritoryMap(Set<Id>) takes a set of user Ids and returns a map of User Ids to User with territory info
    // getUserTerritoryMap() returns a map of User Ids to User with territory info (standard users only)
    // getUserTerritoryMapFields() returns the first part of a query (through the FROM clause) that will select all pertinent territory fields
    // getAccountFirmIdMap(Set<Id>) takes a set of account Ids and returns the firm (top level) for each of these in an Id map (account Id to firm Id)

    
    public static String getCustomSettingProfileId (String profilename){     
        Profile p = [SELECT Id, Name 
                     FROM Profile 
                     WHERE Name = :profilename LIMIT 1]; 
        Return p.Id;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    } 
    
    public static Map<Id,User> getUserTerritoryMap(Set<Id> userIdSet) {
        
        String userQuery = getUserTerritoryMapFields();
        userQuery = userQuery + ' WHERE Id IN :userIdSet ';
        
        List<User> userList = Database.query(userQuery);
        
        Map<Id,User> userMap = new Map<Id,User>();
        
        for (User u : userList) {
            userMap.put(u.Id,u);
        }
        
        return userMap;        
        
    }
    
    public static Map<Id,User> getUserTerritoryMap() {
        
        String standardUserType = 'Standard';
        String userQuery = getUserTerritoryMapFields();
        userQuery = userQuery + ' WHERE UserType = :standardUserType ';
        
        List<User> userList = Database.query(userQuery);
        
        Map<Id,User> userMap = new Map<Id,User>();
        
        for (User u : userList) {
            userMap.put(u.Id,u);
        }
        
        return userMap;
        
    }
    
    public static String getUserTerritoryMapFields() {
        
        String query = 'SELECT Id, Username, ActivityTerritoryParentId__c, ActivityTerritoryType__c, ActivityTerritoryName__c, ';
        query = query + ' ActivityTerritoryId__c,ActivityTerritoryMARSName__c,ActivityTerritoryRoleGroupId__c, ';
        query = query + ' ActivityTerritoryRoleId__c, ActivityChannelId__c,ActivityRegionDept__c, ActivityChannelName__c  FROM User ';
        return query;
    }
    
    public static Map<Id,Id> getAccountFirmIdMap(Set<Id> accountIdSet) {
        
        List<Account> acctList = [SELECT Id, Parent.Id, Parent.Parent.Id, Parent.Parent.Parent.Id
                                  FROM Account
                                  WHERE Id in: accountIdSet];
        
        Map<Id,Id> accountFirmIdMap = new Map<Id,Id>();
        
        for (Account a : acctList) {
            
            accountFirmIdMap.put(a.Id, a.Id);
            if (a.Parent.Id != null) accountFirmIdMap.put(a.Id, a.Parent.Id);
            if (a.Parent.Parent.Id != null) accountFirmIdMap.put(a.Id, a.Parent.Parent.Id);            
            if (a.Parent.Parent.Parent.Id != null) accountFirmIdMap.put(a.Id, a.Parent.Parent.Parent.Id);                        
            
        }
        
		return accountFirmIdMap;        
        
    }   
    
    public static Map<Id,Channel__c> getChannelMap() {
        
        Map<Id,Channel__c> channelMap = new Map<Id,Channel__c>([SELECT Id, FocusFirmField__c, RotationField__c, TierField__c, ZoneField__c
                                                                FROM Channel__c]);
        
        return channelMap;        
        
    }      
    
}