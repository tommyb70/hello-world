public class ContactExtension {
    private final Account acct;
    
    public ContactExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

    public List<Contact> getContacts() {       
    	List<Contact> ceList = [SELECT PrimaryContact__c, Name, Phone, Email, RoleMultiSelect__c, 
                            		CommentsModified__c 
                            		FROM Contact 
                                    where Account.Id =: acct.Id limit 5];
        return ceList;
     }
}