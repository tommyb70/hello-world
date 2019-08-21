@isTest
public class CaseRecurrenceBatchTest {
    
    @testSetup
    static void setup() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;


        NGAMSettings__c settings = new NGAMSettings__c(Name = 'NGAM_ALL', CaseRecurrenceLeadTime__c = 30, CaseRecurrenceToEmail__c = 'dat@natixis.com');
        insert settings;
        
        List<Account> firms = DataFactory.createTestFirms(1);
        insert firms;
        List<Account> accts = DataFactory.createTestAccountswithFirms(1,firms);
        insert accts;
        List<Contact> contacts = DataFactory.createTestContacts(1,accts,FALSE);
        insert contacts;
        
        Date duedate = Date.newInstance(2016,12,10);
        
        List<Case> cases = new List<Case>();
        Case monthly = new Case(Subject = 'Monthly', Frequency__c = 'Monthly', DueDate__c = duedate, AccountId = accts[0].Id, 
                               ContactId = contacts[0].Id, CreateRecurrence__c = TRUE);        
        cases.add(monthly);
        
        Case quarterly = new Case(Subject = 'Quarterly', Frequency__c = 'Quarterly', DueDate__c = duedate, AccountId = accts[0].Id, ContactId = contacts[0].Id,
                               CreateRecurrence__c = TRUE);        
        cases.add(quarterly);
        
        Case semiannual = new Case(Subject = 'Semi-Annually', Frequency__c = 'Semi-Annually', DueDate__c = duedate, AccountId = accts[0].Id, ContactId = contacts[0].Id,
                               CreateRecurrence__c = TRUE);        
        cases.add(semiannual);
        
        Case annual = new Case(Subject = 'Annually', Frequency__c = 'Annually', DueDate__c = duedate, AccountId = accts[0].Id, ContactId = contacts[0].Id,
                               CreateRecurrence__c = TRUE);        
        cases.add(annual);
        insert cases;
        
    }
    
    @isTest static void caseRecurrenceBatchTest() {
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new CaseRecurrenceBatch());
        Test.stopTest();
        
        List<Case> allCases = [SELECT Id, Frequency__c, Subject, CreateRecurrence__c, DueDate__c, RecurrenceDate__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c
                               FROM Case];
        
        system.debug('allCases: ' + allCases);

        List<Case> mCases = [SELECT Id, Frequency__c, Subject, CreateRecurrence__c, DueDate__c, RecurrenceDate__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c
                                  FROM Case WHERE Frequency__c = 'Monthly' ORDER BY DueDate__c];
        
        List<Case> qCases = [SELECT Id, Frequency__c, Subject, CreateRecurrence__c, DueDate__c, RecurrenceDate__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c
                                  FROM Case WHERE Frequency__c = 'Quarterly' ORDER BY DueDate__c];

        List<Case> sCases = [SELECT Id, Frequency__c, Subject, CreateRecurrence__c, DueDate__c, RecurrenceDate__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c
                                  FROM Case WHERE Frequency__c = 'Semi-Annually' ORDER BY DueDate__c];

        List<Case> aCases = [SELECT Id, Frequency__c, Subject, CreateRecurrence__c, DueDate__c, RecurrenceDate__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c
                                  FROM Case WHERE Frequency__c = 'Annually' ORDER BY DueDate__c];

        system.assertequals(allCases.size(),8);
        system.assertEquals(mCases[0].Id,mCases[1].RecurrenceSourceCase__c);
        system.assertEquals(mCases[0].RecurrenceDate__c, mCases[1].DueDate__c);

        system.assertEquals(mCases[0].RecurrenceDate__c,Date.newInstance(2017,1,10));
        system.assertEquals(qCases[0].RecurrenceDate__c,Date.newInstance(2017,3,10));
        system.assertEquals(sCases[0].RecurrenceDate__c,Date.newInstance(2017,6,10));
        system.assertEquals(aCases[0].RecurrenceDate__c,Date.newInstance(2017,12,10));
                
    }
    
}