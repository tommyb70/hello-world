public with sharing class CA_SimpleAgenda {
    private static Map<String, String> aParams;
    private static CA_SimpleAgendaDescribedCore oCore = new CA_SimpleAgendaDescribedCore();

    public static boolean is_ic_inbound() { 
        String UserID =  Userinfo.getUserId();
        Boolean IC = false;
        IC = UserHelperClass.IsIC_Inbound(UserID );
        return IC ;
    }

    @AuraEnabled
    public static String  CA_Remote(String sIncomeParams) {
        system.debug('=== aParams' + sIncomeParams);
        CA_SimpleAgenda.aParams = (Map<String, String>) JSON.deserialize(sIncomeParams, Map<String, String>.class);

        Map<String, String> aResult = new Map<String, String>();
        system.debug(CA_SimpleAgenda.aParams);
        String sAction = CA_SimpleAgenda.aParams.containsKey('event') ? CA_SimpleAgenda.aParams.get('event') : '';
        try {
            if (sAction == 'getData') {
                aResult = CA_SimpleAgenda.getDataAction(null);
                system.debug(LoggingLevel.ERROR,'getData results: '+aResult);
            } else if (sAction == 'getStructure') {
                aResult = CA_SimpleAgenda.getStructureAction();
                system.debug(LoggingLevel.ERROR,'getStructure results: '+aResult);
            } else if (sAction == 'getElement') {
                aResult = CA_SimpleAgenda.getElementAction();
                system.debug(LoggingLevel.ERROR,'getElement results: '+aResult);
            } else if (sAction == 'saveElement') {
                aResult = CA_SimpleAgenda.saveElementAction();
                system.debug(LoggingLevel.ERROR,'saveElement results: '+aResult);
            } else if (sAction == 'rest') {
                aResult = CA_SimpleAgenda.getREST();
                system.debug(LoggingLevel.ERROR,'rest results: '+aResult);
            } else if (sAction == 'getReferenceOptions') {
                aResult = CA_SimpleAgenda.getReferenceAction();
                system.debug(LoggingLevel.ERROR,'getReferenceOptions results: '+aResult);
            }
        } catch (QueryException e) {
            aResult.put('status', 'error');
            aResult.put('error', e.getMessage());
            system.debug('=== DB exception ' + aResult);
        } catch (DMLException e) {
            aResult.put('status', 'error');
            aResult.put('error', 'Database Error: ' + e.getDmlMessage(0));
            List<String> aErrFields = e.getDmlFieldNames(0);
            aResult.put('fields', String.join(aErrFields, ','));
            system.debug('=== DB exception ' + e.getDmlFields(0));
        } catch (System.Exception e) {
            aResult.put('status', 'error');
            aResult.put('error', e.getMessage());
            system.debug('=== exception ' + aResult);
        }

        return JSON.serialize(aResult);

    }

    private static Map<String, String> getDataAction(Map<String, String> aAddParams) {
        CA_EventLoader aLoader = new CA_EventLoader(CA_SimpleAgenda.aParams);

        Map<String, String> aResult = new Map<String, String>{
            'status' => 'ok',
            'events' => JSON.serialize(aLoader.getResult())
        };      

        return aResult;
    }
    
    private static Map<String, String> getReferenceAction() {
        CA_EventLoader aLoader = new CA_EventLoader(CA_SimpleAgenda.aParams);
        Map<String, String> aResult = new Map<String, String>{
            'status' => 'ok',
            'events' => JSON.serialize(aLoader.getResult())
        };      

        return aResult;
        
    }
    
    private static Map<String, String> getElementAction() {
        CA_EventLoader aLoader = new CA_EventLoader(CA_SimpleAgenda.aParams, CA_SimpleAgenda.aParams.get('recordId'));
        List<Map<String, String>> aEls = aLoader.getResult();
        Map<String, String> aResult = new Map<String, String>{
            'status' => 'ok'};
        if(aEls.size() > 0) aResult.put('data',JSON.serialize(aEls[0]));
        else aResult.put('data','{}');

        return aResult;
    }
    
    private static Map<String, String> saveElementAction(){
        CA_EventSaver aSaver = new CA_EventSaver(
            CA_SimpleAgenda.aParams.get('object'), 
            CA_SimpleAgenda.aParams.get('recordId')
        );

        Map<String, String> aSaveResult = aSaver.save((Map<String, String>) JSON.deserialize(CA_SimpleAgenda.aParams.get('data'), Map<String, String>.class));
        Map<String, String> aResult = new Map<String, String>{
            'status' => 'ok',
            'data' => JSON.serialize(aSaveResult)
        };   
        return aResult;
    }


    private static Map<String, String> getStructureAction() {
        String sObjectName = CA_SimpleAgenda.aParams.get('object'),
            sFieldSet = CA_SimpleAgenda.aParams.get('fieldset'),
            sAdditionalFields = CA_SimpleAgenda.aParams.get('fields');
        
        CA_FieldLoader aFieldsLoader = new CA_FieldLoader(sObjectName, sAdditionalFields, sFieldSet);
        Map<String, String> aResult = new Map<String, String>{
            'name' => sObjectName,
            'label' => CA_SimpleAgenda.oCore.getObjectLabelByName(sObjectName),
            'fields' => JSON.serialize(aFieldsLoader.getObjectFields()),
            'fieldSet' => aFieldsLoader.getFieldSetStringFields(),
            'fieldSets' => JSON.serialize(aFieldsLoader.getFieldSets()),
            'sessionId' => userInfo.getSessionId(),
            'listViews' => JSON.serialize(aFieldsLoader.getListViews())
        };

        return aResult;
    }
    
    private static Map<String, String> getREST(){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        req.setEndpoint(CA_SimpleAgenda.aParams.get('url'));
        req.setMethod('POST');
        req.setBody(CA_SimpleAgenda.aParams.get('data'));
        req.setCompressed(true); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'OAuth ' + userInfo.getSessionId());
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            return new Map<String, String>{'error' => res.toString(), 'exception' => e.getMessage()};
        }
        return new Map<String, String>{'data' => res.getBody()};
        //return new Map<String, String>{'data' => 'ok'};
    }


    private class CA_EventLoader{
        private String sFields,
            sStartField,
            sEndField,
            sTitleField,
            sSort,
            sFilter,
            sObj,
            listView,
            sListView,
            sReayQuery,
            sElementId,
            sHM,
            sOffset;
        private Set<String> aQueryFields;
        private Map<String, String> aSOQLTypes, aSOQLFields;
        private Boolean bOneMode = false;
        List<Map<String, String>> aJSONData = new List<Map<String, String>>();
        DateTime dStart, dEnd;

        public CA_EventLoader(Map<String, String> aInitParams){
            this.sStartField = aInitParams.get('startField');
            this.sEndField = aInitParams.get('endField');
            this.sTitleField = aInitParams.get('title');
            this.sObj = aInitParams.get('object');
            this.sFilter = aInitParams.get('filter');
            this.sFields = aInitParams.get('fields');
            this.sHM = aInitParams.get('hm');
            this.sOffset = aInitParams.get('offset');
            this.prepareFields();
            if (this.sStartField != null) {
                this.dStart = this.parseDate(aInitParams.get('start'));
                this.dEnd = this.parseDate(aInitParams.get('end'));
            }
            
            this.sListView = this.getListViewId(aInitParams.get('listView'));
//sFilter += (sFilter == '' ? '' : ' AND ') + this.prepareDateCriteria();
            this.makeQueryText();
            this.runQuery();
        }
        
        public CA_EventLoader(Map<String, String> aInitParams, String sId){
            this.bOneMode = true;
            this.sElementId = sId;
            this.sObj = aInitParams.get('object');
            this.sFields = aInitParams.get('fields');
            this.prepareFields();
            this.makeQueryText();
            this.runQuery();
        }

        private void prepareFields(){
            this.aQueryFields = this.sFields != null ? new Set<String>(this.sFields.split(',')) : new Set<String>();
            this.aQueryFields.add('id');
            if (!this.bOneMode) {
                if (this.sStartField != null) {
                    this.aQueryFields.add(this.sStartField);
                    this.aQueryFields.add(this.sEndField);
                }
                this.aQueryFields.add(this.sTitleField);
            }
            if (this.sObj == 'event') {
                this.aQueryFields.add('allday');
            }
            this.aSOQLTypes = CA_SimpleAgenda.oCore.getFieldsTypesInSOQL(this.sObj, this.aQueryFields); 
            this.aSOQLFields = CA_SimpleAgenda.oCore.getFieldsInSOQL(this.sObj, this.aQueryFields, false);

        }

        private DateTime parseDate(String sDate){
            DateTime dDT = Datetime.valueOfGmt(sDate.replace('T', ' '));
//          Date dResult = dDT.date();
            return dDT;
        }

        private String prepareDateCriteria(){
            String sStartType = this.aSOQLTypes.get(this.sStartField),
                sEndType = this.aSOQLTypes.get(this.sEndField),
                sSOQL = '(';
            if (sStartType == 'DATE') {
                sSOQL += this.aSOQLFields.get(this.sStartField) + ' <= \'' + this.dEnd.format() + '\'';
            } else {
                sSOQL += this.aSOQLFields.get(this.sStartField) + ' <= ' + this.dEnd.formatGMT('yyyy-MM-dd') 
                    + 'T' +  this.dEnd.formatGMT('HH:mm:ss') + 'Z' ;
            }
            if (sEndType == 'DATE') {
                sSOQL += ' AND ' + this.aSOQLFields.get(this.sEndField) + ' >= \'' + this.dStart.format() + '\'';
            } else {
                sSOQL += ' AND ' + this.aSOQLFields.get(this.sEndField) + ' >= ' + this.dStart.formatGMT('yyyy-MM-dd')
                    + 'T' +  this.dStart.formatGMT('HH:mm:ss') + 'Z';
            }
            sSOQL += ')';
            return sSOQL;
        }

        private void makeQueryText(){
            system.debug('=== this.aSOQLFields' + this.aSOQLFields.values());
            this.sReayQuery =  CA_SimpleAgenda.oCore.buildQuery(
                    this.sObj, 
                    String.join(this.aSOQLFields.values(), ','),
                    'ID != NULL '
                        + (this.sFilter != null && this.sFilter != '' ? ' AND ' + this.sFilter : '')
                        + (this.bOneMode || this.sStartField == null ? '' : ' AND ' + this.prepareDateCriteria()), 
                    ''
                ) 
                + (this.bOneMode 
                   ? ' AND id=\'' + this.sElementId + '\'' 
                   : ' ORDER BY ' 
                        + aSOQLFields.get(this.sStartField != null ? this.sStartField : this.sTitleField) 
                        + ' ASC '
                   )
                + ' LIMIT ' + (this.bOneMode 
                        ? '1' 
                        : (this.sHM != null ? this.sHM : '2000')
                   )
                + (this.sOffset != null ? ' OFFSET ' + this.sOffset : '');

        }

        private void runQuery(){
            system.debug('=== ' + this.sReayQuery);
            sObject[] aData;
            if (this.sListView != null) {
                ApexPages.StandardSetController oLVController = new ApexPages.StandardSetController(Database.getQueryLocator(this.sReayQuery));
                oLVController.setPageSize(999);
                oLVController.setFilterId(this.sListView);
                aData = (List<sObject>) oLVController.getRecords();
            } else {
                aData = Database.query(this.sReayQuery);
            }
            String sFieldValue;
            for (sObject aRow : aData) {
                Map<String, String> aRowData = new Map<String, String>{
                    'id' => (String) aRow.id
                };
                if (!this.bOneMode) {
                    aRowData.put('title', this.getFieldValue(aRow, this.aSOQLFields.get(this.sTitleField), this.aSOQLTypes.get(this.sTitleField), false));
                    if (this.sStartField != null) {
                        aRowData.put('start', this.getFieldValue(aRow, this.aSOQLFields.get(this.sStartField), this.aSOQLTypes.get(this.sStartField), false));
                        aRowData.put('end', this.getFieldValue(aRow, this.aSOQLFields.get(this.sEndField), this.aSOQLTypes.get(this.sEndField), false));
                    }
                }

                for (String sFld   : this.aSOQLFields.keySet()) {
                    sFieldValue = this.getFieldValue(aRow, this.aSOQLFields.get(sFld), this.aSOQLTypes.get(sFld), true);
                    if (sFieldValue == '' || sFieldValue == null || sFieldValue == 'null') {
                        continue;
                    }
                    aRowData.put(sFld, sFieldValue);
                }
                this.aJSONData.add(aRowData);
            }
        }

        public List<Map<String, String>> getResult(){
            return this.aJSONData;
        }

        private String getFieldValue(sObject aEl, String sSOQLField, String sType, Boolean bNativeFormat) {
            sObject aSource = aEl;
            String sFld = sSOQLField, sResult;
            if (sSOQLField == null) {
                return null;
            }
            if (sSOQLField.contains('.')) {
                String[] aTmp = sSOQLField.split('\\.');
                aSource = aEl.getSObject(aTmp[0]);
                sFld = aTmp[1];
            }
            if (aSource == null || aSource.get(sFld) == null) {
                return null;
            }
            else if (sType == 'DATE' ) {
                Date dTemp = (Date)aSource.get(sFld);
                Datetime dDT = Datetime.newInstance(dTemp.year(), dTemp.month(), dTemp.day());
    //system.debug('==' + dDT.format('yyyy-MM-dd'));
                //sResult = dTemp.year() + '-' + dTemp.month() + '-' + dTemp.day();
                sResult = dDT.format('yyyy-MM-dd');
                
                /*if (bNativeFormat) {
                    sResult = dTemp.format();
                } else {
                    sResult = dTemp.year() + '-' + dTemp.month() + '-' + dTemp.day();
                }*/
            } else if (sType == 'DATETIME' ) {
/*                if (bNativeFormat) {
                    sResult = ((Datetime)aSource.get(sFld)).format();
                } else {
                    sResult = ((Datetime)aSource.get(sFld)).format('yyyy-MM-dd HH:mm:ss');
                }*/
                sResult = ((Datetime)aSource.get(sFld)).format('yyyy-MM-dd HH:mm:ss');
            } else if (sType == 'BOOLEAN') {
                sResult = (Boolean)aSource.get(sFld) ? 'true' : 'false';
            } else if (sType == 'DECIMAL') {
                sResult = ((Decimal)aSource.get(sFld)).toPlainString();
            } else if (sType == 'DOUBLE') {
                sResult = String.valueOf((Double)aSource.get(sFld));
            } else if (sType == 'CURRENCY') {
                String sCurrency = (( (Decimal)aSource.get(sFld)).setScale(2)).format();
                sResult = (( (Decimal)aSource.get(sFld)) ).format();
            } else {
                sResult = String.valueOf(aSource.get(sFld));
            }
            return sResult;
        }

        private String getListViewId(String sLV){
            if (sLV == '' || sLV == null) {
                return null;
            }
            List<Map <String, String>> aResult = new List<Map <String, String>>();
            List<sObject> aList = Database.query('SELECT id FROM ' + this.sObj + ' LIMIT 1');
            system.debug('=== ' + aList);
            ApexPages.StandardSetController aCtrl;
            aCtrl = new ApexPages.StandardSetController(aList);
            List<SelectOption> aOptions = aCtrl.getListViewOptions();
            for (SelectOption aEl : aOptions) {
                if (sLV == aEl.getLabel()) {
                    return aEl.getValue(); 
                }
            }
            return null;
        }

    }

    private class CA_FieldLoader{
        private String  sObj,
                        sAdditionalFields,
                        sFieldSet;
                        
        private Set<String> aAddFields = new Set<String>();
        
        private  Map<String, Map<String, String>> aReplaceLabels = new Map<String, Map<String, String>>{
            '*' => new Map<String, String>{
                'createdbyid' => 'Created By',
                'lastmodifiedbyid' => 'Last Modified By'
            },
            'event' => new Map<String, String>{
                'ownerid' => 'Assigned To',
                'whoid' => 'Name',
                'activitydate' => 'Due Date'
            },
            'task' => new Map<String, String>{
                'ownerid' => 'Assigned To',
                'whoid' => 'Name',
                'activitydate' => 'Due Date'
            }
        };
        



        public CA_FieldLoader(String sObjectName, String sAddFields, String sFieldSetList) {
            this.sObj = sObjectName;
            this.sAdditionalFields = sAddFields;
            this.sFieldSet = sFieldSetList;

            if (sFieldSetList != null && sFieldSetList != '') {
                this.aAddFields.addAll(this.getFieldSetFields());
            } else if (sAddFields != '' && sAddFields != null) {
                this.aAddFields.addAll(sAddFields.split(','));
            }


            


        }

        private Set<String> getFieldSetFields(){
            Set<String> aResult = new Set<String>();
            Schema.SObjectType oDescr = CA_SimpleAgenda.oCore.getObjectDescription(this.sObj);
            if (oDescr == null ) {
                return aResult;
            }
            Map<String, Schema.FieldSet> aFieldSetMap = oDescr.getDescribe().FieldSets.getMap();
            system.debug('== aFieldSetMap ' + aFieldSetMap);
            List<Schema.FieldSetMember> aFielsSetMembers = aFieldSetMap.containsKey(this.sFieldSet) 
                ? aFieldSetMap.get(this.sFieldSet).getFields()
                : null ;
            if (aFielsSetMembers == null) {
                return aResult;
            }
            for (Schema.FieldSetMember oFieldMember : aFielsSetMembers){
                aResult.add(oFieldMember.getFieldPath().toLowerCase());
            }
            return aResult;
        }

        public Map<String, Map<String, String>> getObjectFields() {

            Map<String, Map<String, String>> aResult = new Map<String, Map<String, String>>();
            String sAPIObjectName = this.sObj.toLowerCase();
            Map<String, Schema.DescribeFieldResult> aFields =CA_SimpleAgenda.oCore.getFieldsDescribesByObjectName(sAPIObjectName);
            Map<String, Set<String>> aAddLinkedFields = (this.aAddFields.size() > 0) 
                ? this.splitAddFields() 
                : new Map<String, Set<String>>();
            

            for (String sKey : aFields.keySet()) {
                Schema.DescribeFieldResult aField = aFields.get(sKey);
                String sAPIName = sKey.toLowerCase(),
                    sFieldType = aField.getType().name().toUpperCase(),
                    sDefault = (aField.getDefaultValueFormula() != null && sFieldType != 'DATE' && sFieldType != 'DATETIME' 
                        ? (String) aField.getDefaultValueFormula() 
                        : ''); 
                if (sDefault != '') {
                    if (sFieldType == 'CURRENCY' || sFieldType == 'NUMBER' || sFieldType == 'INTEGER') {
                        if (!this.isStringAnyNumeric(sDefault)) {
                            sDefault = '';
                        }
                    } else if (sFieldType == 'STRING' || sFieldType == 'TEXTAREA' || sFieldType == 'EMAIL' || sFieldType == 'PHONE') {
                        sDefault = sDefault.substring(1, sDefault.length() - 1);
                    }
                }
                
                Map<String, String> aFieldProp = new Map<String, String>{
                    'label' => this.getFieldLabel(sAPIObjectName, sAPIName, aField.getLabel()),
                    'name' => sAPIName,
                    'type' => sFieldType,
                    'htmlFormatted' => aField.isHtmlFormatted() ? 'true' : 'false',
                    'isAccessible' => aField.isAccessible() ? 'true' : 'false',
                    'isUpdateable' => aField.isUpdateable() ? 'true' : 'false',
                    'isCreateable' => aField.isCreateable() ? 'true' : 'false',
                    'isHTML'       => aField.isHtmlFormatted() ? 'true' : 'false',
                    'isRequired' => ((!aField.isDefaultedOnCreate() && !aField.isNillable())  || sAPIName == 'name') ? 'true' : 'false',
                    'isDependent'  => ((sFieldType == 'PICKLIST' || sFieldType == 'MULTIPICKLIST') 
                        && aField.isDependentPicklist() ? 'true' : 'false'),
                    'default' => sDefault,
                    'options' => (sFieldType == 'PICKLIST' || sFieldType == 'MULTIPICKLIST' || sFieldType == 'COMBOBOX' 
                                  ? this.getPicklistOptions(aField) 
                                  : (sFieldType == 'REFERENCE' ? this.getReferenceOptions(aField) : '[]')
                                 )
                };
                aResult.put(sAPIName, aFieldProp);
                String sReferenceAPIName = aField.getRelationshipName();
                if (aAddLinkedFields.containsKey(sAPIName) || (sReferenceAPIName != null && aAddLinkedFields.containsKey(sReferenceAPIName.toLowerCase()))) {
                    String sFilterSetAPIName = aAddLinkedFields.containsKey(sAPIName) ? sAPIName : sReferenceAPIName.toLowerCase();
                    aResult.putAll(this.getReferenceFields(sAPIName, sFilterSetAPIName, aField, aAddLinkedFields.get(sFilterSetAPIName)));
                }
                
                
            }
            return aResult;
        }
        
        private  Boolean isStringAnyNumeric(String sValue) {
            return sValue != null && sValue.replaceAll('[.,]', '').isNumeric();
        }
        
        private String getPicklistOptions(Schema.DescribeFieldResult aField) {
            List<Map<String, String>> aOptions = new List <Map <String, String>>();
            List<Schema.PicklistEntry> aValues = aField.getPicklistValues();
            if (aValues != null){
                for ( Schema.PicklistEntry oValue : aValues ) {
                    if (oValue.isActive()) {
                        aOptions.add(new Map<String, String>{
                            'value' => oValue.getValue(), 
                            'label' => oValue.getLabel(),
                            'default' => oValue.isDefaultValue() ? 'true' : 'false'
                        });
                    }
                }
            }
            return JSON.serialize(aOptions);
        }
        
        private String getReferenceOptions(Schema.DescribeFieldResult aField) {
            List<Map<String, String>> aOptions = new List <Map <String, String>>();
            Schema.DescribeSObjectResult oDescribe;
            List<Schema.sObjectType> aValues = aField.getReferenceTo();
            if (aValues != null){
                for ( Schema.sObjectType oValue : aValues ) {
                    oDescribe = oValue.getDescribe();
                    aOptions.add(new Map<String, String>{
                        'value' => oDescribe.getName(), 
                        'local' => oDescribe.getLocalName(), 
                        'prefix' => oDescribe.getKeyPrefix(),    
                        'label' => oDescribe.getLabel(),
                        'isAccessible' => oDescribe.isAccessible() && oDescribe.isQueryable() ? 'true' : 'false'
                    });
                }
            }
            return JSON.serialize(aOptions);
        }

        private Map<String, Map<String, String>> getReferenceFields(
            String sFieldname, 
            String sFieldSetFieldName, 
            Schema.DescribeFieldResult oField, 
            Set<String> aLinked
        ) {
            Map<String, Map<String, String>> aResult = new Map<String, Map<String, String>>();
            List <Schema.sObjectType> aRef = oField.getReferenceTo();
            if (aRef == null || aRef.size() < 1) {
                return null;
            }
            String sReferenceObject = aRef.get(0).getDescribe().getName().toLowerCase(),
                sSourceObject = this.sObj.toLowerCase();

            Map<String, Schema.DescribeFieldResult> aFields =CA_SimpleAgenda.oCore.getFieldsDescribesByObjectName(sReferenceObject);
            system.debug('=== aLinked ' + aLinked);
            for (String sKey : aFields.keySet()) {
                String sKeyFieldName = sKey.toLowerCase(),
                    sAPIName = sFieldname + '.' + sKeyFieldName;
                if (!aLinked.contains(sKeyFieldName)) {
                    continue;
                }
                if (sFieldname != sFieldSetFieldName && this.aAddFields.contains(sFieldSetFieldName + '.' + sKeyFieldName)) {
                    this.aAddFields.remove(sFieldSetFieldName + '.' + sKeyFieldName);
                    this.aAddFields.add(sAPIName);
                }

                Schema.DescribeFieldResult aField = aFields.get(sKey);
                

                Map<String, String> aFieldProp = new Map<String, String>{
                    'label' => this.getFieldLabel(sSourceObject, sFieldname, oField.getLabel())
                            + ' / ' + this.getFieldLabel(sReferenceObject, sAPIName, aField.getLabel()),
                        //oField.getLabel() + ' / ' + aField.getLabel(),
                    'name' => sAPIName,
                    'type' => aField.getType().name().toUpperCase(),
                    'htmlFormatted' => aField.isHtmlFormatted() ? 'true' : 'false'
                };
                aResult.put(sAPIName, aFieldProp);
            }
            return aResult;
        }

        private Map<String, Set<String>> splitAddFields(){
            Map<String, Set<String>> aResult = new Map<String, Set<String>>();
            for (String sFieldName : this.aAddFields) {
                String[] aFieldName = sFieldName.split('\\.');
                if (aFieldName.size() < 2) {
                    continue;
                }
                if (!aResult.containsKey(aFieldName[0])) {
                    aResult.put(aFieldName[0].toLowerCase(), new Set<String>());
                }
                aResult.get(aFieldName[0].toLowerCase()).add(aFieldName[1].toLowerCase());
            }
            return aResult;
        }

        public String getFieldSetStringFields(){
            return  (this.sFieldSet != null && this.sFieldSet != '')  ? String.join(new List<String>(this.aAddFields), ',') : '';
        }
        
        public Map<String, Map<String, String>> getFieldSets(){
            Map<String, Map<String, String>> aResult = new Map<String, Map<String, String>>();
            Schema.SObjectType oDescr = CA_SimpleAgenda.oCore.getObjectDescription(this.sObj);
            if (oDescr == null ) {
                return aResult;
            }
            Map<String, Schema.FieldSet> aFieldSetMap = oDescr.getDescribe().FieldSets.getMap();
            for (String sFieldSet : aFieldSetMap.keySet()) {
                aResult.put(sFieldSet, new Map<String, String>{
                    'label' => aFieldSetMap.get(sFieldSet).getLabel(),
                    'name' => aFieldSetMap.get(sFieldSet).getName()
                });
            }
            return aResult;
        }
        
        public  Map<String, Map<String, String>> getListViews(){
            Map<String, Map<String, String>> aResult = new Map<String, Map<String, String>>();
            Schema.SObjectType oDescr = CA_SimpleAgenda.oCore.getObjectDescription(this.sObj);
            if (oDescr == null ) {
                return aResult;
            }
            
            //List<sObject> aList = Database.query('SELECT id FROM ' + this.sObj + ' LIMIT 1');
            //ApexPages.StandardSetController aCtrl ;//= new ApexPages.StandardSetController();
            /*ApexPages.StandardSetController aCtrl = new ApexPages.StandardSetController(aList);
            List<SelectOption> aOptions = aCtrl.getListViewOptions();
            for (SelectOption aEl : aOptions) {
                aResult.put(aEl.getValue(), new Map<String, String>{
                    'label' => aEl.getLabel(),
                    'id' => aEl.getValue(),
                    'name' => aEl.getValue()
                });
            }*/
            return aResult;

        }
        
        private String getFieldLabel(String sObj, String sAPI, String sLabel){
            if (this.aReplaceLabels.get('*').containsKey(sAPI)) {
                return this.aReplaceLabels.get('*').get(sAPI);
            } else if (this.aReplaceLabels.containsKey(sObj)
                  && this.aReplaceLabels.get(sObj).containsKey(sAPI)
            ) {
                return this.aReplaceLabels.get(sObj).get(sAPI);
            } 
            return sLabel;
        }
        
    }
    
    private class CA_EventSaver{
        private sObject aEl;
        private String sObjName,
            sRecordId;
        private Map<String, String> aData;
        private Set<String> aFields;
            
        public CA_EventSaver(String sObjectName, String sId) {
            this.sObjName = sObjectName;
            this.sRecordId = sId;
            this.aFields = new Set<String>(CA_SimpleAgenda.oCore.getObjectAllQueryFields(this.sObjName, 'update'));
            if (this.sRecordId != null && this.sRecordId != '') {
                this.loadObject();
            } else {
                this.aEl = CA_SimpleAgenda.oCore.getRecordByTypeName(this.sObjName);
            }
        }
        
        public Map<String, String> save(Map<String, String> aElData){
            if (!CA_SimpleAgenda.oCore.checkCRUD('insert', this.sObjName)) {
                throw new QueryException('User has no access to ' + this.sObjName);
            }
            this.aData = aElData;
            for (String sField : this.aFields) {
                if (this.aData.containsKey(sField)) {
                    this.setFieldValue(sField, this.aData.get(sField));
                }
            }
            system.debug('***Sobject: '+aEl);
            if(aEl.get('ActivitySource__c') == null) aEl.put ('ActivitySource__c', 'Salesforce1');
             system.debug('***ActivitySource__c: '+aEl);
            if( is_ic_inbound()  == true)
            {
               aEl.put('type',aEl.get('ActivityType__c')); 
               aEl.put('Subject',aEl.get('ActivityType__c')); 
            }
            else
            {
                aEl.put('ActivityType__c',aEl.get('type')); 
                aEl.put('Subject',aEl.get('type')); 
            }
            database.upsert(this.aEl);
/*            try {
                
            } catch (System.DmlException e) {
                system.debug('== DB ' +  e.getMessage());
                throw new System.DmlException('Save Error: ' + e.getDmlMessage(0), e);
            }*/
            return new Map<String, String>{'id' => '' + this.aEl.id};
        }
        
        private void loadObject(){
            String sQuery = CA_SimpleAgenda.oCore.buildQuery(this.sObjName, String.join(new List<String>(this.aFields), ','), 'ID=\''  + this.sRecordId + '\'' , null);
            List<sObject> aList = (List<sObject>) database.query(sQuery);
            if (aList.size() > 0) {
                this.aEl = aList.get(0);
            } else {
                throw new QueryException('No such record');
            }
            
        }
        
        private void setFieldValue(String sField, String sValue) {
            if (sValue == '' || sValue == null) {
                return;
            }
            String fieldType = CA_SimpleAgenda.oCore.getFieldTypeByName(this.sObjName, sField);
            system.debug('== field set ' +  sField + ' / ' + fieldType + ' / ' + sValue);
            if (fieldType == 'DOUBLE' || fieldType == 'PERCENT') { 
                    this.aEl.put(sField, double.valueOf(sValue));
            } else if (fieldType == 'REFERENCE') {
                if (sValue != '000000000000000') {
                    this.aEl.put(sField, (ID)sValue);
                }
            }
            else if (fieldType == 'CURRENCY') {
                this.aEl.put(sField, Decimal.valueOf(sValue));
            }
            else if (fieldType == 'INTEGER') {
                this.aEl.put(sField, integer.valueOf(sValue));
            }
            else if (fieldType == 'DATE') {
                if (!(sValue == 'ActivityDate' && this.sObjName == 'Event') ) {
                    
                    DateTime dDT = Datetime.valueOfGmt(sValue.replace('T', ' '));
                    system.debug('== date ' + dDT + ' / ' + dDT.date());
                    this.aEl.put(sField, dDT.dateGMT());
                }
            }
            else if (fieldType == 'DATETIME') {
                if (!(sField == 'ActivityDate' && this.sObjName == 'Event') ) {
                    DateTime dDT = Datetime.valueOfGmt(sValue.replace('T', ' '));
                    this.aEl.put(sField, dDT);
                }
            }
            else if (fieldType == 'BOOLEAN') {
                this.aEl.put(sField, sValue == 'true' || sValue == 'on' ? true : false );
            }
            else if (fieldType == 'PICKLIST') {
                if (!(
                    (sField == 'ForecastCategory' && this.sObjName == 'Opportunity') ||
                    (sField == 'StatusCode' && this.sObjName == 'Contract')
                )) {
                    this.aEl.put(sField, sValue);
                }
            }
            else {
                if (!(sValue == 'Fiscal' && this.sObjName == 'Opportunity')) {
                    this.aEl.put(sField, sValue);
                }
            }
        }
            
        
    }

    
}