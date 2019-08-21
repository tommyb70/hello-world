@isTest
public class SL_LookupController_test {
   
    @TestSetup
    public static void initialize(){
        Contact con = new Contact();
            con.FirstName = 'testCont';
            con.LastName = 'testCont';
        insert con;
        Contact newCont = con.clone(false, false, false, false);
            newCont.FirstName = 'testCont-clone';
        insert newCont;
    }

    @isTest
    public static void search_test(){
        
        List<Contact> lstConts = [SELECT id, Name FROM Contact LIMIT 2 ];
        List<sObject> returnedResult = SL_LookupController.search(lstConts[0].Name, 'Contact', 'FirstName', ' name != \' te12 \'', 1, new List<Id>{lstConts[1].Id} );

        String query = 'SELECT Name FROM Contact WHERE FirstName LIKE \'%'+ lstConts[0].Name +'%\'  LIMIT 1' ;
        List<sObject> expectedResult = Database.query(query);

        System.assertEquals(returnedResult, expectedResult);
    }

    @isTest
    public static void getRecord_test(){

        List<Contact> lstConts = [SELECT id, FirstName FROM Contact LIMIT 1 ];

        sObject retuned = SL_LookupController.getRecord(lstConts[0].Id, 'Contact', 'FirstName', 'LastName' );
        String recordId = lstConts[0].Id;
       	Set<String> fieldsToQuery = new Set<string>();
			fieldsToQuery.add('Id');
			fieldsToQuery.add('FirstName');
            fieldsToQuery.add('LastName');
		
	    String query = 'SELECT ' + String.join(new List<String> (fieldsToQuery), ', ') +  ' FROM ' + 'Contact' + ' WHERE Id = :recordId';
        
        List<sObject> expectedResult = Database.query(query);
        System.assertEquals(retuned, expectedResult[0]);
    }

    @isTest
    public static void getMultiRecords_test(){
        
        List<Contact> lstConts = [SELECT id, FirstName FROM Contact LIMIT 2 ];
        List<Id> lstIds = new List<Id>();
        for (Integer i = 0; i < lstConts.size(); i++) {
            lstIds.add(lstConts[i].Id);
        }
        
        List<sObject> returnedResult = SL_LookupController.getMultiRecords(lstIds, 'Contact', 'FirstName', 'LastName');
        System.assertEquals(returnedResult.size(), 2);
    }

    @isTest
    public static void searchProduct_test(){
        
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, PartNum__c = '1' + Math.random());
        insert prod;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

        List<SObject> returnedRsult = SL_LookupController.searchProduct('SLA', standardPBE.Pricebook2Id, ' product2.name != \'t3\' ', 1);

        System.assertEquals(returnedRsult.size(), 1);
    }

    @isTest
    public static void getRecordProduct_test(){

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, PartNum__c = '1' + Math.random());
        insert prod;

        SObject returnedRsult = SL_LookupController.getRecordProduct(prod.Id);
        System.assertNotEquals(returnedRsult, null);
    }

}