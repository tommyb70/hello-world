public with sharing class ChartExtension {
	
	public ChartExtension(ApexPages.StandardController controller) {
		
	}

	//Determine if this is SF1 app
    public Boolean isSF1{
        get  {
            Map<String, String> aIncomeParams = ApexPages.currentPage().getParameters();
            if(String.isNotBlank(aIncomeParams.get('sfdcIFrameHost')) ||
                String.isNotBlank(aIncomeParams.get('sfdcIFrameOrigin')) ||
                aIncomeParams.get('isdtp') == 'p1' ||
                (aIncomeParams.get('retURL') != null && aIncomeParams.get('retURL').contains('projectone') )
            ){
                return true;
            } else {
                return false;
            }
        }
    }
}