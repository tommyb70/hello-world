/**
*  Test name   :   SL_ctrl_ListViewHomePage
*  Created by  :   Alex Zhurylo
*  Created on  :   7/18/2019
*  Description :   apex class for SL_ListViewHomePage and all inner components
**/
public with sharing class SL_ctrl_ListViewHomePage {
    
    @AuraEnabled
    public static String getListOfColumns(String metadataRecordName){

        FilteredListConfiguration__mdt record = [SELECT id, MasterLabel, ObjectName__c
                                                 FROM FilteredListConfiguration__mdt  
                                                 WHERE Label =: metadataRecordName LIMIT 1];
        
        String objectApiName = record.ObjectName__c;
        String recordId = record.id;

        List<FilteredListColumn__mdt> filterListRecords = [SELECT ColumnLabel__c, FieldName__c, FilteredListConfiguration__c, IsLink__c, 
                                                    LightningComponentName__c, LightningComponentParams__c, Ordering__c, Field_Value_Add_Symb__c 
                                                    FROM FilteredListColumn__mdt WHERE FilteredListConfiguration__c =: recordId];
        
        List<FilteredListParam__mdt> filterListParams = [SELECT FieldName__c, FilterDefaultValue__c, FilteredListConfiguration__c, FilterLabel__c,
                                                        FilterOperation__c, IsEnableb__c FROM FilteredListParam__mdt 
                                                        WHERE FilteredListConfiguration__c =: recordId ];
        RecordsWrapper wrapper = new RecordsWrapper(record, filterListRecords, filterListParams);
        return JSON.serialize(wrapper);
        
    }

    @AuraEnabled
    public static string getAllRecordsThrougthColumns(String objName, String listOfHeaderElements, String numberOfRecords, 
                                                    String defaultOrder,  Boolean isAsc){

// TJB 20190827                                                       
        String strAsc = '';
        if (isAsc) {
            strAsc = ' desc';
        } else {
            strAsc = ' asc';
        } 

        List<String> lstDeserialize = (List<String>)JSON.deserialize(listOfHeaderElements, List<String>.class);
        String elementsToSlect = '';
        for (Integer i = 0; i < lstDeserialize.size(); i++) {
            
            elementsToSlect += lstDeserialize[i] ;

            if(lstDeserialize.size() != i+1){
                elementsToSlect +=  ',';
            }
        }
        //elementsToSlect +=  ' ,PotentialReason__c,RiskReason__c ';
        
// TJB 20190827                                                       
//        String query = 'SELECT ' + elementsToSlect +' FROM ' + objName + ' ORDER By ' + defaultOrder + ' '+ strAsc + ' NULLS LAST  LIMIT 2000' ;
 //       String query = 'SELECT ' + elementsToSlect +' FROM ' + objName + ' ORDER By ' + defaultOrder + ' LIMIT 2000' ;              System.debug('------------query' + query);
        String query = 'SELECT ' + elementsToSlect +' FROM ' + objName + ' ORDER By ' + defaultOrder + ' '+ strAsc + ' NULLS LAST LIMIT ' + numberOfRecords; 
        List<sObject> lstObject = Database.query(query);

                                                        /*List<Id> lstAccountIds = new List<Id>();
        for (Integer i = 0; i < lstObject.size(); i++) {
            lstAccountIds.add((id)lstObject[i].get(taskParam));
        }

        List<Task> lstTasks = [SELECT id, WhatID FROM Task WHERE WhatID IN : lstAccountIds ];*/
        
        /*Map<Id, Integer> mapOfAccountIdAndCountOfTask = new Map<Id, Integer>();
        for (Integer i = 0; i < lstTasks.size(); i++) {
            if(mapOfAccountIdAndCountOfTask.get(lstTasks[i].WhatID) == null){
                mapOfAccountIdAndCountOfTask.put(lstTasks[i].WhatID, 1);
            }else{
                Integer countTasks = mapOfAccountIdAndCountOfTask.get(lstTasks[i].WhatID);
                countTasks++;
                mapOfAccountIdAndCountOfTask.put(lstTasks[i].WhatID, countTasks);
            }
        }*/
        
        List<ListSerachWrapper> lstWrappers = new List<ListSerachWrapper>();
        
        for (Integer i = 0; i < lstObject.size(); i++) {
            //Integer countTasks = mapOfAccountIdAndCountOfTask.get((Id)lstObject[i].get(taskParam));
            lstWrappers.add(new ListSerachWrapper(lstObject[i]));//, countTasks)); 
        }
        
        return JSON.serialize(lstWrappers);
    }

    @AuraEnabled
    public static String createTaskRecords(List<String> listOfTaskId){
        
        List<Task> lstTasks = new List<Task>();
        for (Integer i = 0; i < listOfTaskId.size(); i++) {
            lstTasks.add(new Task(WhatId = listOfTaskId[i], WhoId = null, OwnerId = UserInfo.getUserId(), ActivityDate = Date.today(), 
                                  ActivityType__c = 'Research', Priority = 'Normal', Status = 'Open', 
                                  Subject='Follow Up Call - Key Insights', ActivitySubType__c = 'Research'));
        }

        try{
            insert lstTasks;
            return 'SUCCESS';
        }catch(Exception e){
            return 'Error ' + e;
        }
        
    }

    @AuraEnabled
    public static String getUserKeyInsightsUrl(){
        User userToGetUrlFor = [SELECT KeyInsightListViewId__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return '/lightning/o/Account/list?filterName=' + userToGetUrlFor.KeyInsightListViewId__c;
    }

    public class ListSerachWrapper {
        sObject objectRecord {get; set;}
        //Integer countOfTask {get;set;}
   
        public ListSerachWrapper(sObject objectRecord) {  
            this.objectRecord = objectRecord;   
        }
	}

    public class RecordsWrapper {
        public FilteredListConfiguration__mdt record {get; set;}
		public List<FilteredListColumn__mdt> filterListRecords {get; set;}
        public List<FilteredListParam__mdt> filterListParams {get;set;}

        public RecordsWrapper(FilteredListConfiguration__mdt record, List<FilteredListColumn__mdt> filterListRecords, List<FilteredListParam__mdt> filterListParams) {  
            this.record = record;   
            this.filterListRecords = filterListRecords;
            this.filterListParams = filterListParams;
        }
    }

    private ApexPages.StandardController stdCtrl {get; set;}
    
    public List<sObject> Records {get; set;}
    public list<string> recordIds {get; set;}
    
    
    public SL_ctrl_ListViewHomePage(ApexPages.StandardController std){
        this.stdCtrl = std;
    }
    
    public SL_ctrl_ListViewHomePage(ApexPages.StandardSetController controller) {
        
        Records = controller.getSelected();
        
        recordIds = new list<string>();
        
        for (sObject r : Records){
            recordIds.add(r.Id);
        }   
		     
	}
    
    public PageReference Redirect() {
        
        PageReference newRef = null;
        User UserRec = [select ID,KeyInsightListViewId__c from User where ID=:UserInfo.getUserId() limit 1];

        if(String.isBlank(UserRec.KeyInsightListViewId__c)){
            newRef = new PageReference('/lightning/o/Account/list');
        }
        else {
            newRef = new PageReference('/lightning/o/Account/list?filterName='+UserRec.KeyInsightListViewId__c);
        }
        newRef.setRedirect(true);
        if(recordIds.size() > 0){
            createTaskRecords(recordIds);
        }
       
        return newRef;
        
    }
}