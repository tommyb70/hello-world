public class TableauVFController {
    
    public String tableauDomain {get;set;}
    
    public TableauVFController(){

    }    

    public PageReference getTableauDomain() {
        if (tableauDomain == null) {
			tableauDomain = TableauHelper.getTableauDomain();
        }
        return null;
    }
    
}