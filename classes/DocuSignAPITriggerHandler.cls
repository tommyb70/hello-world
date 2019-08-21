public class DocuSignAPITriggerHandler {
    
    Public static String accId; 
    Public static String contactId;
    Public static string caseId;
    Public static String attId;
    static String contEmail;
    static String contFullName;
    static String caseType;  
    Static String attachmentName;
    
    @future (callout=true)
    public static void DocuSigTriggerAfterInsert(Id attachmentId){
        
        Docusign_Settings__c docuSignSettings =  Docusign_Settings__c.getValues('PWPortal'); 
        Boolean sendMessage = FALSE;
        
        if (docuSignSettings != null) {
        	sendMessage = docuSignSettings.SendDocuSignMessageFromAttachments__c;
        }
        
        if (sendMessage) {
            
            attId=attachmentId;
            
            system.debug('##############'+attId);
            
            
            List<Attachment> attach = [SELECT Body,BodyLength,ContentType,Description,Id,Name,ParentId FROM Attachment where Id=:attachmentId];
            
            attachmentName = attach[0].Name;
            for(Attachment atts: attach){
                
                caseId= atts.ParentId; 
                
                if(caseId.startsWith('500')){
                    
                    system.debug('#####caseId#########'+caseId);
                    Case caseList = [Select Id,status,Type,RecordType.Name,ContactId,ContactEmail__c,Contact.PWEmail__c,Contact.Full_Name_Plain__c  from Case where Id=:caseId limit 1]; 
                    //contEmail = caseList.ContactEmail__c;
                    contEmail = caseList.Contact.PWEmail__c;
                    contFullName = caseList.Contact.Full_Name_Plain__c;
                    contactId = caseList.ContactId;
                    caseType = caseList.Type;
                    
                    system.debug('#####docuSignSettings#########'+docuSignSettings);
                    
                    if(caseList.Status =='Needs Signature' && caseList.RecordType.Name =='Private Wealth Portal' ){
                        
                        system.debug('#####entered If#########');
                        
                        String passString = '<DocuSignCredentials><Username>'+ docuSignSettings.Username__c
                            +'</Username><Password>' + docuSignSettings.Password__c
                            + '</Password><IntegratorKey>' + docuSignSettings.IntegratorKey__c
                            + '</IntegratorKey></DocuSignCredentials>';
                        
                        system.debug('##############'+passString);
                        
                        String jsonstring = json.serialize(passString);
                        system.debug('##############'+jsonstring );
                        
                        //MyBoundary - used to indicate benging/end of document in multi-part request
                        String contentType = '\r\n--myBoundary'+'\r\n'+'Content-Type:application/octet-stream'+ '\r\n'+
                            'Content-Transfer-Encoding: base64'+'\r\n'+'Content-Disposition:attachment; '+'filename=\"contract.pdf\";'+
                            'documentid=1 '+'\r\n\r\n\r\n';
                        
                        String envelop = createJSONString(caseId);
                        System.debug('request body => '+envelop);
                        String envEOF = '\r\n'+'--myBoundary--';                    
                        Http httpProtocol = new Http();
                        HttpRequest request = new HttpRequest();
                        //String endpoint = 'https://demo.docusign.net/restapi/v2/accounts/7b1892e3-2040-4603-b6b1-b9dabb617110/envelopes';
                        String endpoint = docuSignSettings.End_Point__c;
                        request.setEndPoint(endpoint);
                        request.setMethod('POST');
                        request.setHeader('Accept', 'application/json');
                        request.setHeader('X-DocuSign-Authentication', passString);
                        request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary'); 
                        
                        Blob pdfBlob = atts.Body; 
                        system.debug('#####pdfBlob#########'+pdfBlob );
                        
                        String bcontent = EncodingUtil.base64Encode(atts.Body);
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
            }   
        }
        
        
    }
    
    
    //Util helper for constructing JSON request for createandsend all in one method 
    public static String createJSONString(String caseId){  
        
        Docusign_Settings__c docuSignSettings =  Docusign_Settings__c.getValues('PWPortal');
        
        List<Signers__c> signersList = [Select Id,Name,EmailAddress__c,Case__c from Signers__c where Case__c=:caseId];
        
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
        gen.writeObjectField('email', contEmail);
        gen.writeObjectField('name', contFullName);
        gen.writeObjectField('recipientId', j);
        gen.writeObjectField('routingOrder', '20');
        gen.writeEndObject();
        
        if(caseType=='Account Opening'){
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
        gen.writeObjectField('value', caseId);
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
        gen.writeObjectField('value', caseId);
        gen.writeObjectField('customFieldType', 'text');
        gen.writeEndObject();
        
        
        gen.writeEndArray();
        
        gen.writeEndObject();
        
        gen.writeEndObject();
        System.debug('JSON String => '+gen.getAsString());
        return gen.getAsString();  
    }
    
    
    public class Tab{
        String name;
        String anchorString;
        public Tab(String n){
            name =n;
            anchorString = n;
        }
    }
    
    //Envelope Data Class
    public class EnvResponse{
        String envelopeId;
        String  status;
        String statusDateTime;
        String uri;
    }
}