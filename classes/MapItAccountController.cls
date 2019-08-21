public class MapItAccountController
{
    private ApexPages.StandardController stdCtrl {get; set;}
    
    public List<sObject> Records {get; set;}
    public list<string> recordIds {get; set;}
    
    public string baseObjectId {get; set;}
    public string MapItURL {get; set;}
    Environment_Settings__c cs = Environment_Settings__c.getOrgDefaults();
    
    public MapItAccountController(ApexPages.StandardController std)
    {

    }
    
    public MapItAccountController(ApexPages.StandardSetController controller) 
    {
        Records = controller.getSelected();
        
        recordIds = new list<string>();
        
        for (sObject r : Records)
        {
            recordIds.add(r.Id);
        }        
        
        if (recordIds.size() > 0)
        {
            string objectAPIName;
            
            for(Schema.SObjectType t : Schema.getGlobalDescribe().values())
            {
                Schema.DescribeSObjectResult descr = t.getDescribe();
            
                if (descr.getKeyPrefix() != null)
                {
                    if(recordIds[0].startsWith(descr.getKeyPrefix()))
                    {
                        objectAPIName = descr.getName();
                        break;
                    }
                }
            }        
            
            if (objectAPIName == 'Account')
            {
                baseObjectId = cs.MapAnything_Account_Base_Object_Id__c;
            }
            
            MapItURL = '/apex/sma__MapAnything?baseObjectId=' + baseObjectId;
            
            for (sma__MABaseObject__c  bo : [SELECT Id, sma__Tooltip1__c, sma__Tooltip2__c, sma__Tooltip3__c, sma__Tooltip4__c, sma__Tooltip5__c, sma__Tooltip6__c, sma__Tooltip7__c, sma__Tooltip8__c, sma__Tooltip9__c, sma__Tooltip10__c,
                                                sma__Tooltip11__c, sma__Tooltip12__c, sma__Tooltip13__c, sma__Tooltip14__c, sma__Tooltip15__c, sma__MapIt_Zoom_Control__c, sma__MapIt_Proximity_On__c, sma__MapIt_Proximity_Radius__c, 
                                                sma__MapIt_Proximity_Measurement_Unit__c
                                                FROM sma__MABaseObject__c  WHERE Id=:baseObjectId])
            {
                if (bo.sma__Tooltip1__c != null)
                {
                    MapItURL += '&tooltipField=' + bo.sma__Tooltip1__c;
                }
                
                if (bo.sma__Tooltip2__c != null)
                {
                    MapItURL += '&tooltipField2=' + bo.sma__Tooltip2__c;
                }

                if (bo.sma__Tooltip3__c != null)
                {
                    MapItURL += '&tooltipField3=' + bo.sma__Tooltip3__c;
                }
                
                if (bo.sma__Tooltip4__c != null)
                {
                    MapItURL += '&tooltipField4=' + bo.sma__Tooltip4__c;
                }
                
                if (bo.sma__Tooltip5__c != null)
                {
                    MapItURL += '&tooltipField5=' + bo.sma__Tooltip5__c;
                }

                if (bo.sma__Tooltip6__c != null)
                {
                    MapItURL += '&tooltipField6=' + bo.sma__Tooltip6__c;
                }
                
                if (bo.sma__Tooltip7__c != null)
                {
                    MapItURL += '&tooltipField7=' + bo.sma__Tooltip7__c;
                }
                
                if (bo.sma__Tooltip8__c != null)
                {
                    MapItURL += '&tooltipField8=' + bo.sma__Tooltip8__c;
                }
                
                if (bo.sma__Tooltip9__c != null)
                {
                    MapItURL += '&tooltipField9=' + bo.sma__Tooltip9__c;
                }
                
                if (bo.sma__Tooltip10__c != null)
                {
                    MapItURL += '&tooltipField10=' + bo.sma__Tooltip10__c;
                }
                
                if (bo.sma__Tooltip11__c != null)
                {
                    MapItURL += '&tooltipField11=' + bo.sma__Tooltip11__c;
                }  
                
                if (bo.sma__Tooltip12__c != null)
                {
                    MapItURL += '&tooltipField12=' + bo.sma__Tooltip12__c;
                }  

                if (bo.sma__Tooltip13__c != null)
                {
                    MapItURL += '&tooltipField13=' + bo.sma__Tooltip13__c;
                }  
            
                if (bo.sma__Tooltip14__c != null)
                {
                    MapItURL += '&tooltipField14=' + bo.sma__Tooltip14__c;
                }  
                
                if (bo.sma__Tooltip15__c != null)
                {
                    MapItURL += '&tooltipField15=' + bo.sma__Tooltip15__c;
                }                  
                
                if (bo.sma__MapIt_Zoom_Control__c != null)
                {
                    MapItURL += '&zoom=' + bo.sma__MapIt_Zoom_Control__c;
                }                   
            }
        }
    }
    
    public PageReference Redirect() 
    {
        PageReference newRef = new PageReference(MapItURL + '&color=%23FFA500&recordIds=' + EncodingUtil.urlEncode(string.join(recordIds, ','),'UTF-8'));
        newRef.setRedirect(true);
        return newRef;
    }    
}