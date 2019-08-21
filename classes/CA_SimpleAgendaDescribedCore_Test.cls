@isTest
global with sharing class CA_SimpleAgendaDescribedCore_Test {
    
    public static testMethod void testThis() {
        String sObjName = 'contact';
        String sFieldName = 'accountid';

        CA_SimpleAgendaDescribedCore core = CA_SimpleAgendaDescribedCore.getInstance();
        system.assert(core.getRecordByTypeName(sObjName) != null , 'getRecordByTypeName is null');      
        system.assert(core.getFieldsDescribesByObjectName(sObjName).size() > 0 , sObjName + ' getFieldsDescribesByObjectName is empty');
        
        
        system.assert(core.getFieldTypeByName(sObjName, sFieldName) != '' , 'getFieldTypeByName is empty');


        core.isFieldCreateable(sObjName, 'name');
        core.isObjectAccessable(sObjName);
        core.isObjectEditable(sObjName);        
        core.isObjectCreateable(sObjName);        
        core.isObjectDeleteable(sObjName);        
        
        
        
        system.assert(core.getFieldByName(sObjName, sFieldName) != null , 'getFieldByName is null');
        system.assert(core.getObjectLabelByName(sObjName) != '' , 'getObjectLabelByName is empty');
        
        
        
        core.isFieldUpdatable(sObjName, sFieldName);
        core.isFieldUpdatable(sObjName, 'createdbyid.name');
        core.isFieldCreateable(sObjName, 'createdbyid.name');
        core.RefreshObjects();
        //core.isFieldUpdatable(sObjName, sFieldName);


        core.getFieldsTypesInSOQL('Event', new Set<String>{'ownerid.name', 'startdatetime'});

        system.assert(core.checkFLS('insert', 'event', new List<String>{'ownerid', 'createdbyid'}) != null , 'checkFLS');
        system.assert(core.checkCRUD('all', 'event') != null , 'checkCRUD');
        system.assert(core.getReferenceField('event', 'ownerid') != null , 'getReferenceField');
        system.assert(core.getReferenceField('event', 'ownerid.name') != null , 'getReferenceField');
        system.assert(core.getFieldsTypesInSOQL('event', new Set<String>{'ownerid', 'createdbyid'}) != null , 'getFieldsTypesInSOQL');
        system.assert(core.getFieldsInSOQL('event', new List<String>{'ownerid', 'createdbyid', 'modifiedbyid.name'}) != null , 'getFieldsInSOQL');
        system.assert(core.getObjectDescription('event') != null , 'getObjectDescription');
        system.assert(core.getObjectAllQueryFields('event') != null , 'getObjectAllQueryFields');
        system.assert(core.getObjectAllFields('event') != null , 'getObjectAllFields');
        system.assert(core.buildQuery('event', 'subject', 'id!=NULL', 'subject != NULL') != null , 'buildQuery');


        
    }
}