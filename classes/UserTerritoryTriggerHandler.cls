public class UserTerritoryTriggerHandler {
    
    public static boolean run = true;
    
    public static boolean runOnce(){
    	if(run)
        	{
     		run=false;
     		return true;
    		}else{
        return run;
    	}
    }

    
    public static void UserTerritoryAfterDelete (List<UserTerritory__c> myUserTerrs){
            List<User> UsersToUpdate = new List<User>();
            
            Map <String,id> AllGrpMember = new Map<String,id>();   
                
            for(UserTerritory__c currUserTerr : myUserTerrs)   
                {       
                if(currUserTerr.PrimaryTerritory__c)   
                    	{
                    	User usr = new User(Id=currUserTerr.user__c,RoleProxy__c=null, ZoneLabel__c= '',ZoneNumber__c= null, Zoneid__c = '',PrimaryTerritory__c='', PrimaryTerritoryId__c='', PrimaryChannel__c='', PrimaryChannelid__c='');   
                    	if(currUserTerr.ActivityTerritory__c)
                        	{
                            usr.ActivityChannelId__c = '';
                            usr.DefaultTerritory__c= '';
                            usr.ActivityChannelName__c ='';
                            usr.ActivityTerritoryId__c ='';
                            usr.ActivityTerritoryName__c ='';
                            usr.ActivityZoneId__c ='';
                            usr.ActivityTerritoryMARSName__c ='';    
                            usr.DefaultTerritoryMARSName__c = '';  
                            usr.ActivityTerritoryType__c = '';
                            usr.ActivityTerritoryParentId__c = '';
                            usr.ActivityTerritoryParentMARSName__c = '';
                            usr.ActivityTerritoryParentName__c = '';    
                            usr.ActivityTerritoryParentType__c = '';
                            usr.ActivityTerritoryRoleId__c = '';    
                            usr.ActivityTerritoryRoleGroupId__c = '';    
                        	}
                        UsersToUpdate.add(usr);
                        }   
                }
        
            if (!UsersToUpdate.isEmpty())
                {
 				update UsersToUpdate;
                }
            }
    
    
    public static void UserTerritoryAfterUpdate (List<UserTerritory__c> myUserTerrs){
        	// Only Primary Territory checkbox can be updated on a UserTerritory__c
   			if(runOnce())
            	{ 
                Set<id> PrimaryUserTerritories = new Set<id>();
                Set<id> UsersWithPrimaryTerritories = new Set<id>();
                List<UserTerritory__c> UserTerritoriesNotPrimaryAnymore = new List<UserTerritory__c>();
                List<User> UsersToUpdate = new List<User>();
            
                for (UserTerritory__c currUserTerr : [select id, 
															ownerid, 
                                                      		RoleId__c, 
                                                      		Territory__r.Channel__r.DefaultProfileId__c, 
                                                      		Zoning__c, 
                                                      		Zoning__r.Name, 
                                                      		Zoning__r.zone__c,
                                                      		Territory__r.name,
                                                      		Territory__c,
                                                      		Territory__r.Channel__r.name,
                                                      		Territory__r.Channel__r.id
                                                      		from UserTerritory__c where id in: myUserTerrs and PrimaryTerritory__c=true])
                    {
                    //system.debug('DEBUG ME------------------' + currUserTerr.Territory__r.name + ' ' + currUserTerr.Territory__c + ' ' + currUserTerr.Territory__r.Channel__r.name + ' ' + currUserTerr.Territory__r.Channel__r.id) ; 
                    
                    PrimaryUserTerritories.add(currUserTerr.id);
                    UsersWithPrimaryTerritories.add(currUserTerr.ownerid);
                    User usr = new User(	Id=currUserTerr.ownerid, 
                                        	RoleProxy__c=currUserTerr.RoleId__c, 
                                        	ProxyProfileId__c = currUserTerr.Territory__r.Channel__r.DefaultProfileId__c, 
                                        	ZoneID__c = currUserTerr.Zoning__c,
                                        	ZoneLabel__c= currUserTerr.Zoning__r.Name, 
                                        	ZoneNumber__c= currUserTerr.Zoning__r.zone__c, 
                                        	PrimaryTerritory__c=currUserTerr.Territory__r.name,
                                        	PrimaryTerritoryId__c=currUserTerr.Territory__c,
                                        	PrimaryChannel__c=currUserTerr.Territory__r.Channel__r.name,
                                        	PrimaryChannelid__c=currUserTerr.Territory__r.Channel__r.id);   
                    UsersToUpdate.add(usr);
                    }
            
                for (UserTerritory__c myUserTerritory : [select id from UserTerritory__c where ownerid in : UsersWithPrimaryTerritories and id not in:PrimaryUserTerritories and PrimaryTerritory__c=true])
                    {
                    UserTerritoriesNotPrimaryAnymore.add(new UserTerritory__c(id=myUserTerritory.id, PrimaryTerritory__c=false));
                    }
            
                if (!UserTerritoriesNotPrimaryAnymore.isEmpty())
                    {
                    update UserTerritoriesNotPrimaryAnymore;
                    } 
                if (!UsersToUpdate.isEmpty())
                    {
                    update UsersToUpdate;
                    } 
                    
                }
    }
    
    public static void UserTerritoryBeforeInsert (List<UserTerritory__c> myUserTerrs){
		for(UserTerritory__c currUserTerr : myUserTerrs)
       	 	{
            // Making Sure ownerid and user__c are same
			currUserTerr.ownerid=currUserTerr.user__c;  
            currUserTerr.PrimaryTerritory__c = currUserTerr.ActivityTerritory__c;
            }
    	}
        
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // After Inserting UserTerritory__c
    // If inserting where ActivityTerritory__c  = true, then assumption is that PrimaryTerritory__c = true as well.
    // Will grab all the UserTerritory__c where ActivityTerritory__c=false to unprime them
	//-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void UserTerritoryAfterInsert (List<UserTerritory__c> myUserTerrs){
        List<User> UsersToUpdate = new List<User>();
        Set<id> UserIds = new Set<id>();
        
        for(UserTerritory__c currUserTerr : [select id, Territory__r.RoleGroupId__c, 
                                             ActivityTerritory__c,Territory__r.ParentTerritory__r.TerritoryType__c,
                                             Territory__r.ParentTerritory__c,Territory__r.ParentTerritory__r.Name,
                                             Territory__r.ParentTerritory__r.TerritoryName__c,name, user__c, 
                                             territory__c, Territory__r.RoleId__c,Territory__r.TerritoryType__c,
                                             RoleId__c, Territory__r.TerritoryName__c, Territory__r.Channel__r.DefaultProfileId__c, 
                                             TerrGroupId__c, PrimaryTerritory__c, Zoning__c, Territory__r.name, 
                                             Territory__r.Channel__r.name, Territory__r.Channel__r.id, ownerid, 
                                             Zoning__r.Name,Zoning__r.zone__c  from UserTerritory__c where id in: myUserTerrs])
        	{
            if(currUserTerr.ActivityTerritory__c)   
        		{
                UserIds.add(currUserTerr.user__c);
                //system.debug('currUserTerr.user__c' + currUserTerr.user__c);
                User usr = new User(Id=currUserTerr.user__c,
                                    RoleProxy__c=currUserTerr.RoleId__c,
                                    ProxyProfileId__c = currUserTerr.Territory__r.Channel__r.DefaultProfileId__c,
                                    ZoneID__c = currUserTerr.Zoning__c,
                                    ZoneLabel__c= currUserTerr.Zoning__r.Name,
                                    ZoneNumber__c= currUserTerr.Zoning__r.zone__c,
                                    PrimaryTerritory__c=currUserTerr.Name,
                                    PrimaryTerritoryId__c=currUserTerr.Territory__c,
                                    PrimaryChannel__c=currUserTerr.Territory__r.Channel__r.name,
                                    PrimaryChannelid__c=currUserTerr.Territory__r.Channel__r.id,
                                    DefaultTerritory__c = currUserTerr.Territory__r.Name,
                                    DefaultTerritoryMARSName__c = currUserTerr.Territory__r.TerritoryName__c,
                    				ActivityChannelId__c = currUserTerr.Territory__r.Channel__r.id,
                    				ActivityChannelName__c = currUserTerr.Territory__r.Channel__r.name,
                    				ActivityTerritoryId__c = currUserTerr.Territory__c,
                    				ActivityTerritoryName__c = currUserTerr.Territory__r.Name,
                                    ActivityTerritoryMARSName__c = currUserTerr.Territory__r.TerritoryName__c,
                                    ActivityTerritoryType__c = currUserTerr.Territory__r.TerritoryType__c,
                    				ActivityZoneId__c = currUserTerr.Zoning__c,
                                    ActivityTerritoryParentId__c = currUserTerr.Territory__r.ParentTerritory__c,
                            		ActivityTerritoryParentMARSName__c = currUserTerr.Territory__r.ParentTerritory__r.TerritoryName__c,
                            		ActivityTerritoryParentName__c = currUserTerr.Territory__r.ParentTerritory__r.Name,    
                            		ActivityTerritoryParentType__c = currUserTerr.Territory__r.ParentTerritory__r.TerritoryType__c,
                    				ActivityTerritoryRoleGroupId__c = currUserTerr.Territory__r.RoleGroupId__c,
                    				ActivityTerritoryRoleId__c = currUserTerr.Territory__r.RoleId__c);
                    			
                    
                UsersToUpdate.add(usr);
                }
            }
        
        if (!UsersToUpdate.isEmpty())
        	{ 
            //system.debug ('Came here');
            update UsersToUpdate;
        	}
        
        
        // This will grab all the UserTerritory__c where ActivityTerritory__c=false to unprime them
        List<UserTerritory__c> UserTerritoryToUnprime = new List<UserTerritory__c>([select id from UserTerritory__c where ActivityTerritory__c=false and User__c in: UserIds]);
        
        List<UserTerritory__c> ut = new List<UserTerritory__c>();
        
        for (UserTerritory__c curUserTerr : UserTerritoryToUnprime)
        	{
            ut.add(new UserTerritory__c(id=curUserTerr.id,ActivityTerritory__c=false,PrimaryTerritory__c=false));
        	}
        //This will update the UserTerritory__c records @future, allowing to get out of the runtime context.
		//system.debug('ut.size()' + ut.size());
        Async.updateSObjects(Async.prepare(ut));

    	}
    

    /*

    public static void UserTerritoryAfterInsert (List<UserTerritory__c> myUserTerrs){
   			if(runOnce())
                {   
                List<User> UsersToUpdate = new List<User>();
                List<UserTerritory__c> UserTerrToUpdate = new List<UserTerritory__c>();
                //List<GroupMember> MemberstoCreate = new List<GroupMember>();
                       
                for(UserTerritory__c currUserTerr : [select id, ActivityTerritory__c,name, user__c, territory__c, RoleId__c, Territory__r.Channel__r.DefaultProfileId__c, TerrGroupId__c, PrimaryTerritory__c, Zoning__c, Territory__r.name, Territory__r.Channel__r.name, Territory__r.Channel__r.id, ownerid, Zoning__r.Name,Zoning__r.zone__c  from UserTerritory__c where id in: myUserTerrs])
                    {
                    UserTerritory__c UserTerr = new UserTerritory__c(id=currUserTerr.id, ownerid=currUserTerr.user__c); 
                    UserTerrToUpdate.add(UserTerr); 
                    //system.debug(currUserTerr.PrimaryTerritory__c);
                    if(currUserTerr.PrimaryTerritory__c)   
                        {
                        User usr = new User(Id=currUserTerr.user__c,RoleProxy__c=currUserTerr.RoleId__c, ProxyProfileId__c = currUserTerr.Territory__r.Channel__r.DefaultProfileId__c , ZoneID__c = currUserTerr.Zoning__c ,ZoneLabel__c= currUserTerr.Zoning__r.Name, ZoneNumber__c= currUserTerr.Zoning__r.zone__c, PrimaryTerritory__c=currUserTerr.Territory__r.name,PrimaryTerritoryId__c=currUserTerr.Territory__c ,PrimaryChannel__c=currUserTerr.Territory__r.Channel__r.name,PrimaryChannelid__c=currUserTerr.Territory__r.Channel__r.id);   
                    	// Activity Tagging
                        if(currUserTerr.ActivityTerritory__c)   
                        	{
                            usr.ActivityChannelId__c = currUserTerr.Territory__r.Channel__r.id;
                            usr.ActivityChannelName__c = currUserTerr.Territory__r.Channel__r.name;
                            usr.ActivityTerritoryId__c = currUserTerr.Territory__c;
                            usr.ActivityTerritoryName__c = currUserTerr.Territory__r.name;
                            usr.ActivityZoneId__c = currUserTerr.Zoning__c;
                            }
                        UsersToUpdate.add(usr);
                        }  
                    }
                List<UserTerritory__c> RelatedUTRecords = [select id from UserTerritory__c where id not in: myUserTerrs and user__c in: UsersToUpdate];
                system.debug('RelatedUTRecords.size' + RelatedUTRecords.size());
                List<UserTerritory__c> UnPrime = new List<UserTerritory__c>();
                
                for(UserTerritory__c currUserTerr : RelatedUTRecords)
                    {
                    UserTerritory__c NotPrimaryUT = new UserTerritory__c(id=currUserTerr.id, PrimaryTerritory__c=false); 
                    UnPrime.add(NotPrimaryUT);    
                    }	
                
                if (!UnPrime.isEmpty())
                    {
                    update UnPrime;
                    }   
            
                if (!UsersToUpdate.isEmpty())
                    { 
                    update UsersToUpdate;
                    }
                if (!UserTerrToUpdate.isEmpty())
                    {
                    update UserTerrToUpdate; 
                    }
                }
            } */

     
}