public with sharing class SL_RecordTypeIdentifier {

    @InvocableMethod(label='Get Record Type From Id' description='Takes an Id and returns a record type.')
    public static List<String> getAccountNames(List<Id> idsToCheck) {
        List<String> objectTypes = new List<String>();
        for (Id idToCheck : idsToCheck) {
            objectTypes.add(idToCheck.getSObjectType().getDescribe().getName());
        }
        return objectTypes;
    }
}