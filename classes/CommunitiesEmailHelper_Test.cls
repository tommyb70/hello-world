@isTest
private class CommunitiesEmailHelper_Test {
    
    
    @testSetup static void SetupTest() {        
        DataFactory.insertEstatementCommunityCustomSettings();
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
    }
    
    static testMethod void sendEmailTesting() {        
        
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
        String EmailSenderAddress = myCustomSetting.CommunitySenderEmail__c;
        String ExternalEmailTemplateDevName = myCustomSetting.ExternalEmailTemplate__c;  
        String CommunityInternalSender = myCustomSetting.CommunityInternalSender__c;
        String TestUserEmail = myCustomSetting.TestUserEmail__c;
        String ProfileForFAUser = myCustomSetting.ProfileForFAUser__c;
        String CommunitySenderDisplayName = myCustomSetting.CommunitySenderDisplayName__c;
        
        Id emailTemplateId =  [select id, name from EmailTemplate where developername = :ExternalEmailTemplateDevName].id;
        Map<Id,Profile> usermap = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where name =:ProfileForFAUser]);
        
        List<user> users = [select id,Email from user where profileId in:usermap.Keyset() LIMIT 5];    
        Test.startTest();
        for (User  u : users)
        {
            List<String> ToAddress = new List<String>(); ToAddress.add(u.Email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(ToAddress);   
            email.setCcAddresses(ToAddress);
            email.setTargetObjectId(u.Id);    
            email.setTemplateId(emailTemplateId);                   
            email.setReplyTo(EmailSenderAddress);
            email.setSenderDisplayName(CommunitySenderDisplayName);   
            email.setSaveAsActivity(false);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users                             
            CommunitiesEmailHelper.sendTemplatedEmail(ToAddress, ToAddress, 
                                                      ExternalEmailTemplateDevName,
                                                      u.Id, u.Id, EmailSenderAddress, 
                                                      CommunitySenderDisplayName, 'Statement Available');
            
            CommunitiesEmailHelper.sendEmail(ToAddress, ToAddress,
                                             EmailSenderAddress , CommunitySenderDisplayName,
                                             'Statement Available','Statement Available', true);
            
            CommunitiesEmailHelper.sendEmail(ToAddress, ToAddress,
                                             EmailSenderAddress , CommunitySenderDisplayName,
                                             'Statement Available','Statement Available', false);
            
            
        }
        
        Test.stopTest();
        
    }
    
    
    static testMethod void CommunitiesEmailHelperTesting() {        
        
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        string EStatementFirmName = myCustomSetting.EndClientCommunityAccountName__c;
        String EmailSenderAddress = myCustomSetting.CommunitySenderEmail__c;
        String ExternalEmailTemplateDevName = myCustomSetting.ExternalEmailTemplate__c;  
        String CommunityInternalSender = myCustomSetting.CommunityInternalSender__c;
        String TestUserEmail = myCustomSetting.TestUserEmail__c;
        String ProfileForFAUser = myCustomSetting.ProfileForFAUser__c;
        String CommunitySenderDisplayName = myCustomSetting.CommunitySenderDisplayName__c;
        
        Id emailTemplateId =  [select id, name from EmailTemplate where developername = :ExternalEmailTemplateDevName].id;
        Map<Id,Profile> usermap = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where name =:ProfileForFAUser]);
        
        List<user> users = [select id,Email from user where profileId in:usermap.Keyset() LIMIT 50];    
        Test.startTest();
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        for (User  u : users)
        {
            List<String> ToAddress = new List<String>();
            ToAddress.add(u.Email);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(ToAddress);                   
            email.setTargetObjectId(u.Id);    
            email.setTemplateId(emailTemplateId);                   
            email.setReplyTo(EmailSenderAddress);
            email.setSenderDisplayName(CommunitySenderDisplayName);   
            email.setSaveAsActivity(false);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users                  
            emailMessageList.Add(email);
        }
        Messaging.SendEmailResult[] allornone =  CommunitiesEmailHelper.sendTemplatedEmailByList(emailMessageList,true);
        // Add invalid email address
        List<String> ToAddress = new List<String>();
        ToAddress.add('test.Test.com=test');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(ToAddress);                             
        email.setTemplateId(emailTemplateId);                   
        email.setReplyTo(EmailSenderAddress);
        email.setSenderDisplayName(CommunitySenderDisplayName);   
        email.setSaveAsActivity(false);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users                  
        emailMessageList.Add(email);
        Messaging.SendEmailResult[] results =  CommunitiesEmailHelper.sendTemplatedEmailByList(emailMessageList,false);
        if (results !=  null && results.size() > 0) {
            for (Messaging.SendEmailResult  r : results)
            { 
                if(!r.isSuccess())
                {
                    Messaging.SendEmailError[] errArr = r.getErrors();                      
                    for(Messaging.SendEmailError er :errArr)
                    {
                        System.Debug('error - ' + er.getTargetObjectId()+' ' +  er.getMessage()); 
                    }
                }
            }                           
        }      
        Test.stopTest();
        
    }
}