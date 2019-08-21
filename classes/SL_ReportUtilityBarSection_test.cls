@isTest
public class SL_ReportUtilityBarSection_test {

    @isTest
    public static void getReportLinks_test() {
        try{
            SL_ReportUtilityBarSection.getReportLinks(true);
            SL_ReportUtilityBarSection.getReportLinks(false);
        }catch(Exception ex){

        }
    }

}