public class DataFactory {
    
    public static List<Campaign> createCampaigns(Integer numCampaigns) {
        
        List<Campaign> campaigns = new List<Campaign>();
        for(Integer i = 0; i < numCampaigns; i++){
            Campaign c = new Campaign(Name = 'Test Campaign ' + i);
            campaigns.add(c);
        }
        return campaigns;            
    }
    
    
    public static User createSystemAdminUser() {
        List<Channel__c> channels = createChannels();
        insert channels;
        List<Territory__c> territories = createTerritories(channels[0]);
        insert territories;
        List<Zone__c> zones = createAllZones();
        
        Profile p = [select id from profile where name='System Administrator']; 
        
        User u = new User(alias = 'standt', 
                          email='SFDCadmin@ngam.natixis.com', 
                          emailencodingkey='UTF-8', 
                          lastname='Testing', 
                          languagelocalekey='en_US', 
                          isActive = TRUE,
                          localesidkey='en_US', 
                          profileid = p.Id,
                          ActivityTerritoryName__c = territories[0].Name,
                          ActivityChannelName__c = channels[0].Name,
                          ZoneLabel__c = zones[0].Name,
                          timezonesidkey='America/Los_Angeles', username='SFDCadmin@ngam.natixis.com',UserID__c='SFDCadmin');
        return u;
    } 
    
    public static User createNonSysAdminUser(String zoneLabel, String channelName, String territoryName) { 
        
        List<Profile> p = [SELECT id FROM profile WHERE name LIKE 'NGAM%' AND UserType='Standard' LIMIT 1];
        
        User u = new User(alias = zoneLabel, 
                          email= zoneLabel + '@ngam.natixis.com', 
                          emailencodingkey='UTF-8', 
                          lastname='Testing', 
                          languagelocalekey='en_US', 
                          isActive = TRUE,
                          localesidkey='en_US', 
                          profileid = p[0].Id,
                          ActivityTerritoryName__c = territoryName,
                          ActivityChannelName__c = channelName,
                          ZoneLabel__c = zoneLabel,
                          timezonesidkey='America/Los_Angeles', username=zoneLabel + '@ngam.natixis.com',UserID__c=zoneLabel);
        return u;
    } 
    
    public static List<Channel__c> createChannels(){
        List<Channel__c> Channels = new List <Channel__c>();
        Channels.add(new Channel__c (Name='IAG', 
                                     ChannelName__c='IAG',
                                     TierField__c='PROTierIAG__c', 
                                     ZoneField__c='PROZoneIAG__c',
                                     RotationField__c='PRORotationIAG__c',
                                     FocusFirmField__c='FocusFirmIAG__c'));
        
        /*Channels.add(new Channel__c (Name='WIREHOUSE', 
                                       ChannelName__c='WIREHOUSE',
                                       TierField__c='PROTierWHSE__c', 
                                       ZoneField__c='PROZoneWHSE__c',
                                       RotationField__c='PRORotationWHSE__c',
                                       FocusFirmField__c='FocusFirmWHSE__c'));
        Channels.add(new Channel__c (Name='BANK TRUST', 
                                    ChannelName__c='BANK TRUST',
                                    TierField__c='PROTierFS__c', 
                                    ZoneField__c='PROZoneFS__c',
                                    RotationField__c='PRORotationFS__c',
                                    FocusFirmField__c='FocusFirmFS__c'));*/
        return Channels;    
    }
    
    public static List<Territory__c> createTerritories(Channel__c myChan){
        List<Territory__c> Terrs = new List <Territory__c>();
        Terrs.add(new Territory__c (Name='Test Terr', TerritoryName__c='Test Terr', TerritoryType__c='Region', Code__c='REG604', Channel__c=myChan.id));
        return Terrs;    
    }
        
    public static List<Product2> createProduct2(Integer intProducts, String Prefix){
        List<Product2> Product2s = new List<Product2>();
        for(Integer i = 0; i < intProducts; i++) 
        {
            Product2s.add(new Product2(name=Prefix + i,
                                       ProductType__c='MUTUAL FUND',
                                       ProductCode=Prefix + i,
                                       AssetClass__c='EQUITY',
                                       ProductVisible__c = TRUE,
                                       PartNum__c=Prefix + i));
        }
        return Product2s;    
    }
    
