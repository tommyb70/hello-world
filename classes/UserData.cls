public with sharing class UserData {
      
    public boolean IsVip{
        get{
        system.debug('------' + UserInfo.getUserId());
            List<User> users = [select VIP__c from User where id =: UserInfo.getUserId()];
            
            //if (user.size() > 0) {
                User u = users.get(0);
                return u.VIP__c;
            //}
           // else return false;
          }
      set;
    }
    
     public boolean IsMD {
         get {
             Boolean md= false;
             system.debug('------' + UserInfo.getUserId());
             List<User> users = [select ActivityZoneId__c from User where id =:UserInfo.getUserId()];    
         
             if(users != null && users.size() > 0) {
                 List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
                 if(zones != null && zones.size() > 0) {            
                     if (zones[0].Name == 'MD')
                     md= true;
                 }
             }
             return md;         
          }
          set;      
    }
}