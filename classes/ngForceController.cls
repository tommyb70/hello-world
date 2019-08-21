global with sharing class ngForceController {

    /*
    * Modified Version of RemoteTKController
    */

    global class picklistValues
    {
        String label {get; set;}
        String value {get; set;}
    }

    global class QueryString 
    {
        String selectClause {get; set;}
        String fromClause {get; set;}
    }

    private static String makeError(String message, String errorCode) 
    {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    
    private static String writeFields(String objtype, SObject obj, String fields) 
    {
        Map<String, Object> fieldMap = null;
        try 
        {
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
            if(Test.isRunningTest())
                makeError('Test Message', 'TEST_ERROR');
        } 
        catch (Exception je) 
        {
            return makeError(je.getMessage(), 'JSON_PARSER_ERROR');
        }
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        
        try {
            for (String key : fieldMap.keySet()) 
            {
                if (targetFields.get(key) == null) 
                {
                    system.debug('[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]');
                    return '[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]';
                }
                
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                
                if (value instanceof String && valueType != Schema.DisplayType.String) 
                {
                    // Coerce an incoming String to the correct type
                    String svalue = (String)value;
                    
                    if (valueType == Schema.DisplayType.Date) 
                    {
                        system.debug('doing ' + key + ' : ' + svalue);
                        obj.put(key, Date.valueOf(svalue));
                    }else if(valueType == Schema.DisplayType.DateTime) 
                    {
                        if(svalue.length()>0)
                        obj.put(key,DateTime.valueOf(svalue));
                        else obj.put(key,null);
                    }else if (valueType == Schema.DisplayType.Percent ||
                           valueType == Schema.DisplayType.Currency) 
                           {
                        obj.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Double) 
                    {
                        obj.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Integer) 
                    {
                        obj.put(key, Integer.valueOf(svalue));
                    } else {
                        obj.put(key, svalue);
                    }
                } else {
                    // Just try putting the incoming value on the object
                    obj.put(key, value);
                }
            }
        } 
        catch (SObjectException soe) 
        {
            system.debug(soe.getMessage() + 'INVALID_FIELD');
            return makeError(soe.getMessage(), 'INVALID_FIELD');
        }
        
        return null;
    }

    @remoteAction
    global static String describe(String objtype) 
    {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType;
        try
        {
            targetType = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
            
            List<Object> fields = new List<Object>();
            for (String key : fieldMap.keySet()) 
            {
                Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                Map<String, Object> field = new Map<String, Object>();
                
                field.put('type', descField.getType().name().toLowerCase());
                field.put('name', descField.getName());
                field.put('label', descField.getLabel());
                List<String> references = new List<String>();
                for (Schema.sObjectType t: descField.getReferenceTo()) 
                {
                    references.add(t.getDescribe().getName());
                }
                if (!references.isEmpty()) 
                {
                    field.put('referenceTo', references);
                }
                
                fields.add(field);
            }
            
            Map<String, Object> result = new Map<String, Object>();
            result.put('fields', fields);
            
            return JSON.serialize(result);
        }
        catch(Exception e)
        {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
    }

    @remoteAction
    global static String describeField(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Schema.DescribeFieldResult fieldDescribe=dr.fields.getMap().get(fieldName).getDescribe();
            return JSON.serialize(fieldDescribe);
        }
        catch(Exception e)
        {
            return '[{"message":"Inavalid input","errorCode":"INVALID_INPUT"}]';
        }
    }
    
    @remoteAction
    global static String getPicklistValues(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
            List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();
            List<pickListValues> options = new List<picklistValues>();
            for(Schema.PicklistEntry plv : pickListValues){
                pickListValues pv = new pickListValues();
                pv.label = plv.getLabel();
                pv.value = plv.getValue();
                options.add(pv);
            }
            return JSON.serialize(options);
        }
        catch(Exception e)
        {
            return '[{"message":"Inavalid input","errorCode":"INVALID_INPUT"}]';
        }
    }

    @remoteAction
    global static Set<String> getPicklistValuesWithFieldName(String objtype, String fieldName) {
        try
        {
            Schema.SObjectType token = Schema.getGlobalDescribe().get(objtype);
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
            List<Schema.PicklistEntry> pickListValues = field_map.get(fieldName).getDescribe().getPickListValues();

            Set<String> setPicklistValues = new Set<String>();
            
            for(Schema.PicklistEntry plv : pickListValues){

                setPicklistValues.add(plv.getValue());
            }

            return setPicklistValues;
        }
        catch(Exception e)
        {
            return null;
        } 
    }

    @remoteAction
    global static String getObjType(String Id) {
        try
        {
            Id objId = (id) Id;
            Schema.SObjectType token = objId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String objName = dr.getName();
            Map<String,String> retObj = new Map<String,String>();
            retObj.put('type', objName);
            return JSON.serialize(retObj);
        }
        catch(Exception e)
        {
            return '[{"message":"Operation failed","errorCode":"INVALID_ID"}]';
        }
    }

    @remoteAction
    global static String create(String objtype, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        SObject obj = targetType.newSObject();
        
        Map<String, Object> fieldMap = null;
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }
        
        try {
            insert obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('id', obj.id);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }

    @remoteAction
    global static String bulkUpdate(String objtype, String jsonObjArr) {

        Type listType = Type.forName('List<' + objType + '>');
        if (listType == null) {
            return makeError('The requested resource does not exist in bulkCreate', 'NOT_FOUND');
        }
    
        List<SObject> objs;
        try {
            objs = (List<SObject>)JSON.deserialize(jsonObjArr, listType);
        } catch (JSONException je) {
            return makeError('Unable to deserialize the JSON data array', 'INVALID_JSON');
        }

        try {
            update objs;
        } catch (DMLException dmle) {
            return '[{"data":' + jsonObjArr + 
                    ',"message":"'+dmle.getDmlMessage(0)+
                    '","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
 
        List<Id> rids = new List<Id>();
        for(sObject o : objs) {
            rids.add(o.Id);
        }
 
        Map<String, Object> result = new Map<String, Object>();
        result.put('id', objs);
        result.put('errors', new List<String>());
        result.put('success', true);
         
        return JSON.serialize(result);
    }

    @remoteAction
    global static String retrieve(String objtype, String id, String fieldlist) {
        // TODO - handle null fieldlist - retrieve all fields
        Boolean containsId = false;
        for (String field : fieldlist.split(',')) {
            if (field.equalsIgnoreCase('id')){
                containsId = true;
                break;
            }
        }
        
        if (!containsId) {
            fieldlist = 'Id,'+fieldlist;
        }
        
        String soql = 'SELECT '+fieldlist+' FROM '+objtype+' WHERE Id = \''+id+'\'';
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
        }
        
        return JSON.serialize(records[0]);
    }
    
    @remoteAction
    global static String upser(String objtype, String externalIdField, String externalId, String fields) {
        Map<String, Object> result = new Map<String, Object>();
        try
        {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
            
            SObject obj = targetType.newSObject();
            obj.put(externalIdField, externalId);
            
            Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
            for (String key : fieldMap.keySet()) {
                obj.put(key, fieldMap.get(key));
            }
            
            Schema.SObjectField sobjField = targetType.getDescribe().fields.getMap().get(externalIdField);
            
            Database.Upsert(obj, sobjField);

            result.put('success', 'true');
            result.put('Id', obj.Id);
            
            return JSON.serialize(result);
        }
        catch(Exception e)
        {
            return '[{"message":"DML Failed","errorCode":"DML_EXCEPTION"}]';
        }
    }

    @remoteAction
    global static String updat(String objtype, String id, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist in update","errorCode":"NOT_FOUND"}]';
        }
        
        SObject obj = targetType.newSObject(id);
        
        Map<String, Object> fieldMap = null;
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }
        
        try {
            update obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            system.debug('[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]');
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        //return null;

        Map<String, Object> result = new Map<String, Object>();
        result.put('record',obj);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }

    @remoteAction
    global static String del(String objtype, String id) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
        
        SObject obj = targetType.newSObject();
        obj.put('Id', id);
        
        try {
            delete obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    global static String query(String soql) {
        
        DateTime dt = Datetime.now();
        Date dtTask = Date.today();

        List<sObject> records; 
        try {
            records = Database.query(soql);    
        } catch (QueryException qe) {
            return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        
        return JSON.serialize(result);
    }

    @remoteAction
    global static String search(String sosl) {
        List<List<SObject>> result;        
        try {
            result = Search.query(sosl);
        } catch (Exception se) {
            return '[{"message":"'+se.getMessage()+'","errorCode":"INVALID_SEARCH"}]';
        }
        
        return JSON.serialize(result);
    }
}