public class CommunitiesEmailHelper {
    public class emailException extends Exception {}   
    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, 
                                          String templateApiName, ID targetObjId, 
                                          Id whatId,String FromEmail , String FromDisplayName,String Subject
                                         ) {
                                             //  templateId   must be ID of an Email template
                                             //  targetObjId must be a Contact, User, Lead Id -- also used in merge fields of template recipient.xxxx
                                             //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
                                             //  FromEmail    setting from custom setting
                                             //  bcc      not permitted when using templates
                                             
                                             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                             
                                             Id templateId;  
                                             try {templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;}
                                             catch (Exception e) {throw new emailException ('Unable to locate EmailTemplate using name: ' + templateApiName +   ' refer to Setup | Communications Templates ' + templateApiName);            }
                                             
                                             
                                             email.setToAddresses(toRecipients);
                                             email.setCcAddresses(ccRecipients);
                                             email.setTargetObjectId(whatId);    
                                             email.setTemplateId(templateId);
                                             //email.set(FromEmail);
                                             email.setReplyTo(FromEmail);
                                             email.setSenderDisplayName(FromDisplayName);   
                                             email.setSaveAsActivity(false);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users
                                             
                                             System.debug(LoggingLevel.INFO,'** entered sendTemplatedEmail, to:' + toRecipients + ' cc:' + ccRecipients +  ' templateId:' + templateId 
                                                          + ' tagetObjId:' + targetObjId  + ' FromEmail:' + FromEmail +  + ' UserId:' + whatId
                                                         );
                                             try {
                                                 if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                                                 return;
                                             }
                                             catch (EmailException e) {throw new emailException('sendTemplatedEmail error. ' + e.getMessage());}
                                             
                                         }  
    
    
    public static Messaging.SendEmailResult[]  sendTemplatedEmailByList(List<Messaging.SingleEmailMessage> emails, Boolean allOrNone ) {            
        try {       
            return  Messaging.sendEmail(emails,allOrNone);                       
        }
        catch (EmailException e) {  throw new emailException('sendTemplatedEmail error. ' + e.getMessage());  }
    }
    
    public  Static  void sendEmail(String[] toRecipients, String[] ccRecipients,
                                   String FromEmail , String FromDisplayName,String Msg,string Subject, boolean IsHtml)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toRecipients);
        mail.setCcAddresses(ccRecipients);
        mail.setReplyTo(FromEmail);
        mail.setSenderDisplayName(FromDisplayName);
        mail.setSubject(Subject);
        if(IsHtml == true) mail.setHTMLBody(Msg); 
        else mail.setPlainTextBody(Msg);
        try
        {
            if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch (EmailException e) {throw new emailException('SendEmail error. ' + e.getMessage());}
    }
    
    
    
}