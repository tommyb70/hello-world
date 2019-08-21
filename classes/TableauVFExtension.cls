public class TableauVFExtension {
    
    public String tableauDomain {get;set;}
    public String tableauParametersNotAvailableMsg {get;set;}
    private final SObject obj {get;set;}
    
    public TableauVFExtension(ApexPages.StandardController controller) {
        this.obj = (SObject)controller.getRecord();
        this.tableauDomain = TableauHelper.getTableauDomain();
        this.tableauParametersNotAvailableMsg = TableauHelper.getTableauParametersNotAvailableMsg();
    }
    
}