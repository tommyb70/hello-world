global without sharing class SL_TerritoryToggleButton {

    @AuraEnabled global static List<UserTerritory__c> getUserTerritory() {
        List<UserTerritory__c> retVal = new List<UserTerritory__c>();
        for(UserTerritory__c item:[Select Id, TerritoryName__c, Territory__c, primaryterritory__c FROM UserTerritory__c where ownerid =: UserInfo.getUserId() order by primaryterritory__c desc ,TerritoryName__c limit 500]){
            retVal.add(item);
        }
        return retVal;
    }

    @AuraEnabled global static UserTerritory__c getUserPrimTerritory() {
        UserTerritory__c retVal = null;
        for(UserTerritory__c item: [select Id, TerritoryName__c, Territory__c from UserTerritory__c where PrimaryTerritory__c=true and ownerid =: UserInfo.getUserId() ORDER BY Territory__r.TerritoryType__c, Territory__r.Name]){
            retVal = item;
            system.debug('-----------------' + item.TerritoryName__c + '---' + item.Territory__c );
        }

        return retVal;
    }

    @AuraEnabled global static boolean getIsShowMe(){

        boolean isShowMe = false;
        List<UserTerritory__c> lstUserTerritory = new List<UserTerritory__c>();

        for(UserTerritory__c item:[select id from UserTerritory__c where ownerid =: UserInfo.getUserId() limit 2]){
            lstUserTerritory.add(item);
        }

        if (lstUserTerritory.size() > 1) { isShowMe = true;}

        return isShowMe;
    }

    @AuraEnabled
    public static boolean btnApply( String inPrimaryTerritory ) {

        if(inPrimaryTerritory!=null && inPrimaryTerritory!='') {

            try {
                UserTerritory__c ut = new UserTerritory__c(id=inPrimaryTerritory, PrimaryTerritory__c=true) ;
                update ut;

                // Update User Role
                /*
                UserTerritory__c uTerRec = [select ID,Territory__c, Territory__r.RoleId__c from UserTerritory__c where ID=:inPrimaryTerritory limit 1];
                if(uTerRec!=null && uTerRec.Territory__c!=null && uTerRec.Territory__r.RoleId__c!=null){
                    User uRec = new User(id=UserInfo.getUserId(),UserRoleId=uTerRec.Territory__r.RoleId__c);
                    update uRec;
                }
                */
            }
            catch (Exception ex) {
                throw new AuraHandledException('Something went wrong: ' + ex.getMessage());   
            }
        }
        
        return true;
    }

}