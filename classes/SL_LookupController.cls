public class SL_LookupController {
	@AuraEnabled(cacheable=true)
	public static List<SObject> search(String searchString, String objectName, String fields, 
	String soslParams, Integer limitOfRecords, List<Id> excludeIds) {

		String query = 'SELECT ' + fields + ' FROM ' + objectName + 
					   ' WHERE ' + fields + ' LIKE \'%'+ searchString +'%\' ' ;
		if(soslParams != null){
			query += ' AND ' + soslParams;
		}
		
		if(excludeIds.size() > 0){
			query += ' AND Id NOT IN   : excludeIds ';
		}
		query += ' ORDER BY  ' + fields + ' LIMIT '  + limitOfRecords;

		List<sObject> resultList = Database.query(query);
		return resultList;  
	}

	@AuraEnabled(cacheable=true)
	public static List<SObject> searchProduct( String searchString, String pricebookId, String soslParams, Integer limitOfRecords) {

		String query = 'SELECT product2id, product2.name FROM pricebookentry ' + 
					   ' WHERE  IsActive = TRUE AND pricebook2id =: pricebookId AND product2.name LIKE \'%' + searchString +'%\' ' ;
		if(soslParams != null){
			query += ' AND ' + soslParams;
		}

		query += ' ORDER BY product2.name LIMIT '  + limitOfRecords;

		List<sObject> resultList = Database.query(query);
		return resultList;  
	}

    @AuraEnabled
	public static SObject getRecord(String recordId, String objectName, String mainField, String subField) {
        Set<String> fieldsToQuery = new Set<string>();
        fieldsToQuery.add('Id');
        fieldsToQuery.add(mainField);
        fieldsToQuery.add(subField);
	    String query = 'SELECT ' + String.join(new List<String> (fieldsToQuery), ', ') +  ' FROM ' + objectName + ' WHERE Id = :recordId';
        List<sObject> resultList = Database.query(query);
        return resultList[0];
	}

	@AuraEnabled
	public static SObject getRecordProduct(String recordId) {
        
	    String query = 'SELECT id, name FROM product2 ' + 
					   ' WHERE  id =: recordId ' ;
        List<sObject> resultList = Database.query(query);
        return resultList[0];
	}

	@AuraEnabled
	public static List<SObject> getMultiRecords(List<ID> recordIds, String objectName, String mainField, String subField) {
        List<sObject> resultList = new List<sObject>();
		System.debug(recordIds);
		if(recordIds!=null && recordIds.size()>0)
		{
			Set<String> fieldsToQuery = new Set<string>();
			fieldsToQuery.add('Id');
			fieldsToQuery.add(mainField);
			fieldsToQuery.add(subField);
			String query = 'SELECT ' + String.join(new List<String> (fieldsToQuery), ', ') +  ' FROM ' + objectName + ' WHERE Id in :recordIds';
			resultList = Database.query(query);
		}
        return resultList;
	}    

}