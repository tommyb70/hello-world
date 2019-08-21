public without sharing class FinancialAccountTriggerHandler {
    
    static ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');    
  
    public static void TriggerAfterUpdate (  Map<Id,FinancialAccount__c> myNewFA, Map<Id,FinancialAccount__c> myOldFA) { 
         
      
         for( Id fa :myNewFA.keySet())
        { 
            FinancialAccount__c newValue = myNewFA.get(fa);
            if(myOldFA.containsKey(fa))
               {
                   FinancialAccount__c oldValue = myOldFA.get(fa);
                   if(oldValue.ViewableinCommunity__c !=  newValue.ViewableinCommunity__c)
                   {
                       if(newValue.ViewableinCommunity__c == false)
                       {
                           // remove all the manual sharing
                          system.debug ('-----------------------delete shate' + fa ); 
                          List<FinancialAccount__Share> sharesToDelete =
                          [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause, LastModifiedDate, LastModifiedById, IsDeleted 
                           FROM FinancialAccount__Share where ParentID=:fa and RowCause='Manual' ];
                          delete sharesToDelete;
                           
                       }
                       else
                       {
                               if(newValue.ViewableinCommunity__c == true)
                           {
                               // add all the sharing for Finacial account contact
                                Map<Id,FinancialAccountContact__c> clients = new Map<Id,FinancialAccountContact__c>([ SELECT Id, Name, Contact__r.Name, 
                                                                                                     Contact__r.Id, Financial_Account__c,
                                                                                                     Contact__c, 
                                                                                                     Type__c, Status__c, 
                                                                                                     View_Financial_Account_in_Community__c,
                                                                                                     ContactName__c 
                                                                                                     From  FinancialAccountContact__c 
                                                                                                     where Financial_Account__c=:fa
                                                                                                     and Status__c = 'Current' and View_Financial_Account_in_Community__c = true]);
                                List<Id> ContactList = new List<Id>();
                                for( FinancialAccountContact__c c :clients.values())
                                    { 
                                        ContactList.add(c.Contact__c);
                                    }
                               
                               List<User> users = [SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId, PortalRole, IsPortalEnabled FROM User
                                    where  ContactId=:ContactList
                                                  ];
                               // Create Share
                                 CreateShare(users,fa) ;                                                                                  
                           }
                       }
                   }
               }
               
        }
    }
//    
   
    public static void CreateShare(List<User> UserList, String AccountId){   
        system.debug ('-----------------------Create share user' + AccountId ); 
        List<FinancialAccount__Share> sharesToCreate = new List<FinancialAccount__Share>();
         for( User u :UserList)
        { 

        FinancialAccount__Share cs = new FinancialAccount__Share();
        
        cs.AccessLevel = 'Read';
        cs.ParentID = AccountId;
        cs.RowCause =Schema.FinancialAccount__Share.RowCause.Manual;
        cs.UserOrGroupId = u.Id;
        sharesToCreate.add(cs);   
        
        }
        
        if(!sharesToCreate.isEmpty())
        {
            upsert  sharesToCreate;
        }
    }
   
}