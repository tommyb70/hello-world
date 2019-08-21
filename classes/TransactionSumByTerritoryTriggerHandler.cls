public class TransactionSumByTerritoryTriggerHandler {
	public static void updtBusinessDays(List<TransactionSummaryByTerritory__c> tstl) {
		System.debug('Number of TransactionSummaryByTerritory__c' + tstl.size());
		TransactionSummaryByTerritory__c tst = tstl.get(0);
		List<NGAMSettings__c> l = [select Id, WorkDays__c, BusinessDays__c from NGAMSettings__c];
		if(l == null || l.size() == 0) return;
		NGAMSettings__c setting = l.get(0);
		Decimal workDays = tst.BusinessDays__c - tst.BusinessDaysRest__c;
		if(tst.BusinessDays__c == setting.BusinessDays__c && workDays == setting.WorkDays__c) return;
		List<NGAMSettings__c> sl = new List<NGAMSettings__c>();
		NGAMSettings__c s = new NGAMSettings__c(Id = setting.Id, BusinessDays__c = tst.BusinessDays__c, WorkDays__c = workDays);
		update s;		 			
	}
}