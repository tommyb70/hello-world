public class ContentDocumentLinkTriggerHandler {
    
    public static void docuSignPWCase(List<ContentDocumentLink> myCDL) {
        
        Docusign_Settings__c docuSignSettings = Docusign_Settings__c.getValues('PWPortal');
        Boolean sendMessage = FALSE;
        
        if (docuSignSettings != null) {
        	sendMessage = docuSignSettings.SendDocuSignMessageFromFiles__c;
        }
        
        if (sendMessage) {
            
            Map<Id,Id> CaseCVIdMap = new Map<Id,Id>();
            Id PWRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId();
            
            for (ContentDocumentLink cdl : myCDL) {
                system.debug('this is a ' + cdl.LinkedEntityId.getSObjectType().getDescribe().getName());
                if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case') {
                    CaseCVIdMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                }
                
            }
            
            if (!CaseCVIdMap.isEmpty()) {
                for (Case pwc : [SELECT Id
                                 FROM Case
                                 WHERE RecordTypeId = :PWRecordTypeId
                                 AND Id IN :CaseCVIdMap.keySet()
                                 AND Status = 'Needs Signature']) {
                                     Id docId = CaseCVIdMap.get(pwc.Id);
                                     docuSignPWCaseMessage(docId); 
                                 }
            }
        }
    }
    
    @future (callout=true) 
    public static void docuSignPWCaseMessage(Id docId){ 
        
        Docusign_Settings__c docuSignSettings = Docusign_Settings__c.getValues('PWPortal'); 
        
        
        
        Id PWRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Private Wealth Portal').getRecordTypeId();
        Id CaseId;
        
        for (ContentDocumentLink cdl : [SELECT ContentDocument.Title, ContentDocument.FileExtension, 
                                        ContentDocumentId, LinkedEntityId
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId = :docId]) {
                                            if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case') {
                                                CaseId = cdl.LinkedEntityId;
                                            }
                                        }
        
        ContentVersion cv = [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion
                             WHERE IsLatest = TRUE
                             AND ContentDocumentId = :docId
                             LIMIT 1];
        
        if (!cv.Title.contains('_Completed')) 
        {
            String attachmentName = cv.Title + '.' + cv.FileExtension;
            
            Case PWCase = [SELECT Id, Status, Type, ContactId, ContactEmail__c, Contact.PWEmail__c, Contact.Full_Name_Plain__c 
                           FROM Case 
                           WHERE Id = :caseId 
                           LIMIT 1];
            
            String passString = '<DocuSignCredentials><Username>'+ docuSignSettings.Username__c 
                + '</Username><Password>' + docuSignSettings.Password__c 
                + '</Password><IntegratorKey>' + docuSignSettings.IntegratorKey__c 
                + '</IntegratorKey></DocuSignCredentials>'; 
            
            String jsonstring = json.serialize(passString); 
            
            //MyBoundary - used to indicate benging/end of document in multi-part request 
            String contentType = '\r\n--myBoundary'+'\r\n'+'Content-Type:application/octet-stream'+ '\r\n'+ 
                'Content-Transfer-Encoding: base64'+'\r\n'+'Content-Disposition:attachment; '+'filename=\"contract.pdf\";'+ 
                'documentid=1 '+'\r\n\r\n\r\n'; 
            
            String envelop = createDocuSignPWCaseJSONString(PWCase, docuSignSettings, attachmentName); 
            
            System.debug('request body => '+envelop); 
            String envEOF = '\r\n'+'--myBoundary--'; 
            Http httpProtocol = new Http(); 
            HttpRequest request = new HttpRequest(); 
            String endpoint = docuSignSettings.End_Point__c; 
            request.setEndPoint(endpoint); 
            request.setMethod('POST'); 
            request.setHeader('Accept', 'application/json'); 
            request.setHeader('X-DocuSign-Authentication', passString); 
            request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary'); 
            
            String bcontent = EncodingUtil.base64Encode(cv.versionData); 
            request.setHeader('content-length', String.valueOf(bcontent.length())); 
            
            //Body 
            String cheader = '\r\n--myBoundary'+'\r\n'+' Content-Type: application/json'+ '\r\n'+' Content-Disposition: form-data'+ '\r\n'+'\r\n'; 
            request.setBody(cheader+''+envelop+'\r\n'+contentType+'\r\n'+bcontent+'\r\n'+envEOF); 
            System.debug('Request Body = '+cheader+''+envelop+'\r\n'+contentType+'\r\n'+bcontent+'\r\n'+envEOF); 
            HttpResponse response1 = httpProtocol.send(request); 
            System.debug('response1 =>'+response1.getBody()); 
            JSONParser parse = JSON.createParser(response1.getBody()); 
            system.debug('##############'+parse); 
            EnvResponse envstat = (EnvResponse)parse.readValueAs(EnvResponse.class); 
            System.debug('De-Serialized class is envstats => '+envstat); 
            
        } 
    }
    
    //Util helper for constructing JSON request for createandsend all in one method 
    public static String createDocuSignPWCaseJSONString(Case PWCase, Docusign_Settings__c docuSignSettings, String attachmentName){ 
        
        List<Signers__c> signersList = [Select Id,
                                        Name,
                                        EmailAddress__c,
                                        Case__c from Signers__c where Case__c = :PWCase.Id]; 
        
        System.debug('****************'+signersList); 
        
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject(); 
        gen.writeStringField('emailBlurb', docuSignSettings.EmailBody__c); 
        gen.writeStringField('emailSubject', docuSignSettings.EmailSubject__c); 
        //document 
        gen.writeFieldName('documents'); 
        gen.writeStartArray(); 
        gen.writeStartObject(); 
        gen.writeStringField('documentId', '1'); 
        gen.writeStringField('name', attachmentName); 
        gen.writeEndObject(); 
        gen.writeEndArray(); //end of doc 
        //srat recip 
        gen.writeFieldName('recipients'); 
        //signer -1 
        gen.writeStartObject(); 
        //array of singers 
        gen.writeFieldName('signers'); 
        gen.writeStartArray(); 
        
        integer i= 1; 
        Integer j; 
        //signer 
        if(signersList!=null && signersList.size()>0){         
            for(Signers__c sig: signersList){             
                gen.writeStartObject(); 
                gen.writeObjectField('email', sig.EmailAddress__c); 
                gen.writeObjectField('name', sig.Name); 
                gen.writeObjectField('recipientId', i); 
                gen.writeObjectField('routingOrder', '1'); 
                gen.writeEndObject(); 
                i=i+1; 
            } 
        } 
        
        j = i; 
        
        gen.writeStartObject(); 
        gen.writeObjectField('email', PWCase.Contact.PWEmail__c); 
        gen.writeObjectField('name', PWCase.Contact.Full_Name_Plain__c); 
        gen.writeObjectField('recipientId', j); 
        gen.writeObjectField('routingOrder', '20'); 
        gen.writeEndObject(); 
        
        if(PWCase.Type =='Account Opening'){ 
            j=i+1; 
            gen.writeStartObject(); 
            gen.writeObjectField('recipientId', j); 
            gen.writeObjectField('SigningGroupId', docuSignSettings.SigningGroupID__c); 
            gen.writeObjectField('routingOrder', '30'); 
            gen.writeEndObject(); 
        } 
        
        gen.writeEndArray(); 
        gen.writeEndObject();//end recip 
        gen.writeStringField('status', 'sent');         
        gen.writeFieldName('customFields'); 
        gen.writeStartObject(); 
        gen.writeFieldName('textCustomFields'); 
        
        gen.writeStartArray();     
        
        gen.writeStartObject(); 
        gen.writeObjectField('name', 'DSFSSourceObjectId'); 
        gen.writeObjectField('show', 'false'); 
        gen.writeObjectField('required', 'False'); 
        gen.writeObjectField('value', PWCase.Id); 
        gen.writeObjectField('customFieldType', 'text'); 
        gen.writeEndObject(); 
        
        gen.writeStartObject(); 
        gen.writeObjectField('name', 'DSXPartnerApplication'); 
        gen.writeObjectField('show', 'false'); 
        gen.writeObjectField('required', 'False'); 
        gen.writeObjectField('value',docuSignSettings.DSXPartnerApplication__c); 
        gen.writeObjectField('customFieldType', 'text'); 
        gen.writeEndObject(); 
        
        gen.writeStartObject(); 
        gen.writeObjectField('name', 'PlatformName'); 
        gen.writeObjectField('show', 'false'); 
        gen.writeObjectField('required', 'False'); 
        gen.writeObjectField('value', 'Salesforce'); 
        gen.writeObjectField('customFieldType', 'text'); 
        gen.writeEndObject(); 
        
        gen.writeStartObject(); 
        gen.writeObjectField('name', 'AppName'); 
        gen.writeObjectField('show', 'false'); 
        gen.writeObjectField('required', 'False'); 
        gen.writeObjectField('value', 'DocuSignForSalesforce'); 
        gen.writeObjectField('customFieldType', 'text'); 
        gen.writeEndObject(); 
        
        gen.writeStartObject(); 
        gen.writeObjectField('name', '##SFCase'); 
        gen.writeObjectField('show', 'false'); 
        gen.writeObjectField('required', 'False'); 
        gen.writeObjectField('value', PWCase.Id); 
        gen.writeObjectField('customFieldType', 'text'); 
        gen.writeEndObject();         
        
        gen.writeEndArray();         
        gen.writeEndObject(); 
        
        gen.writeEndObject(); 
        System.debug('JSON String => '+gen.getAsString()); 
        return gen.getAsString(); 
    } 
    
    
    //Envelope Data Class 
    public class EnvResponse{ 
        String envelopeId; 
        String status; 
        String statusDateTime; 
        String uri; 
    } 
}