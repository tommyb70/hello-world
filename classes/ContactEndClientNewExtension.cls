public class ContactEndClientNewExtension {
    
    private final Contact nContact;
    private ApexPages.StandardController stdController;
    
    public String errorMessage { get; set; }
    //public String retURL {get; set;}
    
    public ContactEndClientNewExtension(ApexPages.StandardController stdController) {
        this.nContact = (Contact)stdController.getRecord();
        this.stdController = stdController;
    }
    
    public PageReference SaveEndClient() {
        
        Id endClientRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        try {
            nContact.RecordTypeId = endClientRecordTypeId;
            insert nContact;
        }
        
        catch(System.Exception ex) {
            errorMessage = ex.getMessage(); ApexPages.addMessages(ex); return null;
        }

        return nextPage();
    }
    
    public PageReference nextPage() {
        PageReference nextPage;
        if (!String.isBlank(nContact.Id)) {
            nextPage = new ApexPages.StandardController(nContact).view();
        } else {
            nextPage = null;
        }
        return nextPage;
    }    
    
    
}