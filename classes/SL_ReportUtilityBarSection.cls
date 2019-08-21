global class SL_ReportUtilityBarSection {

    @AuraEnabled global static String getReportLinks(Boolean isLinkBarView) {
        String retVal = '{}';
        List<ReportUtilityBar__mdt> lstReportUBar = new List<ReportUtilityBar__mdt>();
        Set<String> setFldNames = new Set<String>();
        User uRecord = null;

        ReportUtilityBar__mdt selReportUtilityBar = null;
        
        for(ReportUtilityBar__mdt item:[SELECT Strength__c,UserFieldName__c,UserFieldValue__c,ID,MasterLabel,DeveloperName FROM ReportUtilityBar__mdt WHERE IsLinkBar__c = :isLinkBarView order by Strength__c desc limit 1000]){
            lstReportUBar.add(item);
            if(String.isNotBlank(item.UserFieldName__c)){
                setFldNames.add(item.UserFieldName__c);
            }
        }

        if(lstReportUBar.size()==0){
			throw new ReportUtilityBarException('There is no Report UtilityBar records');
        }

        if(setFldNames.size()>0){
            List<String> lstFldNames = new List<String>();
            lstFldNames.addAll(setFldNames);
            String qSOQL = 'SELECT ' + String.join(lstFldNames,',') +' FROM user where ID=\''+UserInfo.getUserId()+'\' LIMIT 1' ;

            try{
                List<sObject> lstObject = Database.query(qSOQL);
                uRecord = (User)lstObject[0];
            }
            catch(Exception e){
                throw new ReportUtilityBarException('Incorrect User Field Name in UtilityBar record'); 
            }
        }

        if(uRecord!=null){
            for(ReportUtilityBar__mdt item:lstReportUBar){

                String sUserFldVal = null;
                String fldName = item.UserFieldName__c;

                if(String.isBlank(fldName)){
                    selReportUtilityBar = item;
                    break;
                }

                String[] fldNameParts = fldName.split('\\.',2);

                if(fldNameParts.size()==1){
                    if(uRecord.get(fldNameParts[0])!=null){
                       sUserFldVal = ''+uRecord.get(fldNameParts[0]);
                    }
                }
                else if(fldNameParts.size()==2){
                    if(uRecord.getSobject(fldNameParts[0]).get(fldNameParts[1])!=null){
                       sUserFldVal = ''+uRecord.getSobject(fldNameParts[0]).get(fldNameParts[1]);
                    }
                }

                if(sUserFldVal == item.UserFieldValue__c){
                    selReportUtilityBar = item;
                    break;
                }
            }
        }
        else{
            selReportUtilityBar = lstReportUBar[0];
        }


        if(selReportUtilityBar!=null){

            Map<ID, ReportUtilityBarSectionWrapper> mapRepBarUtilSections = new Map<ID, ReportUtilityBarSectionWrapper>();

            for(ReportBarUtilitySection__mdt item:[SELECT ID,HeaderLabel__c,SortOrder__c from ReportBarUtilitySection__mdt where ReportUtilityBar__c =:selReportUtilityBar.ID order by SortOrder__c ASC limit 1000]){
                mapRepBarUtilSections.put(item.ID, new ReportUtilityBarSectionWrapper(selReportUtilityBar,item));
            }

            for(ReportUtilityBarItem__mdt item:[SELECT DisplayName__c,Sort_Order__c,URL__c,ID,MasterLabel,DeveloperName,ReportBarUtilitySection__c  FROM ReportUtilityBarItem__mdt where ReportBarUtilitySection__c in :mapRepBarUtilSections.keySet() order by Sort_Order__c ASC limit 1000]){
                mapRepBarUtilSections.get(item.ReportBarUtilitySection__c).lstUBarItems.add(item);
            }

            retVal = JSON.serialize(mapRepBarUtilSections.values());
        }
        else{
            throw new ReportUtilityBarException('System can not find associated Report Utility Bar record'); 
        }


        return retVal;
    }

    public class ReportUtilityBarSectionWrapper {

        public ReportUtilityBar__mdt recordUBar {get; set;}
        public ReportBarUtilitySection__mdt recordUBarSection {get; set;}
        public List<ReportUtilityBarItem__mdt> lstUBarItems {get; set;}

        public ReportUtilityBarSectionWrapper(ReportUtilityBar__mdt recordUBar, ReportBarUtilitySection__mdt recordUBarSection) {
            this.recordUBar = recordUBar;
            this.recordUBarSection = recordUBarSection;
            this.lstUBarItems = new List<ReportUtilityBarItem__mdt>();
        }

	}
	
    public class ReportUtilityBarException extends Exception {}

}