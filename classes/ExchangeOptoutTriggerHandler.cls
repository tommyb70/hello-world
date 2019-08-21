public class ExchangeOptoutTriggerHandler {
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------
    // ExchangeOptout After Insert
    // 
	//-----------------------------------------------------------------------------------------------------------------------------------------------
    public static void ExchangeOptoutAfterInsert (List<ExchangeOptout__c> ExchangeOptouts)
    	{

            Set<String> Emails = new Set<String>();
            
            for (ExchangeOptout__c cEO : ExchangeOptouts)
                {    
                    if (cEO.Email__c != '')    
                    	{
                        Emails.add(cEO.Email__c);
                    	}
                }
            List<contact> ContactsToUpdate = new List<contact> ();
            
            List<contact> ContactsToOptOut = [select id, email from contact where email in : Emails];
            
            for (Contact cCont : ContactsToOptOut)
                {
                 ContactsToUpdate.add(new Contact(id=cCont.id,HasOptedOutOfEmail=true, EmailPreference__c='NEVER'));
                }
            
            List<ExchangeOptoutContact__c> ContactsToOptOutDetail = new List<ExchangeOptoutContact__c> ();
            
            for (ExchangeOptout__c cEO : ExchangeOptouts)
                {
                    for (contact mc : ContactsToOptOut) 
                        {
                            if (mc.email == cEO.Email__c)
                            {
                             ExchangeOptoutContact__c EOoC = new ExchangeOptoutContact__c(Contact__c = mc.id, ExchangeOptout__c=cEO.id);
                             ContactsToOptOutDetail.add(EOoC);
                            } 
                        }
                }
            
            if (!ContactsToUpdate.isEmpty())
            	{
                update ContactsToUpdate;    
            	}
            
            
            if (!ContactsToOptOutDetail.isEmpty())
            	{
                insert ContactsToOptOutDetail;    
            	}    

		}
    
}