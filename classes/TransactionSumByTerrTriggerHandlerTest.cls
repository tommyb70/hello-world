/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TransactionSumByTerrTriggerHandlerTest {

    static testMethod void updtBusinessDaysTest() {
    	Territory__c t = new Territory__c(TerritoryName__c = 'WHSE TERR1');    	
    	insert t;
    	NGAMSettings__c ngs = new NGAMSettings__c(Name = 'NGAM_ALL', WorkDays__c = 0, BusinessDays__c = 0);
    	insert ngs;
    	TransactionSummaryByTerritory__c  tst = new TransactionSummaryByTerritory__c(
    		TranSumTerrId__c = '12345',
    		Territory__c = t.Id,
			ProductType__c = 'MF',
			BusinessDays__c = 21,
			BusinessDaysRest__c = 12,
			DailyPurchases__c = 10000,
			DailyRedemptions__c = 20000,
			MonthlyPurchases__c = 100000,
			MonthlyRedemptions__c = 100000,
			YearlyPurchases__c = 100000,
			YearlyRedemptions__c = 100000,
			MonthlyGoal__c = 300000,
			MTDGoal__c = 10000,
			YearlyGoal__c = 200000,
			YTDGoal__c = 10000000    			
    	);
    	insert tst;
		List<NGAMSettings__c> l = [select Id, WorkDays__c, BusinessDays__c from NGAMSettings__c];
    	System.assertEquals(1, l.size());
    	NGAMSettings__c sc = l.get(0);
    	System.assertEquals(21, sc.BusinessDays__c);
    	System.assertEquals(21 - 12, sc.WorkDays__c);
    }
}