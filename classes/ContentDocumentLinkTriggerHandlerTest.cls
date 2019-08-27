@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
    @isTest static void testDocuSignAPI() { 
        // Set mock callout class          
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        Account acc=new Account(Name='Natixis'); insert acc; 
        
        Contact con = new Contact(LastName='Natixis',FirstName='Natixis',Email='natixis@natixis.com',AccountId=acc.Id,PWEmail__c='natixis@natixis.com'); insert con; 
        
        Id recTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId(); 
        
        Case cas = new Case(AccountId=acc.Id,ContactId=con.Id,RecordTypeId=recTypeIdCase,IsPrivateWealthCase__c=TRUE, Status='Needs Signature',Type='Account Opening'); 
        insert cas; 
        
        Signers__c sing = new Signers__c(Name='Natixis',EmailAddress__c='natixis@natixis.com',Case__c=cas.Id); insert sing; 
        
        Docusign_Settings__c docu = new Docusign_Settings__c(Name ='PWPortal',EmailBody__c='You have received a document from the Natixis Investment Portal to review and sign',EmailSubject__c='Documents for you to sign' 
                                                             ,End_Point__c='https://demo.docusign.net/restapi/v2/accounts/7b1892e3-2040-4603-b6b1-b9dabb617110/envelopes',IntegratorKey__c='TEST', 
                                                             Password__c='TEST',SigningGroupID__c='TEST',Username__c='TEST@mpa.natixis.com',
                                                             DSXPartnerApplication__c='DSFS 6.8',SendDocuSignMessageFromFiles__c = TRUE);
        insert docu; 
        
        ContentVersion cv = new ContentVersion();
        cv.versionData = Blob.valueOf('Unit Test Attachment Body');        
        cv.Description = 'test';
        cv.title = 'Unit Test Attachment'; 
        cv.IsMajorVersion = False;
        cv.pathOnClient = 'Unit Test Attachment';
        upsert cv;
        
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cl.LinkedEntityId = cas.Id;
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        Insert cl;
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorDocuSignAPI()); 
        ContentDocumentLinkTriggerHandler.docuSignPWCaseMessage(cl.ContentDocumentId);
        Test.stoptest(); 
    } 
    
}