public with Sharing class DictionaryItemExtension {
    
    public static boolean showObjUI{get;set;}
    public static boolean showRectypeUI{get;set;}
    public static boolean showFieldUI{get;set;}
    public static boolean showPIcklistUI{get;set;}
    public static string RecordtypesLabel{get;set;}
    public static string PicklistLabel{get;set;}
//    public static string published{get;set;}
//    public static string notPublished{get;set;}
    public static DictionaryItem__c DIInfo{get;set;}
    public static DictionaryItem__c objectInformation{get;set;}
    public static List<DictionaryItem__c> recordtypesInformation{get;set;}
    public static List<DictionaryItem__c> fieldsInformationsRecords{get;set;}
    public static List<FieldInfo> fieldsInformation{get;set;}
    public static boolean showDetailPage{get;set;}   
    
    public class FieldInfo{         
        public string FieldType{get;set;}
        public DictionaryItem__c fieldsInformation{get;set;}
    }    
    public static DictionaryItem__c picklistFieldInformation{get;set;}
    public static String picklistFieldType{get;set;}
    public static List<DictionaryItem__c> picklistValuesInformation{get;set;}    
    
    public pageReference intialCheck(){            
        showDetailPage = false;
        RecordtypesLabel = 'Record Types';
        PicklistLabel = 'Picklist Values';
        
        NGAMSettingsHierarchy__c NAM = NGAMSettingsHierarchy__c.getInstance(userinfo.getProfileId());
        if(NAM != null){
            showDetailPage = NAM.DictionaryItemVFPageView__c;
        }
        
        objectInformation = new DictionaryItem__c();
        recordtypesInformation = new List<DictionaryItem__c>();
        fieldsInformation = new List<FieldInfo>();        
        picklistFieldInformation = new DictionaryItem__c();
        picklistValuesInformation = new List<DictionaryItem__c>();
        fieldsInformationsRecords = new List<DictionaryItem__c>();
        showObjUI = false;
        showPIcklistUI = false;
        showRectypeUI = false;
        showFieldUI = false;
//        published = 'This item is not published';
        DIInfo = new DictionaryItem__c();
        DIInfo = [select id,
                  Name,
                  Label__c,
                  FieldType__c,
                  Publish__c,
                  BusinessDefinition__c,
                  ParentDictionaryItem__c,
                  PluralLabel__c,ParentDictionaryItem__r.Label__c ,
                  ParentDictionaryItem__r.PluralLabel__c,
                  ParentDictionaryItem__r.Publish__c,
                  recordtype.Name from DictionaryItem__c 
                  where Id =:apexpages.currentpage().getparameters().get('id')];                                                    
        
//        if(DIInfo.Publish__c){published = 'This item is published';}
//        if(!DIInfo.Publish__c){notPublished = 'This item is not published';}

//        if(!showDetailPage){published = '';}
        if(DIInfo.recordtype.Name == 'Object'){
            showObjUI = true;
        }
        if(DIInfo.recordtype.Name == 'Record Type'){
            showRectypeUI = true;
            RecordtypesLabel = 'Other Record Types for '+DIInfo.ParentDictionaryItem__r.Label__c;
        }
        if(DIInfo.recordtype.Name == 'Field'){
            showFieldUI = true;
        }
        if(DIInfo.recordtype.Name == 'Picklist Value'){
            showPIcklistUI = true;
            PicklistLabel = 'Other Picklist Values for '+DIInfo.ParentDictionaryItem__r.Label__c;
        }
        
        List<DictionaryItem__c> lstDIData = [select id,
                                             Label__c,
                                             FieldType__c,
                                             Publish__c,
                                             BusinessDefinition__c,
                                             ParentDictionaryItemLabel__c,
                                             PluralLabel__c,
                                             recordtype.Name,
                                             ParentDictionaryItem__r.PluralLabel__c,
                                             ParentDictionaryItem__c from DictionaryItem__c 
                                             where ParentDictionaryItem__c  =:DIInfo.ParentDictionaryItem__c or ParentDictionaryItem__c =:DIInfo.Id or 
                                             Id =:DIInfo.Id or Id =:DIInfo.ParentDictionaryItem__c order by Label__c ];
        
        if(!lstDIData.IsEmpty()){                  
            for(DictionaryItem__c DI:lstDIData){                     
                
                if(DI.recordtype.Name == 'Record Type' && DI.Id != DIInfo.Id){
                    recordtypesInformation.add(DI); 
                }else if(DI.recordtype.Name == 'Field'){                      
                    fieldsInformationsRecords.add(DI);                        
                }else if(DI.recordtype.Name == 'Picklist Value' && DI.Id != DIInfo.Id){
                    picklistValuesInformation.add(DI); 
                }                                    
            }     
            
            getFieldsInfoPagination();         
        }              
        return null;              
    }
    
    public integer pageNumber{get
    {
        return Setcon.getPageNumber();
    }    
                              set;    
                             }
    
    public integer size { get; set; }
    Public Integer noOfRecords{get; set;}
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(fieldsInformationsRecords);
                size=25;
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
    
    public void next(){
        showObjUI = true;
        setCon.next();
    }    
    public void first(){
        showObjUI = true;
        setCon.first();
    }        
    public void previous(){
        showObjUI = true;
        setCon.previous();
    }    
    public void last(){
        showObjUI = true;
        setCon.last();
    }
    
    public List<FieldInfo> getFieldsInfoPagination() {
        
        List<DictionaryItem__c> lstDI = (List<DictionaryItem__c>) Setcon.getRecords();
        fieldsInformation = new List<FieldInfo>();   
        for(DictionaryItem__c DI:LstDI){
            FieldInfo FI = new FieldInfo();
            FI.fieldsInformation = DI;
            FI.FieldType = DI.FieldType__c != null ? DI.FieldType__c.tolowercase().capitalize() : '';
            fieldsInformation.add(FI); 
        }
        return fieldsInformation;
    } 
    
    public DictionaryItemExtension(ApexPages.StandardController controller) {        
        
    }
    
}