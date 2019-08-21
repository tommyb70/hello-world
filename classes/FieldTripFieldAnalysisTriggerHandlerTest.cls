/** 
* @author : Pratibha Potluri 
* @Created Date: 10/02/2018 
* @description : test class for FieldTripFieldAnalysisTriggerHandler. 
**/ 

@isTest
private class FieldTripFieldAnalysisTriggerHandlerTest{

    static testMethod void methodone(){
        
        //inserting the Dictionary item record
        DictionaryItem__c DI = new DictionaryItem__c();
        DI.APIName__c = 'Name';
        DI.MetadataIdentifier__c = 'Field:account.Name';
        DI.IsActive__c = true;
        insert DI;
        
        //inserting the Field Trip Field Object analysis record
        Field_Trip__Object_Analysis__c FTO = new Field_Trip__Object_Analysis__c();
        FTO.Field_Trip__Object_Name__c = 'account';
        FTO.Field_Trip__Last_Analyzed__c = system.now();
        insert FTO;
        
        //inserting the field trip field analysis record
        Field_Trip__Field_Analysis__c FTF = new Field_Trip__Field_Analysis__c();
        FTF.Field_Trip__Populated_On__c = 2;
        FTF.Field_Trip__Object_Analysis__c = FTO.Id;
        FTF.Name = 'Name';
        FTF.Field_Trip__Label__c = 'Name';
        insert FTF;
        
    }
}