    public static List<ExchangeOptout__c> createExchangeOptouts(Integer intEmails) {
        List<ExchangeOptout__c> ExchangeOptouts = new List<ExchangeOptout__c>();
        for(Integer i = 0; i < intEmails; i++){
            ExchangeOptouts.add(new ExchangeOptout__c(Email__c='Test'+i + '@Test.com',
                                                      EmailDate__c=system.today(),
                                                      ItemId__c='Item' + i,
                                                      Subject__c='Test'+ i));     
        }
        return ExchangeOptouts;    
    }
        
    public static List<Zone__c> createAllZones (){
        List<Zone__c> allZones = new  List<Zone__c> ();  
        allZones.add(new zone__c(name='MRD',Zone__c=1)); 
        allZones.add(new zone__c(name='RD1',Zone__c=2));      
        allZones.add(new zone__c(name='RD2',Zone__c=3));     
        allZones.add(new zone__c(name='R3',Zone__c=4)); 
        allZones.add(new zone__c(name='IC',Zone__c=5));  
        
        insert allZones;
        
        return  [select id,Name from Zone__c];
    }
    
    public static List<ActivityProduct__c> createActivityProducts (List<Task> Tasks,  List<Product2> Products) {
        List<ActivityProduct__c> ActPds = new List<ActivityProduct__c>();    
        for (Task tsk : Tasks) {       
            for (Product2 p : Products) {    
                ActivityProduct__c newActPd =  new ActivityProduct__c(ActivityId__c=tsk.id,Product__c=p.id );
                ActPds.add(newActPd);    
            }    
        }
        return ActPds;
    }
        
    public static List<TaskRelation> createTaskRelations (List<Task> Tasks,  List<Contact> Contacts) {
        List<TaskRelation> ActTRs = new List<TaskRelation>();    
        for (Task tsk : Tasks) {       
            for (Contact c : Contacts) {    
                TaskRelation newTR =  new TaskRelation(TaskId=tsk.id,RelationId=c.id );
                ActTRs.add(newTR);    
            }    
        }
        return ActTRs;
    }
    
    public static List<EventRelation> createEventRelations (List<Event> Events,  List<Contact> Contacts) {
        List<EventRelation> ERs = new List<EventRelation>();    
        for (Event event : Events) {       
            for (Contact c : Contacts) {    
                EventRelation newER =  new EventRelation(EventId=event.id,RelationId=c.id );
                ERs.add(newER);    
            }    
        }
        return ERs;
    }    
        
    public static List<ActivityContact__c> createActivityContacts (List<Task> Tasks,  List<Contact> Contacts) {
        List<ActivityContact__c> ActCs = new List<ActivityContact__c>();    
        for (Task tsk : Tasks) {       
            for (Contact c : Contacts) {    
                ActivityContact__c newAC =  new ActivityContact__c(ActivityId__c=tsk.id,Contact__c=c.id,Account__c = c.AccountId, Date__c=tsk.ActivityDate );
                ActCs.add(newAC);    
            }    
        }
        return ActCs;
    }

    //Added by Prabhpreet
    public static List<ActivityContact__c> createActivityContactsEvents (List<Event> Events,  List<Contact> Contacts) {
        List<ActivityContact__c> ActCs = new List<ActivityContact__c>();    
        for (Event evt : Events) {       
            for (Contact c : Contacts) {    
                ActivityContact__c newAC =  new ActivityContact__c(ActivityId__c=evt.id,Contact__c=c.id,Account__c = c.AccountId, Date__c=evt.ActivityDate );
                ActCs.add(newAC);    
            }    
        }
        return ActCs;
    }

        
    public static List<Task> updateTestTasks(List<Task> Tasks, String strTitle, String StrDesc) {
       
        List<Task> tsks = new List<Task>();
        
        for (Task tsk : Tasks) {
            Task t = new Task(id=tsk.id, 
                              subject=strTitle,
                              type=strTitle, 
                              IsReminderSet= true,
                              ActivitySource__c='User Created', 
                              Status='Completed', 
                              ActivityDate=date.today() +3, description=StrDesc);
            tsks.add(t);
        }
        return tsks;
    }
    
