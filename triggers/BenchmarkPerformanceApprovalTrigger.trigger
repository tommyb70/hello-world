/**
 * @author Pratibha Potluri
 * @Created Date: 09/04/2018
 * @description : trigger on Benchmark Performance Approval to move the data into the Benchmark 
                  Performance obj based on conditions. 
**/

trigger BenchmarkPerformanceApprovalTrigger on BenchmarkPerformanceApproval__c(after Insert,after update){
    
    if(trigger.isAfter){
        BenchmarkPerformApprovalTriggerHandler.afterActions(trigger.new);
    }
}