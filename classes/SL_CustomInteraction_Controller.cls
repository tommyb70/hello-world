public with sharing class SL_CustomInteraction_Controller {

    public boolean isIcInbound { 
        get {
            return UserHelperClass.IsIC_Inbound(Userinfo.getUserId());
        }
        set;       
    } 
    
    public SL_CustomInteraction_Controller() {}

    private static RecordType callCampaignRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'CallCampaign' LIMIT 1];

    @remoteAction
    public static String queryCampaignRecords(String objId, String ownerId, String objName)
    {
        String strQuery;
        List<Id> lstOfCampaignIds = new List<Id>();
        Map<Id,List<String>> mapOfCampaignMemberStatus = new Map<Id,List<String>>();
        Map<String, Object> result = new Map<String, Object>();

        if(objName == 'Contact') {
            //AND Campaign.OwnerId =: ownerId
            List<CampaignMember> lstOfCampaignMemberDetails = new List<CampaignMember>([SELECT Status, Campaign.Name, Campaign.Id, Campaign.Status, Contact.Name, Contact.AccountId, Contact.Account.Name FROM CampaignMember WHERE ContactId =: objId AND HasResponded = false AND Campaign.RecordTypeId =: callCampaignRecordType.Id]);

            for(CampaignMember obj : lstOfCampaignMemberDetails) {
                lstOfCampaignIds.add(obj.Campaign.Id);
            }  

            List<CampaignMemberStatus> lstOfCampaignMemberStatus = new List<CampaignMemberStatus>([Select Id,Label,CampaignId from CampaignMemberStatus Where CampaignId IN : lstOfCampaignIds]);

            for(CampaignMemberStatus obj : lstOfCampaignMemberStatus) {            

                if(!mapOfCampaignMemberStatus.containsKey(obj.CampaignId))
                {              
                    
                    mapOfCampaignMemberStatus.put(obj.CampaignId, new List<String>{obj.Label});
                }
                else
                {
                    mapOfCampaignMemberStatus.get(obj.CampaignId).addAll(new List<String>{obj.Label});
                }   
            }     

            result.put('records', lstOfCampaignMemberDetails);
            result.put('campaignsStatus', mapOfCampaignMemberStatus);

        } else if(objName == 'Task') {

            List<Task> lstOfTasks = new List<Task>([Select Id, WhatId, WhoId, What.Name,Who.Name, Type, Subject, Description, Status, ActivityDate, Campaign_IDs__c from Task Where Id =: objId]);
            result.put('records', lstOfTasks);
        }

        return JSON.serialize(result);
    }
}