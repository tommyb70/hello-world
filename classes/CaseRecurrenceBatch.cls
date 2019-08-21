global class CaseRecurrenceBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String query = 'SELECT Id, AccountId, BusinessHoursId, Origin, OwnerId, Reason, RecordTypeId, ' +
        ' ContactId, Description, Priority, Status, Subject, Type, ' +
        ' AdTraxCode__c, AffiliateFirmName__c, CaseRegionDept__c, CaseTerritory__c, ' +
        ' CreateRecurrence__c, DeliveryMethod__c, Department__c, DueDate__c, Duration__c, ' +
        ' Format__c, Frequency__c, Level__c, Purpose__c, ' +
        ' NewOrExistingBusiness__c, NewProductStrategy__c, Opportunity__c, ' +
        ' ProductStrategyMutualFund__c, RecurrenceDate__c, RecurrenceSourceCase__c,' + 
        ' RecurrenceTargetCase__c, RequestDate__c, Requestor__c, RequesterChannel__c, ' +
        ' RequesterTerritory__c, RequestFor__c, ' +
        ' SubmittedOnBehalfOf__c, ' +
        ' Vehicle__c ' +
        ' FROM Case ' +
        ' WHERE CreateRecurrence__c = TRUE ';
    
    public Set<Id> clonedCasesIdSet = new Set<Id>();
    
    public static NGAMSettings__c settings = NGAMSettings__c.getValues('NGAM_ALL');
    public static Integer leadTime = (Integer)settings.CaseRecurrenceLeadTime__c;
    public static String emailToAddresses = settings.CaseRecurrenceToEmail__c;
    public static Group IPMQueue = [SELECT Id FROM Group WHERE Name = 'IPM' AND Type = 'Queue' LIMIT 1];
    public static User NGAMIntegrationId = [SELECT Id FROM User WHERE Username LIKE 'inatixis@%natixis%' LIMIT 1];
    public static List<Case> clonedCases = new List<Case>();
    public static List<Case> casesToClone = new List<Case>();
    
    global Database.querylocator start(Database.BatchableContext BC){   
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope)	{ 
        
        //        NGAMSettings__c settings = NGAMSettings__c.getValues('NGAM_ALL');
        //        Integer leadTime = (Integer)settings.CaseRecurrenceLeadTime__c;
        //        String emailToAddresses = settings.CaseRecurrenceToEmail__c;
        
        Date leadTimeDate = date.Today().addDays(leadTime);
        Map<Id,Case> casesToUpdateMap = new Map<Id,Case>();
        
        Set<Id> userCheckSet = new Set<Id>();
        
        for (Case c : scope) {
            userCheckSet.add(c.Requestor__c);
            userCheckSet.add(c.OwnerId);
        }
        
        Map<Id,User> userCheckMap = new Map<Id,User>([SELECT Id FROM User WHERE IsActive = TRUE AND Id IN :userCheckSet]);
        
        for (Case c : scope) {
            
            switch on c.Frequency__c {
                when 'Monthly' {
                    c.RecurrenceDate__c = c.DueDate__c.addMonths(1);
                }
                when 'Quarterly' {
                    c.RecurrenceDate__c = c.DueDate__c.addMonths(3);
                }
                when 'Semi-Annually' {
                    c.RecurrenceDate__c = c.DueDate__c.addMonths(6);
                }
                when 'Annually' {
                    c.RecurrenceDate__c = c.DueDate__c.addYears(1); 
                }
            }
            
            if (!userCheckMap.containsKey(c.OwnerId)) c.OwnerId = IPMQueue.Id;            
            if (!userCheckMap.containsKey(c.Requestor__c)) c.Requestor__c = NGAMIntegrationId.Id;
            
            casesToUpdateMap.put(c.Id, c);
            if (c.RecurrenceDate__c <= leadTimeDate) casesToClone.add(c); 
        }
        
        for (Case c : casesToClone) {
            Case cClone = c.clone(false,true,false,false);
            cClone.RecurrenceSourceCase__c = c.Id;
            cClone.Case_Closed_by__c = null;
            cClone.DateRequestCompleted__c = null;
            cClone.OtherReason__c = null;
            cClone.Reason_for_Late_Delivery__c = null;
            cClone.RecurrenceTargetCase__c = null;
            cClone.RushRequest__c = FALSE;
            cClone.RushRequestReason__c = null;
            cClone.Status = 'New';
            cClone.Origin = 'Recurrence Batch';
            cClone.DueDate__c = c.RecurrenceDate__c;
            
            switch on cClone.Frequency__c {
                when 'Monthly' {
                    cClone.RecurrenceDate__c = cClone.DueDate__c.addMonths(1);
                }
                when 'Quarterly' {
                    cClone.RecurrenceDate__c = cClone.DueDate__c.addMonths(3);
                }
                when 'Semi-Annually' {
                    cClone.RecurrenceDate__c = cClone.DueDate__c.addMonths(6);
                }
                when 'Annually' {
                    cClone.RecurrenceDate__c = cClone.DueDate__c.addYears(1); 
                }
            }

            clonedCases.add(cClone);
            
        }
        
        insert clonedCases;
        
        for (Case c : clonedCases) {
            Case tc = casesToUpdateMap.get(c.RecurrenceSourceCase__c);
            tc.RecurrenceTargetCase__c = c.Id;
            tc.CreateRecurrence__c = FALSE;
            casesToUpdateMap.put(c.RecurrenceSourceCase__c,tc);
            clonedCasesIdSet.add(c.Id);
        }
        
        update casesToUpdateMap.values();
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        Datetime yesterdayDateTime = Datetime.now().addDays(-1);
        
        clonedCases = [SELECT Id, AccountId, BusinessHoursId, CaseNumber, Origin, OwnerId, Reason, RecordTypeId, ContactId, Description, Priority, Status, Subject, Type,
                       AdTraxCode__c, Client_Type__c, CompletedDate__c, CreateRecurrence__c, DateRequestCompleted__c, DeliveryMethod__c, DueDate__c, Format__c, Frequency__c, 
                       Level__c, NewProductStrategy__c, Opportunity__c, Reason_for_Late_Delivery__c, RecurrenceDate__c, OtherReason__c, RecurrenceSourceCase__c, RecurrenceTargetCase__c, 
                       Requestor__c, RushRequest__c, RushRequestReason__c, Vehicle__c, Case_Closed_by__c, RecurrenceSourceCase__r.CaseNumber, RecurrenceSourceCase__r.Subject 
                       FROM Case
                       WHERE Id in :clonedCasesIdSet];
        
        if (!clonedCases.isEmpty()) {
            String body = '<p>Number of Cases Cloned: ' + clonedCases.size() + '</p>';
            String tBody = '<br/><table  border= "1" >';
            tbody = tBody + '<tr><th> Case </th><th> Cloned From </th><th> Subject </th><th> Frequency </th><th> Due Date </th></tr>';
            
            for (Case c : clonedCases) {
                
                tBody = tBody + '<tr><td>' + c.CaseNumber + '</td><td>' + c.RecurrenceSourceCase__r.CaseNumber + '</td><td>' +  c.Subject + '</td><td>' + c.Frequency__c  + '</td><td>' + c.DueDate__c.format() + '</td></tr>';
                
            }    
            
            tBody = tBody + '</table><br/>';
            body = body +tBody;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = emailToAddresses.Split(',');            
            String[] toAddresses = new String[] {'tom.barad@natixis.com'};            
                mail.setToAddresses(toAddresses);
            mail.setSubject('Clone Recurring Cases Batch');
            mail.setHTMLBody(body);
            
            try {
                if (!Test.IsRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (EmailException e) {
                throw new emailException('SendEmail error. ' + e.getMessage());
            }
            
        }
    }
    
}