public with sharing class UserTerritoryPicklist
{
public id PrimaryTerritory {get; set;}
public String PrimaryTerritoryName{get; set;}
public String ViewAllPSId = '0PSF0000000XyKS';
//public String ViewAllPSId = '0PSM00000000R9P';    

public String VieAllLabel{
    get {
        Integer VA = [select count() from PermissionSetAssignment where PermissionSetId=: ViewAllPSId and AssigneeId=: UserInfo.getUserId()];
        if (VA>0)
        	{
            VieAllLabel = 'View My Territory Only';    
            }
       	else
        	{
            VieAllLabel = 'View All Territories';       
            }
        return VieAllLabel;
    }
	set;
    
}
    
    
public boolean ShowMe{
    get{
        Integer Utc = [select count() from UserTerritory__c where ownerid =: UserInfo.getUserId()];
        if (Utc > 1)
        	{
            ShowMe = true;   
            }
        else
        	{
             ShowMe = false;
            }
        return ShowMe;
    	}
	set;
}     

public UserTerritoryPicklist()
		{
        List<UserTerritory__c> myDefaultTerrs = [select id, Territory__r.id, Territory__r.name from UserTerritory__c where PrimaryTerritory__c=true and ownerid =: UserInfo.getUserId() ORDER BY Territory__r.TerritoryType__c, Territory__r.Name];    
     	if (myDefaultTerrs.size()>0)
        	{
            UserTerritory__c DefaultTerr = myDefaultTerrs.get(0);
            PrimaryTerritory = DefaultTerr.Territory__r.id;
            PrimaryTerritoryName = DefaultTerr.Territory__r.name;       
            system.debug('-----------------' + PrimaryTerritory + '---' + PrimaryTerritoryName );
            }
		}   

public List<SelectOption> getUserTerritory()
	{
  	List<SelectOption> options = new List<SelectOption>();
  	List<UserTerritory__c> utlist  = new List<UserTerritory__c>();
  	utlist = [Select Id, TerritoryName__c, Territory__r.id, primaryterritory__c FROM UserTerritory__c where ownerid =: UserInfo.getUserId() order by primaryterritory__c desc ,TerritoryName__c ];
    for (Integer j=0;j<utlist.size();j++)
    	{
        Boolean SelectedTerr=false;
        //system.debug(utlist[j].Territory__r.id + '-------' + PrimaryTerritory);
         options.add(new SelectOption(utlist[j].id,utlist[j].TerritoryName__c));
      	}   
  return options;
}

public void NewDef()
    {    
    UserTerritory__c ut = new UserTerritory__c(id=PrimaryTerritory, PrimaryTerritory__c=true) ;
    update ut;
    }
    
public void ViewAll()
	{
	List<PermissionSetAssignment> myPS = [select id from PermissionSetAssignment where PermissionSetId=: ViewAllPSId and AssigneeId=: UserInfo.getUserId()];
    if (myPS.isEmpty())
    	{
        PermissionSetAssignment ViewAllPS = new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId= ViewAllPSId);
    	insert ViewAllPS;   
        }
    else
    	{
        delete myPS[0];
        }
	}

    
    
}