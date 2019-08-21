/**
 * @author Pratibha Potluri
 * @Created Date: 09/05/2018
 * @description : trigger on Benchmark Performance to assign the benchmark into the product performance. 
**/
 
 //Trigger will fire when a record is created or Updated on BenchmarkPerformance

 trigger BenchmarkPerformanceTrigger on BenchmarkPerformance__c(after Insert,after Update) {
    BenchmarkPerformanceTriggerHandler.populateProductPerformance(trigger.new);
 }