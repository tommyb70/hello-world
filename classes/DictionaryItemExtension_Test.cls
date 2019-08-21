@isTest
private class DictionaryItemExtension_Test{
    
    @TestSetup
    static void setup(){
        
        DictionaryItem__c DObject = new DictionaryItem__c();
        DObject.RecordtypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
        DObject.Label__c ='Account';
        insert DObject;
        
        DictionaryItem__c DRt = new DictionaryItem__c();
        DRt.RecordtypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Record Type').getRecordTypeId();
        DRt.Label__c ='Account';
        DRt.ParentDictionaryItem__c = DObject.Id;
        insert DRt;
        
        DictionaryItem__c DFd = new DictionaryItem__c();
        DFd.RecordtypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
        DFd.Label__c ='Account';
        DFd.fieldType__c ='Text';
        DFd.ParentDictionaryItem__c = DObject.Id;
        insert DFd;
        
        DictionaryItem__c DFdp = new DictionaryItem__c();
        DFdp.RecordtypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
        DFdp.Label__c ='Account';
        DFdp.fieldType__c ='Picklist';
        DFdp.ParentDictionaryItem__c = DObject.Id;
        insert DFdp;
        
        DictionaryItem__c DFdpv = new DictionaryItem__c();
        DFdpv.RecordtypeId = Schema.SObjectType.DictionaryItem__c.getRecordTypeInfosByName().get('Picklist Value').getRecordTypeId();
        DFdpv.Label__c ='Account';
        DFdpv.ParentDictionaryItem__c = DFdp.Id;
        insert DFdpv;
    }
    
    private static testMethod void objectMethod(){
        
        DictionaryItem__c DI = [select id from DictionaryItem__c where Recordtype.Name = 'Object' LIMIT 1];    
          PageReference pageRef = Page.DictionaryItemVF;
          Test.setCurrentPage(pageRef);
          System.currentPageReference().getParameters().put('Id', String.ValueOf(DI.id));
          
          ApexPages.StandardController sc = new ApexPages.StandardController(DI);
          DictionaryItemExtension DIE = new DictionaryItemExtension(sc);
          DIE.intialCheck();
          DIE.getFieldsInfoPagination();
          DIE.first();
          DIE.Last();
          DIE.Next();
          DIE.Previous();
    }
     
     private static testMethod void PLMethod(){
        
        DictionaryItem__c DI = [select id from DictionaryItem__c where Recordtype.Name = 'Field' and FieldType__c =:'Picklist' LIMIT 1];    
          PageReference pageRef = Page.DictionaryItemVF;
          Test.setCurrentPage(pageRef);
          System.currentPageReference().getParameters().put('Id', String.ValueOf(DI.id));
          
          ApexPages.StandardController sc = new ApexPages.StandardController(DI);
          DictionaryItemExtension DIE = new DictionaryItemExtension(sc);
          DIE.intialCheck();
          
    }   
    
	private static testMethod void RTMethod(){
        
        DictionaryItem__c DI = [select id from DictionaryItem__c where Recordtype.Name = 'Record Type' LIMIT 1];    
          PageReference pageRef = Page.DictionaryItemVF;
          Test.setCurrentPage(pageRef);
          System.currentPageReference().getParameters().put('Id', String.ValueOf(DI.id));
          
          ApexPages.StandardController sc = new ApexPages.StandardController(DI);
          DictionaryItemExtension DIE = new DictionaryItemExtension(sc);
          DIE.intialCheck();
          
    }   
    
	private static testMethod void FieldMethod(){
        
        DictionaryItem__c DI = [select id from DictionaryItem__c where Recordtype.Name = 'Field' LIMIT 1];    
          PageReference pageRef = Page.DictionaryItemVF;
          Test.setCurrentPage(pageRef);
          System.currentPageReference().getParameters().put('Id', String.ValueOf(DI.id));
          
          ApexPages.StandardController sc = new ApexPages.StandardController(DI);
          DictionaryItemExtension DIE = new DictionaryItemExtension(sc);
          DIE.intialCheck();
          
    }   
    
	private static testMethod void PLVMethod(){
        
        DictionaryItem__c DI = [select id from DictionaryItem__c where Recordtype.Name = 'Picklist Value' LIMIT 1];    
          PageReference pageRef = Page.DictionaryItemVF;
          Test.setCurrentPage(pageRef);
          System.currentPageReference().getParameters().put('Id', String.ValueOf(DI.id));
          
          ApexPages.StandardController sc = new ApexPages.StandardController(DI);
          DictionaryItemExtension DIE = new DictionaryItemExtension(sc);
          DIE.intialCheck();
          
    }    
    
}