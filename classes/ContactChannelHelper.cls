public class ContactChannelHelper {
    
    public static Map<id,Channel__c> ChannelMap {
        get {
            if (ChannelMap == null) {
                ChannelMap = new Map<id,Channel__c>([Select Id, Name, TierField__c, ZoneField__c, FocusFirmField__c from Channel__c ]);
            }
            return ChannelMap;
        }
        set;
    }
        
    public static Map<id,Contact> ContactChannelFieldMap(Set<Id> ContactIds) {
        //Takes a set of contact Ids and return a map of the the contact with channel-defined field data
        
        Set<String> channelContactFields = ChannelFieldSet();
        
        //Get all Contact fields from schema
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Contact.fields.getMap();        
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        //Build the query using fields from contact if they exist in the set of fields from channel
        String theQuery = 'SELECT Id, ';        
        for(Schema.SObjectField s : fldObjMapValues)        {           
            String theName = s.getDescribe().getName();
            if (channelContactFields.contains(theName)) {
                theQuery += theName + ',';       
            }
        }       
        theQuery += ' BPL__c, PrimaryTerritory__c, PrimaryRegion__c, PrimaryRegionName__c, PrimaryTerritoryName__c ';    
        // Finalize query string       
        theQuery += ' FROM Contact where id IN :ContactIds'; 
        
        system.debug('ContactMap Query: ' + theQuery);
        
		// Use the query string to get the contact map
        Map <Id, Contact> ccfm = new Map<Id, Contact>(
            (List<Contact>)Database.query(theQuery)
        );

        return ccfm;

    }

    public static String ContactChannelFieldQuery() {
        
        Set<String> channelContactFields = ChannelFieldSet();
        system.debug('ccf' + channelContactFields);
        
        //Get all Contact fields from schema
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Contact.fields.getMap();        
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        //Build the query using fields from contact if they exist in the set of fields from channel
        String theQuery = 'SELECT Id, ';        
        for(Schema.SObjectField s : fldObjMapValues)        {           
            String theName = s.getDescribe().getName();
            if (channelContactFields.contains(theName)) {
                theQuery += 'contact__r.' + theName + ',';       
            }
        }       
       
        system.debug('ContactMap Query: ' + theQuery);
        
        return theQuery;

    }

    public static Set<String> ChannelFieldSet() {
        
        //Get all the fieldnames in any of the contact channel fields
        Set<String> channelContactFields = new Set<String>();
        List<Channel__c> channels = new List<Channel__c>([SELECT Id, FocusFirmField__c, RotationField__c, TierField__c, ZoneField__c
                                                          FROM Channel__c]);
        
        for (Channel__c c : channels) {
            if (c.FocusFirmField__c != null) {
                channelContactFields.add(c.FocusFirmField__c);   
            }
            if (c.RotationField__c != null) {
                channelContactFields.add(c.RotationField__c);   
            }
            if (c.TierField__c != null) {
                channelContactFields.add(c.TierField__c);   
            }
            if (c.ZoneField__c != null) {
                channelContactFields.add(c.ZoneField__c);   
            }
        }
        
        return channelContactFields;
        
    }
    
}