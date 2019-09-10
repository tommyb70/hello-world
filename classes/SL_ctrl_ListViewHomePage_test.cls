/**
*  Test name   :   SL_ctrl_ListViewHomePage_test
*  Created by  :   Alex Zhurylo
*  Created on  :   7/26/2019
*  Description :   test class for SL_ctrl_ListViewHomePage
**/
@isTest
public class SL_ctrl_ListViewHomePage_test {

    /*  init
        1) create new Account() record with all required fields;
     */
    @TestSetup
    public static void init(){
        
        Double rand = Math.random() * 1000;
        Account acc = new Account();
            acc.Name = 'test' + rand;
            acc.PotentialScore__c = '1';
            acc.RiskScore__c = '1';
            acc.MktOppMarketShareAUM__c = 1.0;
            acc.MktOppPYIndustryNetSales__c = 1.0;
            acc.MktOppPYMarketSharePurchases__c = 1.0;
            acc.NumberOfOpenTasks__c = 1.0;
            acc.type = 'Affiliate';
        insert acc;
    }
    
    /*  getListOfColumns_test check getListOfColumns
        1) call getListOfColumns with Main Dashboard parameter and assign to returnedResult variable;
        2) return metadata record with name Main Dashboard from FilteredListConfiguration__mdt;
        3) return records from FilteredListParam__mdt and FilteredListColumn__mdt where FilteredListConfiguration__c
            = id from record returned in step 2;
        4) create RecordsWrapper wrapper with all 3 records(step 2 and 3);
        5) compare returnedResult and expectedResult;
        6) expected result => strings are equal;
     */
    @isTest
    public static void getListOfColumns_test() {
        
        String nameOfmetadata = 'Main Dashboard';

        String returnedResult = SL_ctrl_ListViewHomePage.getListOfColumns(nameOfmetadata);

        FilteredListConfiguration__mdt record = [SELECT id, MasterLabel, ObjectName__c
                                                 FROM FilteredListConfiguration__mdt  
                                                 WHERE Label =: nameOfmetadata LIMIT 1];
        
        String objectApiName = record.ObjectName__c;
        String recordId = record.id;

        List<FilteredListColumn__mdt> filterListRecords = [SELECT ColumnLabel__c, FieldName__c, FilteredListConfiguration__c, IsLink__c, 
                                                    LightningComponentName__c, LightningComponentParams__c, Ordering__c, Field_Value_Add_Symb__c 
                                                    FROM FilteredListColumn__mdt WHERE FilteredListConfiguration__c =: recordId];
        
        List<FilteredListParam__mdt> filterListParams = [SELECT FieldName__c, FilterDefaultValue__c, FilteredListConfiguration__c, FilterLabel__c,
                                                        FilterOperation__c, IsEnableb__c FROM FilteredListParam__mdt 
                                                        WHERE FilteredListConfiguration__c =: recordId ];
        SL_ctrl_ListViewHomePage.RecordsWrapper wrapper = new SL_ctrl_ListViewHomePage.RecordsWrapper(record, filterListRecords, filterListParams);
        String expectedResult = JSON.serialize(wrapper);

        System.assertEquals(expectedResult, returnedResult);
    }

