/**
    *  Class Name     : SL_AcceptCaseButtonController
    *  ModifiedOn     : 02/July/2019
    *  ModifiedBy     : Privlad 
    *  Description    : This is the Controller for LC SL_AcceptCaseButton.
*/
global class SL_AcceptCaseButtonController {

    @AuraEnabled
    public static void updateCaseLEX(Id caseId)
    {
        Case caseRec = new Case(ID=caseId, OwnerId=UserInfo.getUserId());
        update caseRec;
    }
}