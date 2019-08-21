@isTest
private class AccountTerritoryTriggerHandler_Test {
        /*
    static testMethod void deleteAccountShareTest() {

       Account a = new Account(MarsAccountId__c = 'OF123456', Name = 'TestAccount');
       insert a;
       system.debug('a.id: ' + a.Id);
       List<Territory__c> tl = new List<Territory__c>();
       for(Integer i=0; i< 3; i++) {
              Territory__c t = new Territory__c(TerritoryName__c = 'WHSE TERR' + i);
              insert t;
              system.debug('t.id: ' + t.Id);
              UserRole role = new UserRole(Name = t.TerritoryName__c, CaseAccessForAccountOwner = 'None',
                   ContactAccessForAccountOwner = 'None',OpportunityAccessForAccountOwner = 'None',DeveloperName = t.Id);
               insert role;
               Group g = new Group(Name = t.TerritoryName__c, DeveloperName = t.id);
               insert g;
              
              List<Group> grps = [select Id from Group where RelatedId =: role.Id and Type =: 'Role']; 
//            if(grsp.size() <= 0) throw new exception('No role group');
              t.GroupId__c = g.Id;
              t.RoleId__c = role.Id;
              t.RoleGroupId__c = grps[0].Id;
              update t;
              System.debug(t.Id + ' - ' + t.TerritoryName__c + ' - ' + t.GroupId__c + ' - ' + t.RoleId__c + ' - ' + t.RoleGroupId__c);
              tl.add(t);
       }
       List<AccountTerritory__c> atl = new List<AccountTerritory__c>();
       List<AccountShare> asl = new List<AccountShare>();
       for(Integer i=0; i<tl.size(); i++) { 
              Territory__c t = tl[i];           
              AccountTerritory__c atc = new AccountTerritory__c(Account__c = a.Id, Territory__c = t.Id);
              atl.add(atc);
              AccountShare ashare = new AccountShare(AccountId = a.Id, 
                                                       AccountAccessLevel = 'Edit',
                                                              OpportunityAccessLevel = 'Edit',
                                                ContactAccessLevel = 'None',
                                                UserOrGroupId = t.RoleGroupId__c);
              asl.add(ashare);
              ashare = new AccountShare(AccountId = a.Id, 
                                                       AccountAccessLevel = 'Edit',
                                                              OpportunityAccessLevel = 'Edit',
                                                ContactAccessLevel = 'None',
                                                UserOrGroupId = t.GroupId__c);
              asl.add(ashare);
       }
       insert atl;
       insert asl;
       AccountTerritory__c[] ata = [select Id, Account__c from AccountTerritory__c where Account__r.MarsAccountId__c =: 'OF123456'];            
       Set<Id> ids = new Set<Id>();
       for(AccountTerritory__c a1 : ata) ids.add(a1.Account__c);
        delete ata;
        
        AccountShare[] asl1 = [select Id from AccountShare where AccountId in :ids and RowCause = 'Manual'];
        System.assertEquals(0, asl1.size());
    }*/
}