    public static List<Task> updateTestTasks_outlookplugin(List<Task> Tasks, String strTitle, String StrDesc) {
        
        List<Task> tsks = new List<Task>();
        
        for (Task tsk : Tasks) {
            Task t = new Task(id=tsk.id, 
                              subject=strTitle, 
                              type=strTitle, 
                              IsReminderSet= true, 
                              Status='Completed', 
                              ActivityDate=date.today() +3, description=StrDesc);
            tsks.add(t);
        }
        return tsks;
    }
    
            
    public static List<Task> createTestTasks(Integer numTasks, List<Contact> Contacts, String strTaskType) {
        
        List<Task> tsks = new List<Task>();
        
        for (Contact c : Contacts) {
            for(Integer i = 0; i < numTasks; i++) {
                Task t = new Task(subject= strTaskType,
                                  type=strTaskType, 
                                  ActivitySource__c='User Created', 
                                  ActivityDate=date.today(), 
                                  whoid=c.id,
                                  whatid=c.accountid, description='test + '+ i );
                tsks.add(t);
            }
        }
        return tsks;
    }
    
    public static List<Task> createTestTasks_outlookPlugin(Integer numTasks, List<Contact> Contacts, String strTaskType) {
        
        List<Task> tsks = new List<Task>();
        
        for (Contact c : Contacts) {
            for(Integer i = 0; i < numTasks; i++) {
                Task t = new Task(subject= strTaskType,
                                  type=strTaskType, 
                                  ActivityDate=date.today(), 
                                  whoid=c.id, 
                                  whatid=c.accountid, description='test + '+ i );
                tsks.add(t);
            }
        }
        return tsks;
    }
    
    public static List<Event> createTestEvents(Integer numTasks, List<Contact> Contacts, String strEventType) {
        
        List<Event> events = new List<Event>();
        
        for (Contact c : Contacts) {
            for(Integer i = 0; i < numTasks; i++) {
                Event t = new Event(subject= strEventType,
                                  type=strEventType, 
                                  ActivityDate=date.today(), 
                                  whoid=c.id, 
                                    DurationInMinutes = 1,
                                    ActivityDateTime = Datetime.now(),
                                  whatid=c.accountid, description='test + '+ i );
                events.add(t);
            }
        }
        return events;
    }    
    
    public static List<Account> createTestAccounts(Integer numAccts) {
        
        List<Account> accts = new List<Account>();
        
        for(Integer i = 0; i < numAccts; i++){
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }
        //insert accts;
        return accts;
    }
    
