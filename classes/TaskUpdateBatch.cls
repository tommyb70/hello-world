global class TaskUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{

    public integer CScount = 0;
    // 'Select id, Current_Owner_Channel__c, OwnerCurrentTerritory__c, OwnerCurrentZoneId__c, RepCurrentBPLStatus__c, contact__r.BPL__c, Account__r.Parent.FocusFirmFS__c, Account__r.Parent.FocusFirmIAG__c, Account__r.Parent.FocusFirmRS__c, Account__r.Parent.FocusFirmWHSE__c, Contact__r.PROTierFS__c, Contact__r.PROTierIAG__c, Contact__r.PROTierRS__c, Contact__r.PROTierWHSE__c, Contact__r.PROZoneFS__c, Contact__r.PROZoneIAG__c, Contact__r.PROZoneRS__c, Contact__r.PROZoneWHSE__c, OwnerChannelId__c from ActivityContact__c ';
	public String query ;
    public static Map<id,Channel__c> ChannelMap {
          get {
               if (ChannelMap == null) {
                    ChannelMap = new Map<id,Channel__c>([Select Id, Name, TierField__c, ZoneField__c, FocusFirmField__c from Channel__c limit 20]);
                    }
               return ChannelMap;
          }
          set;
     } 

    global Database.querylocator start(Database.BatchableContext BC){   
            return Database.getQueryLocator(query);
    		}

   	global void execute(Database.BatchableContext BC, List<ActivityContact__c> scope)
   			{ 
            List<ActivityContact__c> reprocessedACs = new List<ActivityContact__c>();
                
            for (ActivityContact__c curAC : scope)
            	{
                CScount = CScount + 1;
                ActivityContact__c reprocessedAC = new ActivityContact__c(); 
                
                reprocessedAC.id = curAC.Id;  
                reprocessedAC.OwnerChannel__c = curAC.Current_Owner_Channel__c;   
                reprocessedAC.Channel__c = curAC.OwnerChannelId__c;
				reprocessedAC.OwnerTerritory__c = curAC.OwnerCurrentTerritory__c;
				reprocessedAC.OwnerZone__c = curAC.OwnerCurrentZoneId__c;
				reprocessedAC.RepBPL__c = curAC.RepCurrentBPLStatus__c;              

               	String UserPrimaryChannelId = '';
               	UserPrimaryChannelId = curAC.OwnerChannelId__c;
               	String FieldName = '';
               if (UserPrimaryChannelId <> null)   
                      {        
                       FieldName = (String)ChannelMap.get(UserPrimaryChannelId).FocusFirmField__c; 
                       if (FieldName <> null)   
                            {  
                            reprocessedAC.ChannelFocusFirm__c = (Boolean)curAC.getSobject('Account__r').getSobject('Parent').get(FieldName);
                            } 
                       FieldName = (String)ChannelMap.get(UserPrimaryChannelId).TierField__c; 
                       if (FieldName <> null)   
                            {  
                            reprocessedAC.RepTier__c = (String)curAC.getSobject('Contact__r').get(FieldName);
                            } 
                       FieldName = (String)ChannelMap.get(UserPrimaryChannelId).ZoneField__c; 
                       if (FieldName <> null)   
                            {  
                            reprocessedAC.RepZone__c = (ID)curAC.getSobject('Contact__r').get(FieldName);
                            } 
                       }   
               reprocessedACs.add(reprocessedAC);   
               } 

		if (!reprocessedACs.isEmpty())
        		{
           		update reprocessedACs;
           		}  
           }
    
	global void finish(Database.BatchableContext BC)
			{
            /*try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'dat@ngam.natixis.com'};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('dat@ngam.natixis.com');
			mail.setSenderDisplayName('DAT');
			mail.setSubject('ActivityContact__c processing Completed');
			mail.setPlainTextBody('ActivityContact__c processed: ' + CSCount + '\n\nSOQL source :' + query);
          if (!Test.IsRunningTest())  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
           }
           catch (Exception e) {
           System.debug('Exception: ' + e);            
           }  */  
         }
 
}