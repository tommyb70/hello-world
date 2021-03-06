/**
*  JIRA        :   https://silverline.jira.com/browse/DYNAMO-243
*  Class name  :   SL_ctrl_TwoBoxesForm
*  Created by  :   Alex Zhurylo
*  Created on  :   07/05/2019
*  Description :   Apex class for SL_TwoBoxesForm component
**/
public with sharing class SL_ctrl_TwoBoxesForm {
   

   @AuraEnabled
   public static String getSearchValues(String objectApiName, String inQuery, String inSearchTxt, List<ID> inRecIDs){
       
       List<RecordsWrapper> lstWrappers = new List<RecordsWrapper>();
       if(inRecIDs==null){ inRecIDs = new List<ID>();}
       Integer limitOfLecord = 30;

       List<sObject> lstRecords = null;

       if(objectApiName=='Product2'){
            if(inSearchTxt!=null && inSearchTxt.trim()!='' && inSearchTxt.trim().length()>1)
            {
                String searchQuery = 'Find  \'' + inSearchTxt + '\' IN ALL FIELDS RETURNING  Product2(ProductCode,Name,TradingSymbol__c WHERE ';
                if(String.isNotBlank(inQuery)){
                    searchQuery += '('+inQuery+') and ';
                }
                searchQuery += 'ID not in :inRecIDs limit '+limitOfLecord+')';

                //List<List<sObject>> searchList = [Find :inSearchTxt IN ALL FIELDS RETURNING  Product2(ProductCode,Name,TradingSymbol__c WHERE ID not in :inRecIDs limit :limitOfLecord)];
                List<List<sObject>> searchList = search.query(searchQuery);
                if(searchList!=null && searchList.size()==1 && searchList.get(0)!=null && searchList.get(0).size()>0){
                    lstRecords = searchList.get(0);
                }
            }
            else if(inSearchTxt!=null && inSearchTxt.trim()!='' && inSearchTxt.trim().length()==1){
                String searchQuery = 'select ID,Name from '+objectApiName+' where ';
                if(String.isNotBlank(inQuery)){
                    searchQuery += '('+inQuery+') and ';
                }
                searchQuery += '(Name like \''+inSearchTxt+'%\' or TradingSymbol__c like \''+inSearchTxt+'%\') and ID not in :inRecIDs ORDER BY Name limit '+limitOfLecord;

                lstRecords = Database.query(searchQuery);
            }
            else{
                String searchQuery = 'select ID,Name from '+objectApiName+' where ';
                if(String.isNotBlank(inQuery)){
                    searchQuery += '('+inQuery+') and ';
                }
                searchQuery += 'ID not in :inRecIDs order by Name limit '+limitOfLecord;

                lstRecords = Database.query(searchQuery);
            }

       }
       else{
           if(inSearchTxt!=null && inSearchTxt.trim()!='' && inSearchTxt.trim().length()>0){
                String searchQuery = 'select ID,Name from '+objectApiName+' where ';
                if(String.isNotBlank(inQuery)){
                    searchQuery += '('+inQuery+') and ';
                }
                searchQuery += 'Name like \''+inSearchTxt+'%\' and ID not in :inRecIDs order by Name limit '+limitOfLecord;

                lstRecords = Database.query(searchQuery);
           }
           else{
                String searchQuery = 'select ID,Name from '+objectApiName+' where ';
                if(String.isNotBlank(inQuery)){
                    searchQuery += '('+inQuery+') and ';
                }
                searchQuery += 'ID not in :inRecIDs order by Name limit '+limitOfLecord;

                lstRecords = Database.query(searchQuery);
            }
       }

       if(lstRecords!=null) {
            for (Integer i = 0; i < lstRecords.size(); i++) {
                lstWrappers.add(new RecordsWrapper((String)lstRecords[i].get('id'), (String)lstRecords[i].get('Name'), false));
            }
       }

       return JSON.serialize(lstWrappers);
   }

   @AuraEnabled
   public static String getPicklistValues(String objectApiName, String inQuery, String listOfRecords){ 

        Integer limitOfLecord = 30;
        String SOQLQuery = 'select ID,Name from '+objectApiName+' order by Name limit '+limitOfLecord;
        if(String.isNotBlank(inQuery)){
            SOQLQuery = 'select ID,Name from '+objectApiName+' where '+inQuery+' order by Name limit '+limitOfLecord;
        }
        List<sObject> lstRecords = Database.query(SOQLQuery);

        List<RecordsWrapper> lstWrappers = new List<RecordsWrapper>();

        for (Integer i = 0; i < lstRecords.size(); i++) {
            lstWrappers.add(new RecordsWrapper((String)lstRecords[i].get('id'), (String)lstRecords[i].get('Name'), false));
        }
        
        List<RecordsWrapper> lstWrappersRight = null;
        if(listOfRecords != null || listOfRecords != ''){
            
            List<String> lstResult = new List<String>();
            Boolean isTrue = true;
            while(isTrue && listOfRecords != null){
                if (listOfRecords.contains(',') == true){
                    lstResult.add(listOfRecords.substring(0, listOfRecords.substringBefore(',').length()));
                    listOfRecords = listOfRecords.substring(listOfRecords.substringBefore(',').length() + 1);
                } else{
                    lstResult.add(listOfRecords);
                    isTrue = false;
                }                
            }
            
            String queryRight = 'SELECT id, Name FROM ' + objectApiName + ' WHERE id IN :  lstResult ';

            List<sObject> lstRecordsRight = Database.query(queryRight);
            
            lstWrappersRight = new List<RecordsWrapper>();
        
            for (Integer i = 0; i < lstRecordsRight.size(); i++) {
                lstWrappersRight.add(new RecordsWrapper((String)lstRecordsRight[i].get('id'), (String)lstRecordsRight[i].get('Name'), false));
            }
        }
        List<List<RecordsWrapper>> wrapper = new List<List<RecordsWrapper>>();
        wrapper.add(lstWrappers);
        wrapper.add(lstWrappersRight);

        return JSON.serialize(wrapper);
    }

    public class RecordsWrapper {
        public String Id {get;set;}
        public String Name {get;set;}
        public Boolean isSelected {get;set;}

        public RecordsWrapper(String id, String Name, Boolean isSelected) {
            this.id = id;
            this.Name = Name;
            this.isSelected = isSelected;
        }
    } 
    
}