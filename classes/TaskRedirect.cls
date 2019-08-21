public with sharing class TaskRedirect {
	private sobject obj {get; set;}

	public TaskRedirect(ApexPages.StandardController stdController) {
		this.obj = stdController.getRecord();
	}

	public pageReference redirectContact()
	{
		COntact con = [select id, FirmBranchID18__c, account.Name, Name from Contact where id = :obj.ID];
		PageReference NewTaskPage = Page.TaskNew;
        Map<String, String> aData = new Map<String, String>{
            'status' => 'Completed',
            'whatid' => con.FirmBranchID18__c,
            'whatid_text' => con.account.name,
            'whoid' => con.ID,
            'whoid_text' => con.Name,
            'activitydate' => Datetime.now().format('yyy-MM-dd')
        };
        NewTaskPage.getParameters().putAll(new Map<String, String>{
            'predefine' => JSON.serialize(aData),
            'somefield' => 'lalala',
            'nooverride' => '1'
            
        });  

		NewTaskPage.setRedirect(true);
		return NewTaskPage;
	}	

	public pageReference redirectOpportunity()
	{
		Opportunity opp = [select id, Name from Opportunity where id = :obj.ID];
		PageReference NewTaskPage = Page.TaskNew;
        Map<String, String> aData = new Map<String, String>{
            'status' => 'Completed',
            'opportunity__c' => opp.ID,
            'opportunity__c_text' => opp.Name,
            'activitydate' => Datetime.now().format('yyy-MM-dd')
        };
        NewTaskPage.getParameters().putAll(new Map<String, String>{
            'predefine' => JSON.serialize(aData),
            'somefield' => 'lalala',
            'nooverride' => '1'
            
        });  

		NewTaskPage.setRedirect(true);
		return NewTaskPage;
	}	

	public pageReference redirectAccount()
	{
		Account acc = [select id, Name from Account where id = :obj.ID];
		PageReference NewTaskPage = Page.TaskNew;
        Map<String, String> aData = new Map<String, String>{
            'status' => 'Completed',
            'whatid' => acc.ID,
            'whatid_text' => acc.name,
            'activitydate' => Datetime.now().format('yyy-MM-dd')
        };
        NewTaskPage.getParameters().putAll(new Map<String, String>{
            'predefine' => JSON.serialize(aData),
            'somefield' => 'lalala',
            'nooverride' => '1'
            
        });  

		NewTaskPage.setRedirect(true);
		return NewTaskPage;
	}
}