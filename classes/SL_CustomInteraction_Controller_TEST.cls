@isTest
public class SL_CustomInteraction_Controller_TEST{

    @isTest private static void testSL_CustomInteraction_Controller(){

        SL_CustomInteraction_Controller controller = new SL_CustomInteraction_Controller() ;
    }

    @isTest static void test_queryCampaignRecords() {
    
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

                //insert account
        List<Account> myA = DataFactory.createTestAccounts(1);
        insert myA;

        Contact objContact1 = new Contact(FirstName='Test', LastName='Contact1',AccountId=myA[0].Id);
        insert objContact1; 
        Contact objContact2 = new Contact(FirstName='Test', LastName='Contact2',AccountId=myA[0].Id);
        insert objContact2; 

        Campaign objCampaign1 = new Campaign(Name = 'Test Campaign1');
        insert objCampaign1;
        Campaign objCampaign2 = new Campaign(Name = 'Test Campaign1');
        insert objCampaign2;

        CampaignMember objCampaignMember1 = new CampaignMember(CampaignId = objCampaign1.Id, ContactId = objContact1.Id);
        insert objCampaignMember1;
        CampaignMember objCampaignMember2 = new CampaignMember( CampaignId = objCampaign1.Id, ContactId = objContact2.Id);
        insert objCampaignMember2;

        CampaignMember objCampaignMember3 = new CampaignMember(CampaignId = objCampaign2.Id, ContactId = objContact1.Id);
        insert objCampaignMember3;
        CampaignMember objCampaignMember4 = new CampaignMember( CampaignId = objCampaign2.Id, ContactId = objContact2.Id);
        insert objCampaignMember4;

        CampaignMemberStatus objCampaignMemberStatus1 = new CampaignMemberStatus(CampaignId = objCampaign1.Id,Label='New', IsDefault=false, HasResponded=false, SortOrder=3 );
        insert objCampaignMemberStatus1;
        CampaignMemberStatus objCampaignMemberStatus2 = new CampaignMemberStatus(CampaignId = objCampaign2.Id, Label='New', IsDefault=false, HasResponded=false, SortOrder=3);
        insert objCampaignMemberStatus2;

        Task objTask = new Task(Campaign_IDs__c = objCampaign1.Id,Subject='TestCampaignTask1',Description='TestCampaignTask1');
        insert objTask;
        
        Task objTask2 = new Task(Campaign_IDs__c = objCampaign1.Id, Subject='TestCampaignTask2',Description='TestCampaignTask2');
        insert objTask2; 

        Task objTask3 = new Task(Campaign_IDs__c = objCampaign2.Id,Subject='TestCampaignTask3',Description='TestCampaignTask3');
        insert objTask3;

        Task objTask4 = new Task(Campaign_IDs__c = objCampaign2.Id,Subject='TestCampaignTask4',Description='TestCampaignTask4');
        insert objTask4;

        String jsonResult = SL_CustomInteraction_Controller.queryCampaignRecords(objContact1.Id, UserInfo.getUserId(), 'Contact');
        System.assertNotEquals(null, jsonResult, 'SL_CustomInteraction_Controller.queryCampaignRecords returned null');
        jsonResult = SL_CustomInteraction_Controller.queryCampaignRecords(objContact1.Id, UserInfo.getUserId(), 'Task');
        System.assertNotEquals(null, jsonResult, 'SL_CustomInteraction_Controller.queryCampaignRecords returned null');
    }
}