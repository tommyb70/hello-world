public with sharing class SL_RecordTypeSelection {

    @AuraEnabled
	public static List<Map<String,String>> getRecordTypeList(String objectName) {

        List<Map<String,String>> retVal = new List<Map<String,String>>();
        Set<ID> setIDs = new Set<ID>();

        Schema.DescribeSObjectResult doOpportunityRTs = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo> rtMapByOpportunity = doOpportunityRTs.getRecordTypeInfosByName(); 
        for(String rtTypeInfo: rtMapByOpportunity.keySet())
        {
            Schema.RecordTypeInfo rTypeInfo = rtMapByOpportunity.get(rtTypeInfo);
            if(rTypeInfo.isActive() && !rTypeInfo.isMaster() && rTypeInfo.isAvailable()){
                setIDs.add(rTypeInfo.getRecordTypeId());
            }
        }

        for(RecordType item:[select ID, Name, Description from RecordType where ID in :setIDs]){
            retVal.add(new Map<String, String>{'label' => item.Name, 'value' => item.ID, 'desc' => item.Description});
        }

        return retVal;

	}

}