/**
*  Class name  :   SL_CloneListView
*  Created by  :   Alex Zhurylo
*  Created on  :   8/01/2019
*  Description :   Apex class clons List View. Incoming parameter group id, list view id
**/
public without sharing class SL_CloneListView {

    @future(callout=true)
    public static void cloneListView(Id groupId, Id listViewId) {
        MetadataService.MetadataPort service = createService();
        String nameOfListView = listListViews(listViewId, service);
        MetadataService.ListView listView = Test.isRunningTest() ? 
                (MetadataService.ListView) JSON.deserialize(ListViewForTest, MetadataService.ListView.class) :
                (MetadataService.ListView) service.readMetadata('ListView', new String[] { nameOfListView }).getRecords()[0];
        Group grp = getGoupApiName(groupId);
        MetadataService.ListView listViewNew = new MetadataService.ListView();
        
        String labelName = grp.Name;
        if(labelName.length() > 39){
            labelName = labelName.substring(0,39);
        }
        listViewNew.label = labelName; 
       
        String fullName = 'Account.View_' + groupId;

        if(fullName.length() > 79){
            fullName = fullName.substring(0,79);
        }
        listViewNew.fullName = fullName;
        listViewNew.filters = listView.filters;
        listViewNew.filterScope = listView.filterScope;
        listViewNew.columns = listView.columns;
        
        MetadataService.SharedTo shr = new MetadataService.SharedTo();
            shr.groups = new List<String>{grp.DeveloperName};
        listViewNew.sharedTo = shr;

        List<MetadataService.SaveResult> results;
        if(!Test.isRunningTest()){
            results = service.createMetadata(new MetadataService.Metadata[] { listViewNew });
        }

        if (results != null && !results.isEmpty()) {
            Id listViewIdToSetOnUsers = getListViewIdByFullName(fullName, service);
            List<Id> userIds = getUserIds(groupId);
            updateUserListViewIds(userIds, listViewIdToSetOnUsers);
        }
    }

    private static Group getGoupApiName(Id groupId){
        
        List<Group> lstGroup = [SELECT id, name, developerName FROM Group WHERE id =: groupId LIMIT 1];
        if(lstGroup.size() > 0){
            return lstGroup[0];
        }else{
            throw new CloneListViewException('There is no group with this id. Please contact your admin.');
        }
    }

    private static String listListViews(Id listViewId, MetadataService.MetadataPort service){

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'ListView';
        queries.add(listView);

        MetadataService.FileProperties[] fileProperties = Test.isRunningTest() ? 
                new List<MetadataService.FileProperties>{(MetadataService.FileProperties) JSON.deserialize(FilePropertiesForTest, MetadataService.FileProperties.class)} :
                service.listMetadata(queries, 25);

        for(MetadataService.FileProperties fileProperty : fileProperties){
            if(listViewId == fileProperty.id){
                return fileProperty.fullName;
            }
        }
        throw new CloneListViewException('There is no list view with this id. Please contact your admin.');
    }

    private static Id getListViewIdByFullName(String fullName, MetadataService.MetadataPort service){

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'ListView';
        queries.add(listView);

        MetadataService.FileProperties[] fileProperties = Test.isRunningTest() ? 
                new List<MetadataService.FileProperties>{(MetadataService.FileProperties) JSON.deserialize(FilePropertiesForTest, MetadataService.FileProperties.class)} :
                service.listMetadata(queries, 25);

        for(MetadataService.FileProperties fileProperty : fileProperties){
            if(fullName == fileProperty.fullName){
                return fileProperty.Id;
            }
        }
        throw new CloneListViewException('There is no list view with this full name. Please contact your admin.');
    }

    private static MetadataService.MetadataPort createService(){
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    private static List<Id> getUserIds(Id groupId) {
        List<Id> userIds = new List<Id>();
        List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :groupId];
        for (GroupMember member : groupMembers) {
            userIds.add(member.UserOrGroupId);
        }
        return userIds;
    }
    
    private static void updateUserListViewIds(List<Id> userIds, Id listViewId) {
        List<User> usersToUpdate = new List<User>();
        for (Id userId : userIds) {
            User userToUpdate = new User();
            userToUpdate.Id = userId;
            userToUpdate.KeyInsightListViewId__c = listViewId;
            usersToUpdate.add(userToUpdate);
        }
        
        update usersToUpdate;
    }

    private class CloneListViewException extends Exception {}

    private static String FilePropertiesForTest = '{"type_x_type_info":["type","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"type_x":"ListView","namespacePrefix_type_info":["namespacePrefix","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"namespacePrefix":null,"manageableState_type_info":["manageableState","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"manageableState":"unmanaged","lastModifiedDate_type_info":["lastModifiedDate","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"lastModifiedDate":"2019-07-29T10:59:22.000Z","lastModifiedByName_type_info":["lastModifiedByName","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"lastModifiedByName":"Vladimir Prishlak","lastModifiedById_type_info":["lastModifiedById","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"lastModifiedById":"0052A000009fuMdQAI","id_type_info":["id","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"id":"00B5C000001dCA3UAM","fullName_type_info":["fullName","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"fullName":"Account.Key_Insights","fileName_type_info":["fileName","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"fileName":"objects/Account.object","field_order_type_info":["createdById","createdByName","createdDate","fileName","fullName","id","lastModifiedById","lastModifiedByName","lastModifiedDate","manageableState","namespacePrefix","type_x"],"createdDate_type_info":["createdDate","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"createdDate":"2019-07-25T16:27:23.000Z","createdByName_type_info":["createdByName","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"createdByName":"Vladimir Prishlak","createdById_type_info":["createdById","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"createdById":"0052A000009fuMdQAI","apex_schema_type_info":["http://soap.sforce.com/2006/04/metadata","true","false"]}';
    private static String ListViewForTest = '{"fullName":null,"type_att_info":["xsi:type"],"type":"ListView","sharedTo_type_info":["sharedTo","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"sharedTo":null,"queue_type_info":["queue","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"queue":null,"language_type_info":["language","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"language":null,"label_type_info":["label","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"label":"Key Insights","fullName_type_info":["fullName","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"fullName":"Account.Key_Insights","filterScope_type_info":["filterScope","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"filterScope":"Everything","filters_type_info":["filters","http://soap.sforce.com/2006/04/metadata",null,"0","-1","false"],"filters":[{"value_type_info":["value","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"value":"Account.Affiliate,Account.Consultant,Account.Firm,Account.Office,Account.ParentFirm","operation_type_info":["operation","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"operation":"equals","field_type_info":["field","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"field_order_type_info":["field","operation","value"],"field":"ACCOUNT.RECORDTYPE","apex_schema_type_info":["http://soap.sforce.com/2006/04/metadata","true","false"]},{"value_type_info":["value","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"value":"CA","operation_type_info":["operation","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"operation":"equals","field_type_info":["field","http://soap.sforce.com/2006/04/metadata",null,"1","1","false"],"field_order_type_info":["field","operation","value"],"field":"ACCOUNT.ADDRESS1_STATE_CODE","apex_schema_type_info":["http://soap.sforce.com/2006/04/metadata","true","false"]}],"field_order_type_info":["fullName","booleanFilter","columns","division","filterScope","filters","label","language","queue","sharedTo"],"division_type_info":["division","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"division":null,"columns_type_info":["columns","http://soap.sforce.com/2006/04/metadata",null,"0","-1","false"],"columns":["ACCOUNT.NAME","ACCOUNT.ADDRESS1_STATE_CODE","MktOppNatixisAUM__c","MktOppIndustryAUM__c","MktOppMarketShareAUM__c","PotentialScore__c","PotentialReason__c","RiskScore__c","RiskReason__c"],"booleanFilter_type_info":["booleanFilter","http://soap.sforce.com/2006/04/metadata",null,"0","1","false"],"booleanFilter":null,"apex_schema_type_info":["http://soap.sforce.com/2006/04/metadata","true","false"]}';
        
}