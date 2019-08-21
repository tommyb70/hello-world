public  class UserHelperClass {
      
    public Static boolean IsVip(String UserID)
      {
            system.debug('------' + UserID);
            boolean VIP = false;
            List<User> users = [select VIP__c from User where id =: UserID]; 
            if(users != null && users.size() > 0)    
            {        
            User u = users.get(0);
            VIP  = u.VIP__c;
            }
            return VIP ;
         
      }
      
      // use in task page for figure out the activity type and sub type based on logged in user
      public Static boolean IsIC_Inbound(String UserID)
      {
          Boolean ic = false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
            if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {
            // if( zones[0].Zone__c == 5 || zones[0].Zone__c == 6)   ic= true;
             if(zones[0].Name.startsWithIgnoreCase('IC')  || zones[0].Name.startsWithIgnoreCase('Inbound') || (zones[0].Name.startsWithIgnoreCase('RD')))
             ic= true;
            }
            }
          return ic;         
      }
      
      
                           
    public Static boolean IsIC(String UserID)
      {
          Boolean ic = false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
            if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {
                if(zones[0].Name.startsWithIgnoreCase('IC') )  ic= true;
             }
            /* if (( zones[0].Zone__c == 5) ||  ( zones[0].Zone__c == 7) || ( zones[0].Zone__c == 8) ||  ( zones[0].Zone__c == 9) || ( zones[0].Zone__c == 10) )
              ic= true;
             }*/
            }
          return ic;         
      }
      
          
     public Static boolean IsInbound(String UserID)
      {
          Boolean inbound= false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
           if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {
             if(  zones[0].Name.startsWithIgnoreCase('Inbound') ) inbound= true;
             }
            }
          return inbound;         
      }
      
      
      
          
    public Static boolean IsRD(String UserID)
      {
          Boolean rd= false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
            if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {
             //if( zones[0].Zone__c == 2 || zones[0].Zone__c == 3)   rd= true;
             if (( zones[0].Zone__c == 2) ||  ( zones[0].Zone__c == 3) || ( zones[0].Zone__c == 11) ||  ( zones[0].Zone__c == 12) ) rd= true;
             }
            }
          return rd;         
      }
      
          
     public Static boolean IsMRD(String UserID)
      {
          Boolean mrd= false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
           if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {
             //if( zones[0].Zone__c == 1)   mrd= true;
             if (( zones[0].Zone__c == 1) ||  ( zones[0].Zone__c == 18) || ( zones[0].Zone__c == 19) || 
            ( zones[0].Zone__c == 20) ||   ( zones[0].Zone__c == 21) ||   ( zones[0].Zone__c == 22) ||   ( zones[0].Zone__c == 23) )
              mrd= true;
             }
            }
          return mrd;         
      }
      
      public Static boolean IsMD(String UserID)
      {
          Boolean md= false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
           if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {            
             if (( zones[0].Zone__c == 24)  )
              md= true;
             }
            }
          return md;         
      }
      
       public Static boolean IsDir(String UserID)
      {
          Boolean dir= false;
           system.debug('------' + UserID);
            List<User> users = [select ActivityZoneId__c from User where id =: String.escapeSingleQuotes(UserID)];     
           if(users != null && users.size() > 0)    
            {
             List<Zone__c> zones = [select id,Name,Zone__c from Zone__c where id =: users[0].ActivityZoneId__c];    
             if(zones != null && zones.size() > 0)    
            {            
             if (( zones[0].Zone__c == 13)  || ( zones[0].Zone__c == 14) || ( zones[0].Zone__c == 15)|| ( zones[0].Zone__c == 16) || ( zones[0].Zone__c == 17))
              dir= true;
             }
            }
          return dir;         
      }
}