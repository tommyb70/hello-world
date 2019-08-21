public class RunCaseAssignmentRules {
    
    @InvocableMethod(label='Run Case Assignment Rules' description='Runs case assignment rules')
    public static void runCaseAssignmentRules(List<Case> cases) {
        
        Map<Id,Case> runRulesCases = new Map<Id,Case>();
        
        for (case c : cases) {
            runRulesCases.put(c.Id,new Case(Id = c.Id,RunCaseAssignmentRules__c=FALSE));
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = TRUE;
        Database.update(runRulesCases.values(), dmo);
        
    }
    
}