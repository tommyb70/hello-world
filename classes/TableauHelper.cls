public class TableauHelper {
    
    public static String getTableauDomain() {
        
        String tableauDomain;
        
        NGAMSettings__c settings = NGAMSettings__c.getvalues('NGAM_ALL');
        Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if (org.IsSandbox == FALSE) {
            tableauDomain = settings.TableauProductionDomain__c;
        } else {
            tableauDomain = settings.TableauQADomain__c;
        }
        
        return tableauDomain;
    }

    public static String getTableauParametersNotAvailableMsg() {

        NGAMSettings__c settings = NGAMSettings__c.getvalues('NGAM_ALL');
        String msg = settings.TableauParametersNotAvailableMsg__c;
        return msg;

    }





/*    public static String getTableauVisualization(SObject o, String vt) {
        
        String v;
        
        if (String.isBlank(vt)) vt = 'Default';
        
        String objectName = o.getSObjectType().getDescribe().getName();
        
        TableauVisualization__mdt vm = [SELECT Visualization__c FROM TableauVisualization__mdt
                                        WHERE VisualizationType__c = :vt
                                        AND ObjectAPIName__c = :objectName
                                        LIMIT 1];
        
        v = vm.Visualization__c;
        
        return v;
    }   */ 
    
}