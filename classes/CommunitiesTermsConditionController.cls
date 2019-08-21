global with sharing class CommunitiesTermsConditionController {
      
    
   
    global String TextFileContentAsString {get; set;}
    global String Community {get; set;}
    global Boolean Accepted {get; set;}
    global String startUrl {get; set;}
    global String CancelUrl {get; set;}
  
   global String CommunityName {get; set;}
    
    
    global CommunitiesTermsConditionController () {
       CommunitiesTermsConditionController.GetLatestTCData(Community);
        Accepted = false;
    }

    global static  Map<String,Object> GetLatestTCData(String Community) {
      
      Map<String,Object> result = new  Map<String,Object>();
        List<ContentVersion> versionList =  [SELECT Id, ContentDocumentId, ContentUrl, IsLatest, VersionNumber, Title, Description, ReasonForChange, SharingOption, 
                                   PathOnClient, NetworkId, Origin, FileExtension, ContentSize, VersionData, PublishStatus, FileType, CreatedDate, 
                                   ContentLocation, TextPreview, IsMajorVersion, Effective_Datetime__c, Community__c FROM ContentVersion 
                                   where Community__c=:Community and IsLatest = true and PublishStatus ='P'
                                   order by Effective_Datetime__c desc];
        
        if(!versionList.isEmpty())
        {
           System.debug('Attachment body : '+ versionList[0].VersionData);
           System.debug('Attachment body : '+ versionList[0].Title);
           result.put('FileText', versionList[0].VersionData.toString());
           result.put('FileType', versionList[0].FileType);
           result.put('EffectiveDatetime', versionList[0].Effective_Datetime__c);
           result.put('Community', versionList[0].Community__c );            
           result.put('Count', 1);
           result.put('result',true);
        }
        else
        {
           result.put('ErrorMessage', 'No Terms and Condition file');
           result.put('result',false);
        }
       
        return  result;
    }
    
     global PageReference NextAction() {
         
         PageReference next = New PageReference('/apex/ContactUs.vfp');
         if( Accepted)
         {
             next = new PageReference ('/apex/communitiesEstatement.vfp');
             next.setRedirect(true);
         
        
         }
         else
         {
             // logout url
         }
         return next;
    	// Go to nExt page
    	
    }
}