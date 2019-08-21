@isTest
public class PRCGResearchNoteTriggerHandlerTest {
    
    @testSetup 
    static void SetupTest() {
        
        List<Security__c> securities = new List<Security__c>();
        
        securities.add(new Security__c(Name='Test Security 1', MorningstarCode__c = '1', Ticker__c = 'TEST-REAL1'));
        securities.add(new Security__c(Name='Test Security 2', MorningstarCode__c = '2', Ticker__c = 'TEST-REAL2'));
        securities.add(new Security__c(Name='Test Security 3', MorningstarCode__c = '3', Ticker__c = 'TEST-REAL3'));
        securities.add(new Security__c(Name='Test Security 4', MorningstarCode__c = '4', Ticker__c = 'TEST-REAL4'));
        
        insert securities;
        
    }
    
    @isTest
    static void myTest() {
        
        Id analystNoteRecordTypeId = Schema.SObjectType.PRCGResearchNote__c.getRecordTypeInfosByName().get('PRC Analyst Note').getRecordTypeId();
        
        List<Security__c> testSecurities = [SELECT Id, Ticker__c FROM Security__c];
        
        List<PRCGResearchNote__c> validationNotes1 = new List<PRCGResearchNote__c>();
        
        validationNotes1.add(new PRCGResearchNote__c(Name='Test Note 1 Related Symbol', Security__c = testSecurities[0].Id, RecordTypeId = analystNoteRecordTypeId, 
                                                        RelatedSymbols__c = testSecurities[1].Ticker__c));
        
        validationNotes1.add(new PRCGResearchNote__c(Name='Test Note 2 Related Symbols', Security__c = testSecurities[0].Id, RecordTypeId = analystNoteRecordTypeId, 
                                                        RelatedSymbols__c = testSecurities[1].Ticker__c + ';' +  testSecurities[2].Ticker__c));
        
        validationNotes1.add(new PRCGResearchNote__c(Name='Test Note 3 Related Symbols', Security__c = testSecurities[0].Id, RecordTypeId = analystNoteRecordTypeId, 
                                                        RelatedSymbols__c = testSecurities[1].Ticker__c + ';' +  testSecurities[2].Ticker__c + ';' +  testSecurities[3].Ticker__c));
        
        PRCGResearchNote__c validationNote2 = new PRCGResearchNote__c(Name='Test Note 1 Fake Related Symbol', Security__c = testSecurities[0].Id, RecordTypeId = analystNoteRecordTypeId, 
                                                                          RelatedSymbols__c = 'FAKER');
        
        PRCGResearchNote__c validationNote3 = new PRCGResearchNote__c(Name='Test Note 2 Real, 1 Fake Related Symbol', Security__c = testSecurities[0].Id, RecordTypeId = analystNoteRecordTypeId, 
                                                                          RelatedSymbols__c = testSecurities[1].Ticker__c + ';' + 'FAKER' + ';' +  testSecurities[2].Ticker__c);    
        
        system.debug('validationNotes1: ' + validationNotes1);
        
        Test.startTest();
        insert validationNotes1;
        
        try
        {
            insert validationNote2;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('does not exist in the Securities object') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 

        try
        {
            insert validationNote3;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('does not exist in the Securities object') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        validationNotes1[0].RelatedSymbols__c = 'FAKER';

        try
        {
            update validationNotes1[0];
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('does not exist in the Securities object') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stopTest();

    }    
    
}