@IsTest
private class PRCGResearchNotes_Test {    
    static testMethod void getNotes() {
        
        NGAMSettingsHierarchy__c hsettings = NGAMSettingsHierarchy__c.getOrgDefaults();
        hsettings.ByPassAccountValidationRules__c  = TRUE;
        upsert hsettings NGAMSettingsHierarchy__c.Id;

        
        //insert account
        List<Account> myA = DataFactory.createTestAccounts(1);
        insert myA;
        
        //insert contact
        Contact contact = new Contact(LastName = 'Test', FirstName = '1',AccountId=myA[0].Id);
        insert contact;
        
        //insert case
        Case c = new Case();
        c.RecordType = new RecordType (Name ='PRCG Request');
        c.Contact = contact;
        insert c;
        
        //insert Request Models
        PRCGRequestModel__c requestModel = new PRCGRequestModel__c();
        requestModel.Case__c = c.Id;
        requestModel.ModelId__c = '1';
        insert requestModel;
        
        //insert security
        Security__c security1 = new Security__c();
        security1.Name = 'AXA fund 1';
        security1.Ticker__c = 'AXA1';
        security1.MorningstarCode__c = '1';
        insert security1;
        
        //insert security
        Security__c security2 = new Security__c();
        security2.Name = 'AXA fund 2';
        security2.Ticker__c = 'AXA2';
        security2.MorningstarCode__c = '2';
        insert security2;
                     
        //insert request portfolios
        PRCGModelSecurity__c modelSecurity1 = new PRCGModelSecurity__c();
        modelSecurity1.Security__c = security1.Id;
        modelSecurity1.PRCGRequestModel__c = requestModel.Id;
        insert modelSecurity1;     
        
        //insert request portfolios
        PRCGModelSecurity__c modelSecurity2 = new PRCGModelSecurity__c();
        modelSecurity2.Security__c = security2.Id;
        modelSecurity2.PRCGRequestModel__c = requestModel.Id;
        insert modelSecurity2;   
        
        //insert research note
        PRCGResearchNote__c note1 = new PRCGResearchNote__c();
        note1.Note__c = 'This is test3';
        //note1.Subject__c = 'General';
        note1.Approval_Status__C = 'Approved';
        note1.Security__c = security1.Id;
        insert note1; 
        
        //insert research note
        PRCGResearchNote__c note2 = new PRCGResearchNote__c();
        note2.Note__c = 'This is test2';
        //note2.Subject__c = 'General';
        note2.Approval_Status__C = 'Approved';
        note2.Security__c = security2.Id;
        insert note2;   
        
         //insert research note
        PRCGResearchNote__c note3 = new PRCGResearchNote__c();
        note3.Note__c = 'This is test3';
        //note3.Subject__c = 'General';
        note3.Approval_Status__C = 'Approved';
        note3.Security__c = security1.Id;
        insert note3;     
      
        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        PRCGResearchNotes prn = new PRCGResearchNotes(sc);
        Map<string, List<PRCGResearchNote__c>> m = prn.getnoteMap(c.Id);
          
      
        Test.stopTest();
        
        system.debug('Size:' + m.size());
        
    }
}