    /*  getAllRecordsThrougthColumns_test check getAllRecordsThrougthColumns
        1) call getListOfColumns with Main Dashboard parameter and assign to serializeListOfRecord variable;
        2) create listRecords and desiarialize string from step 1;
        3) iterate throught list of filterListRecords from step 2 and find all FieldName__c and LightningComponentParams__c. 
            Assign them to  list lstHeaderItems;
        4) call getAllRecordsThrougthColumns with all required parameters and assign to returnedResult;
        5) call private getAllRecordsThrougthColumns with all required parameters and assign to expectedResult;
        6) compare returnedResult and expectedResult;
        7) expected result => strings are equal;
     */
    @isTest
    public static void getAllRecordsThrougthColumns_test() {
        
        String nameOfmetadata = 'Main Dashboard';
        String serializeListOfRecord = SL_ctrl_ListViewHomePage.getListOfColumns(nameOfmetadata);

        SL_ctrl_ListViewHomePage.RecordsWrapper listRecords = (SL_ctrl_ListViewHomePage.RecordsWrapper) JSON.deserialize(serializeListOfRecord,  SL_ctrl_ListViewHomePage.RecordsWrapper.class);

        List<FilteredListColumn__mdt> filterListRecords = listRecords.filterListRecords;

        List<String> lstHeaderItems = new List<String>();
        for (Integer i = 0; i < filterListRecords.size(); i++) {
            if (filterListRecords[i].FieldName__c != null) {
                lstHeaderItems.add(filterListRecords[i].FieldName__c);
            } else {
                lstHeaderItems.add(filterListRecords[i].LightningComponentParams__c);
            }
        }

        String objName = 'Account';
        String listOfHeaderElements = JSON.serialize(lstHeaderItems);        
        String numberOfRecords = '10';
        String defaultOrder = 'Name';
        Boolean isAsc = false;

        String returnedResult = SL_ctrl_ListViewHomePage.getAllRecordsThrougthColumns(objName, listOfHeaderElements, numberOfRecords, defaultOrder, isAsc);
        String expectedResult = getAllRecordsThrougthColumns(objName, listOfHeaderElements, numberOfRecords, defaultOrder, isAsc);
        System.assertEquals(expectedResult, returnedResult);

        returnedResult = SL_ctrl_ListViewHomePage.getAllRecordsThrougthColumns(objName, listOfHeaderElements, numberOfRecords, defaultOrder, true);
        expectedResult = getAllRecordsThrougthColumns(objName, listOfHeaderElements, numberOfRecords, defaultOrder, true);
        System.assertEquals(expectedResult, returnedResult);
    }

    /*  createTaskRecords_test check createTaskRecords
        1) return account record;
        2) create new listOfIds and add account id;
        3) return all tasks where WhatId =: acc.Id;
        4) expected result list of tasks equals 0;
        5) call createTaskRecords with created list of ids in step 2;
        6) return all tasks where WhatId =: acc.Id;
        7) expected result list of tasks equals 1;
        8) call createTaskRecords with incorrect id;
        9) expected result string doen't equal SUCCESS;
     */
    @isTest
    public static void createTaskRecords_test() {
        
        Account acc = [SELECT id FROM Account LIMIT 1];

        List<String> listOfIds = new List<String>{acc.Id};

        List<Task> lstTasks = [SELECT Id FROM Task WHERE WhatId =: acc.Id];
        System.assertEquals(lstTasks.size(), 0);

        String returnedResult = SL_ctrl_ListViewHomePage.createTaskRecords(listOfIds);
        System.assertEquals(returnedResult, 'SUCCESS');

        lstTasks = [SELECT Id FROM Task WHERE WhatId =: acc.Id];
        System.assertEquals(lstTasks.size(), 1);

        String returnedResultError = SL_ctrl_ListViewHomePage.createTaskRecords(new List<String>{lstTasks[0].Id});
        System.assertNotEquals(returnedResultError, 'SUCCESS');
    }

    /*  getAllRecordsThrougthColumns
        return all records due to incoming parameters
     */
    private static String getAllRecordsThrougthColumns(String objName, String listOfHeaderElements, String numberOfRecords, 
                                                    String defaultOrder,  Boolean isAsc){

// TJB 20190827                                                       
/*        String strAsc = '';
        if (isAsc) {
            strAsc = ' desc';
        } else {
            strAsc = ' asc';
        } */

        List<String> lstDeserialize = (List<String>)JSON.deserialize(listOfHeaderElements, List<String>.class);
        String elementsToSlect = '';
        for (Integer i = 0; i < lstDeserialize.size(); i++) {
            
            elementsToSlect += lstDeserialize[i] ;

            if(lstDeserialize.size() != i+1){
                elementsToSlect +=  ',';
            }
        }

// TJB 20190827                                                       
//        String query = 'SELECT ' + elementsToSlect +' FROM ' + objName + ' ORDER By ' + defaultOrder + ' '+ strAsc + ' NULLS LAST  LIMIT 2000' ;
        String query = 'SELECT ' + elementsToSlect +' FROM ' + objName + ' ORDER By ' + defaultOrder + ' LIMIT 2000' ;        
        List<sObject> lstObject = Database.query(query);

        List<SL_ctrl_ListViewHomePage.ListSerachWrapper> lstWrappers = new List<SL_ctrl_ListViewHomePage.ListSerachWrapper>();
        
        for (Integer i = 0; i < lstObject.size(); i++) {
            lstWrappers.add(new SL_ctrl_ListViewHomePage.ListSerachWrapper(lstObject[i])); 
        }
        
        return JSON.serialize(lstWrappers);
    }

}