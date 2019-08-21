public with sharing class TopProducers {
    
	List<Contact> contacts;

	public List<Contact> getContacts() {
		if(contacts == null) contacts = [select name , TranYTDPurchases__c , TranPYPurchases__c from contact where TranYTDPurchases__c != null order by TranYTDPurchases__c desc limit 15];
		return contacts;
	}

}