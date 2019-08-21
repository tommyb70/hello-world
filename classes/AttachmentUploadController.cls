public with sharing class AttachmentUploadController {

  public Attachment attachment {
  	get {
      	if (attachment == null)
        	attachment = new Attachment();
      		return attachment;
    	}
  set;
  }

  public PageReference cancel() {

	PageReference BackTo = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
    BackTo.getParameters().put('retURL','/' + ApexPages.currentPage().getParameters().get('retURL'));
    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return BackTo;
  }

    
  public PageReference upload() {

    attachment.OwnerId = UserInfo.getUserId();
    attachment.ParentId = ApexPages.currentPage().getParameters().get('id');
    attachment.IsPrivate = false;

    try {
      insert attachment;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
      return null;
    } finally {
      attachment = new Attachment(); 
    }
	PageReference BackTo = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
    BackTo.getParameters().put('retURL','/' + ApexPages.currentPage().getParameters().get('retURL'));
    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return BackTo;
  }

}