    public static List<Account> createTestFirms(Integer numAccts){
        
        List<Account> accts = new List<Account>();
        List<RecordType> types = [SELECT SobjectType, Id, Name, IsActive FROM RecordType where SobjectType = 'Account' and Name ='Firm' and IsActive = True];
        
        for(Integer i = 0; i < numAccts; i++) {
            Account a = new Account(Name = 'TestFirm' + i);
            a.RecordTypeId = types[0].id;
            a.BillingCity  = 'Boston';
            a.BillingPostalCode = '02201';
            a.BillingStreet = '399 Boyston st';
            a.FirmType__c = 'DCIO';
            a.Status__c= 'Active';
            a.MarsAccountId__c = 'TESTFIRM' + i;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }
    
    public static List<Account> createTestAccountswithFirms(Integer numAccts, List<Account> parents){
        
        List<Account> accts = new List<Account>();
        Account p ;
        if( (parents != null)  && ( parents.size() > 0) )p = parents[0];
        for(Integer i = 0; i < numAccts; i++) {                        
            Account o = new Account(Name = 'Testoffice' + i);
            o.BillingCity  = 'Boston';
            o.BillingPostalCode = '02201';
            o.BillingStreet = '399 Boyston st';
            if ( p != null) o.ParentId = p.Id;
            o.Status__c= 'Active';
            accts.add(o);
        }
        //insert accts;
        return accts;
    }
    
    public static List<Contact> createTestContacts(Integer numConts, List<Account> Accounts, boolean BPL){
        
        List<Contact> conts = new List<Contact>();
        
        for (Account a : Accounts) {
            for(Integer i = 0; i < numConts; i++) {
                Contact ct = new Contact(FirstName = 'Test', LastName = 'TestContact' + a.Name + i,accountid=a.id, BPL__c= BPL, Email='Test'+i + '@Test.com');
                conts.add(ct);
            }
        }
        //insert conts;
        return conts;
    }
    
    public static List<Opportunity> createOpportunities(Integer numOpptys, List<Account> accounts){
        
        List<Opportunity> opptys = new List<Opportunity>();
        
        for (Account a : Accounts) {
            for(Integer i = 0; i < numOpptys; i++) {
                Opportunity o = new Opportunity(Name = 'Test Oppty ' + i, CloseDate = Date.TODAY(), StageName='Research',accountid=a.id);
                opptys.add(o);
            }
        }
        return opptys;
    }  
    
    public static List<Case> createCases(Integer numCases, List<Account> accounts){
        
        List<Case> cases = new List<Case>();
        
        for (Account a : Accounts) {
            for(Integer i = 0; i < numCases; i++) {
                Case c = new Case(Subject = 'Test Case ' + i, accountid=a.id);
                cases.add(c);
            }
        }
        
        return cases;
    }      
    
    public static List<FinancialAccount__c> createFinancialAccounts( integer numRecords) {
        List<FinancialAccount__c> conts = new List<FinancialAccount__c>();
        for(Integer i = 0; i < numRecords; i++) {                                  
            FinancialAccount__c fac = new  FinancialAccount__c();
            fac.Name ='Test'+ i;
            fac.ViewableinCommunity__c = TRUE;
            conts.add(fac);
        }
        
        return conts;
    }
        
    public static List<FinancialAccountContact__c> createFinancialAccountContacts( List<FinancialAccount__c> Accounts,List<Contact> contacts) {
        
        List<FinancialAccountContact__c> conts = new List<FinancialAccountContact__c>();
        
        for (FinancialAccount__c a : Accounts){                                   
            for (Contact c : contacts){
                FinancialAccountContact__c fac = new  FinancialAccountContact__c();
                fac.Contact__c = c.Id;
                fac.Status__c ='Current';
                fac.View_Financial_Account_in_Community__c  = true;
                fac.Financial_Account__c  = a.Id;
                conts.add(fac);
            }
        }        
        return conts;
    }
    
    public static List<Contact> createTestEndClients(Integer numConts){
        //NOTE: End Clients should not have accounts - ContactTriggerHandler creates and associates the account
        insertEstatementCommunityCustomSettings();
        
        ExternalCommunitySettings__c myCustomSetting = ExternalCommunitySettings__c.getValues('EstatementCommunity');
        List<Account> a = createTestFirms(1);
        a[0].Name = myCustomSetting.EndClientCommunityAccountName__c;
        insert a;
        
        List<Contact> conts = new List<Contact>();
        Id ECRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('End Client').getRecordTypeId();
        
        for(Integer i = 0; i < numConts; i++){
            Contact ct = new Contact(FirstName = 'ECTest' +1, LastName = 'ECTest' + i, Email='ECTest'+i + '@Test.com');
            ct.RecordTypeId = ECRecTypeId;                         
            conts.add(ct);
        }
        return conts;
    }
    
    public static List<FinancialAccountFile__c> createFinancialAccountFiles(Integer numFiles, List<FinancialAccount__c> finAccts){
        List<FinancialAccountFile__c> fafs = new List<FinancialAccountFile__c>();
        for (FinancialAccount__c a : finAccts){                    
            for(Integer i = 0; i < numFiles; i++){
                FinancialAccountFile__c f = new FinancialAccountFile__c( OriginalFileName__c ='Test ' + i);
                f.FinancialAccount__c = a.Id;
                fafs.add(f);
            }
        }
        //insert conts;
        return fafs;
    }
    
    public static void insertEstatementCommunityCustomSettings(){
        
        if (ExternalCommunitySettings__c.getValues('EstatementCommunity') == null) {
            ExternalCommunitySettings__c testCustomSettings = 
                new ExternalCommunitySettings__c(Name='EstatementCommunity',
                                                 EndClientCommunityAccountName__c='NGAM DISTRIBUTION, L.P., PORTAL END CLIENTS',
                                                 PermissionSetsForFAUser__c='Community_Login_User_eStatement',
                                                 UseTestEmail__c='Y',
                                                 AccountPrefix__c ='EstatementCommunity',
                                                 CommunitySenderDisplayName__c = 'PortalSolutions',
                                                 ExternalEmailTemplate__c = 'eStatement_Community_New_Statements_Posted',
                                                 PotalUserName__c = 'portalnatixis@ngam.natixis.com',
                                                 ProfileForFAUser__c='NGAM Community Plus Login User',
                                                 ProfileForEndClient__c='NGAM Community Plus Login User',
                                                 EndClientOwnerId__c = '005F0000007X7mm',
                                                 BatchUserJobNumberOfDays__c = '1',
                                                 MPAWebServiceUsername__c = '',
                                                 BatchJobCCemails__c = 'Neetu.Gupta@ngam.natixis.com;Tom.Barad@ngam.natixis.com',
                                                 ContactObjectEmailField__c='VestMarkEmail__c',
                                                 PemissionSetForEndClient__c='Community_Login_User_eStatement',
                                                 UserNameFormat__c='{0}{1}@portalsolutions.mpaoverlay.com.crmstage',
                                                 CommunityInternalSender__c = 'dat@ngam.natixis.com',
                                                 TestUserEmail__c='dat@ngam.natixis.com',
                                                 CommunitySenderEmail__c = 'portalsolutions@mpa.natixis.com',
                                                 InactivateDaysForUserLogin__c = 180,
                                                 UpdateVestMarkEmailInUserRecord__c = TRUE,
                                                 BatchNotifyFAJobNumberOfDays__c = '30',
                                                 BatchNotifyFASendAllorNone__c = false,
                                                 MPAWebServicePassword__c = '',                                                 
                                                 UseMPANamedCredential__c = 'MPA');
            insert testCustomSettings;
        }
    }
    
    //inserting the NGAM custom settings record
    Public static void CreateNGAMCustomSettings(){
        NGAMSettings__c ngamSettings = new NGAMSettings__c(Name='NGAM All',
                                                          ProfileDataOps__c ='NGAM Data Operations',
                                                          ProfileSales__c ='NGAM Sales',
                                                          ProfileIntegration__c ='NGAM Integration',
                                                          ProfilePardot__c ='NGAM Pardot Connector User ONLY',
                                                          ProfileSystemAdministrator__c='System Administrator',
                                                          ProfileForInactiveUsers__c='NGAM Inactive User',
                                                          ProfileStandardUser__c='Standard User',
                                                          ProfileCventIntegration__c='NGAM cVent Connector User Only');
        insert ngamSettings;
    }
    

    public static List<CDRQualitativeData__c> createCDRQualitativeData (Integer numRecords, 
                                                                        String recTypeName,  
                                                                        Id firstId, Id secondId) 
    {
        List<CDRQualitativeData__c> cdr = new List<CDRQualitativeData__c>();
        
        Id recTypeId = Schema.SObjectType.CDRQualitativeData__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        Id productId;
        Id accountId;
        Id contactId;
        Id benchmarkId;
        Id additionalInfoId;
        Id childProductId;
        Id childAccountId;
        
        if (recTypeName.equals('Additional Info')) additionalInfoId = firstId;
        if (recTypeName.equals('Benchmark')) benchmarkId = firstId;
        if (recTypeName.equals('Benchmark-Additional Info')) {
            benchmarkId = firstId;
            additionalInfoId = secondId;
        }
        if (recTypeName.equals('Contact')) contactId = firstId;
        if (recTypeName.equals('Contact-Additional Info')) {
            contactId = firstId;
            additionalInfoId = secondId;
        }
        if (recTypeName.equals('ETF') || recTypeName.equals('Mutual Fund') || recTypeName.equals('Share Class')) productId = firstId;
        if (recTypeName.equals('Firm')) accountId = firstId;
        if (recTypeName.equals('Firm-Additional Info')) {
            accountId = firstId;
            additionalInfoId = secondId;
        }
        if (recTypeName.equals('Firm-Child Firm')) {
            accountId = firstId;
            childAccountId = secondId;
        }
        if (recTypeName.equals('Firm-Contact')) {
            accountId = firstId;
            contactId = secondId;
        }
        if (recTypeName.equals('Firm-Product')) {
            accountId = firstId;
            productId = secondId;
        }
        if (recTypeName.equals('Product-Additional Info')) {
            productId = firstId;
            additionalInfoId = secondId;
        }
        if (recTypeName.equals('Product-Benchmark')) {
            productId = firstId;
            benchmarkId = secondId;
        }
        if (recTypeName.equals('Product-Child Product')) {                                                                                                                                                                                                          
            productId = firstId;
            childProductId = secondId;
        }
        if (recTypeName.equals('Product-Contact')) {
            productId = firstId;
            contactId = secondId;
        }
        
        for(Integer i = 0; i < numRecords; i++) {                                  
            CDRQualitativeData__c c = new CDRQualitativeData__c(Name='Test CDR ' + i, 
                                                                RecordTypeId = recTypeId, 
                                                                Product__c = productId, 
                                                                Account__c = accountId, 
                                                                Contact__c = contactId,
                                                                AdditionalInfo__c = additionalInfoId, 
                                                                Benchmark__c = benchmarkId, 
                                                                ChildProduct__c = childProductId,
                                                                ChildAccount__c = childAccountId);
            cdr.add(c);
        }
    return cdr;    
    }
    
}