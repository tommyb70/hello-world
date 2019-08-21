public class CDRMorningstarAPIWSC {
    
    public class myRESTException extends Exception{}
    
    @future(callout=true)
    public static void callMorningstarCDR() {       
        
        CDRSettings__c CDRSettings = CDRSettings__c.getValues('NGAM');
        String MSCreateAccessCodeBody = CDRSettings.MorningstarCreateAccessCodeBody__c;
        String MSCreateAccessCodeURL = CDRSettings.MorningstarCreateAccessCodeURL__c;
        String MSUniverseCode = CDRSettings.MorningstarUniverseCode__c;
        String MSDailyRatingsAndRankingsURL = CDRSettings.MorningstarDailyRatingsAndRankingsURL__c;
        String MSXMLFile = CDRSettings.UseThisStaticResourceForMSXML__c;
        
        Boolean CallAPICenter = String.isBlank(MSXMLFile);
        
        if (CallAPICenter) {
            // Get Access Code
            HttpRequest ACreq = new HttpRequest();
            ACreq.setEndpoint(MSCreateAccessCodeURL);
            ACreq.setMethod('POST');
            ACreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            ACreq.setBody(MSCreateAccessCodeBody);
            Http ACh = new Http();
            HttpResponse responseAC = ACh.send(ACreq);
            String MSAccessCode = processAccessCodeResp(responseAC);
            system.debug('MSAccessCode: ' + MSAccessCode);
            
            if (MSAccessCode != null && MSAccessCode != '') {
                // Get Daily Ratings and Rankings from API Center
                MSDailyRatingsAndRankingsURL = MSDailyRatingsAndRankingsURL.replace('{universeId}',MSUniverseCode);
                MSDailyRatingsAndRankingsURL = MSDailyRatingsAndRankingsURL.replace('{accesscode}',MSAccessCode);
                system.debug('MSDailyRatingsAndRankingsURL: ' + MSDailyRatingsAndRankingsURL);
                
                HttpRequest DailyReq = new HttpRequest();
                DailyReq.setEndpoint(MSDailyRatingsAndRankingsURL);
                DailyReq.setMethod('GET');
                DailyReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                Http DailyReqH = new Http();
                HttpResponse DailyResp = DailyReqH.send(DailyReq);
                
                if (DailyResp.getStatusCode() != 200) {
                    processMSError(DailyResp, 'Ratings and Returns API Call');   
                } else {
                    String strXML = DailyResp.getBody();
                    processDailyXML(strXML);
                }
                
            } else {                
                processMSError(responseAC, 'Fetch of Access Code');
            }   
            
        } else {
            // Using Static Resource Daily Ratings and Rankings 
            system.debug('Using ' + MSXMLFile + ' instead of calling API Center');
            
            StaticResource staticRes = [SELECT Id, Body FROM StaticResource WHERE Name =: MSXMLFile];
            String strXML = staticRes.Body.toString();
            processDailyXML(strXML);
            
        }
        
    }
    
    
    public static void processMSError(HttpResponse rsp, String msg) {
        
        System.debug('The status code returned was not expected: ' + rsp.getStatusCode() + ' ' + rsp.getStatus());
        
        String plainTextBody = 'CDRMorningstarAPIWSC has failed with status code ' + rsp.getStatusCode() + ' during ' + msg + '.  Please attempt to rerun this job via the dev console today using the following command: CDRMorningstarAPIWSC.callMorningstarCDR();';
        
        NGAMSettings__c settings = NGAMSettings__c.getvalues('NGAM_ALL');
        String[] toAddresses = settings.FailureNotificationEmailAddress__c.split(';');
        
        // Send an email 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('CDRMorningstarAPIWSC has Failed');
        mail.setPlainTextBody(plainTextBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    public static string processAccessCodeResp(HttpResponse rsp) {
        
        String MSAccessCode;
        
        if (rsp.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         rsp.getStatusCode() + ' ' + rsp.getStatus());
        } else {
            List<String> XMLDataAC = new List<String>();
            String strXML = rsp.getBody();
            System.debug(strXML);
            Dom.Document doc = new Dom.Document();
            doc.load(strXml);
            Dom.XMLNode envelope = doc.getRootElement();       
            Dom.XMLNode data = envelope.getChildElements()[1]; 
            Dom.XMLNode apiname = data.getChildElements()[0];
            Dom.XMLNode accesscode = apiname.getChildElements()[0];
            MSAccessCode = accesscode.getText();
            System.debug('AccessCode: ' + accesscode.getText());
        }
        
        return MSAccessCode;
    }
    
    public static void processDailyXML(String strXML) {
        
        Map<String,Product2> MSProductMap = new Map<String,Product2>();
        List<Product2> MSProducts = [SELECT Id, MorningstarId__c FROM Product2 WHERE MorningstarId__c != null];
        
        for (Product2 p : MSProducts) {
            MSProductMap.put(p.MorningstarId__c, p);
        }
        
        Map<String,ProductPerformance__c> ppToUpsertMap = new Map<String,ProductPerformance__c>();
        List<ProductPerformance__c> ppToUpsertME = new List<ProductPerformance__c>();
        Map<String,ProductPerformance__c> ppProduct = new Map<String,ProductPerformance__c>();
        Date MSRatingDate;
        Date MSRatingDateNextME;
        
        Dom.Document doc = new Dom.Document();
        doc.load(strXml);
        Dom.XMLNode envelope = doc.getRootElement(); 
        List<Dom.XMLNode> data = envelope.getChildElements();
        
        for (Dom.XMLNode d : data) {
            if (d.getChildElements().size() != 0) {
                Dom.XMLNode api = d.getChildElements()[0];
                List<Dom.XMLNode> details = api.getChildElements();
                ProductPerformance__c pp = new ProductPerformance__c();
                ProductPerformance__c pprd = new ProductPerformance__c();
                
                for (Dom.XMLNode dtl : details) {
                    String elementName = dtl.getName();
                    String elementText = dtl.getText();
                    system.debug('Getting ' + elementName + ' : ' + elementText);
                    if (elementName == 'FSCBI-MStarID') {
                        if (MSProductMap.containsKey(elementText)) {
                            pp.Product__c = MSProductMap.get(elementText).Id;
                        } else {
                            system.debug('MStarId: '+elementText);
                        }
                    }
                    
                    if (elementName == 'FSCBI-CategoryName') pp.MorningstarCategoryName__c = elementText;
                    if (elementName == 'DP-Rank10Yr') pp.MorningstarDailyRank10Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank1Day') pp.MorningstarDailyRank1Day__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank1Mth') pp.MorningstarDailyRank1Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank1Week') pp.MorningstarDailyRank1Week__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank1Yr') pp.MorningstarDailyRank1Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank3Mth') pp.MorningstarDailyRank3Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank3Yr') pp.MorningstarDailyRank3Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank5Yr') pp.MorningstarDailyRank5Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-Rank6Mth') pp.MorningstarDailyRank6Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-RankMTD') pp.MorningstarDailyRankMTD__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-RankQTD') pp.MorningstarDailyRankQTD__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-RankYTD') pp.MorningstarDailyRankYTD__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize10Yr') pp.MorningstarDailyCategorySize10Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize1Day') pp.MorningstarDailyCategorySize1Day__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize1Mth') pp.MorningstarDailyCategorySize1Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize1Week') pp.MorningstarDailyCategorySize1Week__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize1Yr') pp.MorningstarDailyCategorySize1Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize3Mth') pp.MorningstarDailyCategorySize3Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize3Yr') pp.MorningstarDailyCategorySize3Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize5Yr') pp.MorningstarDailyCategorySize5Year__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySize6Mth') pp.MorningstarDailyCategorySize6Month__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySizeMTD') pp.MorningstarDailyCategorySizeMTD__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySizeQTD') pp.MorningstarDailyCategorySizeQTD__c = decimal.valueOf(elementText);
                    if (elementName == 'DP-CategorySizeYTD') pp.MorningstarDailyCategorySizeYTD__c = decimal.valueOf(elementText);
                    if (elementName == 'ART-AnalystRating') pp.MorningstarAnalystRating__c = elementText;
                    if (elementName == 'MR-NumberOfFunds10Year') pp.MorningstarNumberOfFunds10Year__c = integer.valueOf(elementText);
                    if (elementName == 'MR-NumberOfFunds3Year') pp.MorningstarNumberOfFunds3Year__c = integer.valueOf(elementText);
                    if (elementName == 'MR-NumberOfFunds5Year') pp.MorningstarNumberOfFunds5Year__c = integer.valueOf(elementText);
                    if (elementName == 'MR-NumberOfFundsOverall') pp.MorningstarNumberOfFundsOverall__c = integer.valueOf(elementText);
                    if (elementName == 'MR-Rating10Year') pp.MorningstarRating10Year__c = elementText;
                    if (elementName == 'MR-Rating3Year') pp.MorningstarRating3Year__c = elementText;
                    if (elementName == 'MR-Rating5Year') pp.MorningstarRating5Year__c = elementText;
                    if (elementName == 'MR-RatingOverall') pp.MorningstarRatingOverall__c = elementText;
                    if (elementName == 'TTRR-AbsRank10Yr') pp.MorningstarAbsoluteRank10Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank1Mth') pp.MorningstarAbsoluteRank1Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank1Yr') pp.MorningstarAbsoluteRank1Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank3Mth') pp.MorningstarAbsoluteRank3Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank3Yr') pp.MorningstarAbsoluteRank3Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank5Yr') pp.MorningstarAbsoluteRank5Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRank6Mth') pp.MorningstarAbsoluteRank6Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-AbsRankYTD') pp.MorningstarAbsoluteRankYTD__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize10Yr') pp.MorningstarCategorySize10Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize1Mth') pp.MorningstarCategorySize1Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize1Yr') pp.MorningstarCategorySize1Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize3Mth') pp.MorningstarCategorySize3Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize3Yr') pp.MorningstarCategorySize3Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize5Yr') pp.MorningstarCategorySize5Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySize6Mth') pp.MorningstarCategorySize6Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-CategorySizeYTD') pp.MorningstarCategorySizeYTD__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank10Yr') pp.MorningstarRank10Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank1Mth') pp.MorningstarRank1Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank1Yr') pp.MorningstarRank1Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank3Mth') pp.MorningstarRank3Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank3Yr') pp.MorningstarRank3Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank5Yr') pp.MorningstarRank5Year__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-Rank6Mth') pp.MorningstarRank6Month__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-RankYTD') pp.MorningstarRankYTD__c = integer.valueOf(elementText);
                    if (elementName == 'TTRR-MonthEndDate') pp.MorningstarMonthEndDate__c = date.valueOf(elementText);
                    if (elementName == 'MR-RatingDate') pp.MorningstarRatingDate__c = date.valueOf(elementText);
                    if (elementName == 'DP-DayEndDate') pp.AsOfDate__c = date.valueOf(elementText);
                }
                
                if (pp.Product__c != null && pp.AsOfDate__c != null) {
                    pp.ExternalID__c = (pp.Product__c + '|' + pp.AsOfDate__c.format());
                    pp.HasMorningstar__c = TRUE;
                    ppToUpsertMap.put(pp.ExternalID__c,pp);
                    if ((pp.MorningstarRatingDate__c != null) && (pp.MorningstarRatingDate__c.monthsBetween(pp.AsOfDate__c) == 1)) {
                        ppProduct.put(pp.Product__c,pp);
                        MSRatingDate = pp.MorningstarRatingDate__c;
                        MSRatingDateNextME = Date.newInstance(MSRatingDate.addMonths(1).year(),
                                                              MSRatingDate.addMonths(1).month(),
                                                              Date.daysInMonth(MSRatingDate.addMonths(1).year(),MSRatingDate.addMonths(1).month()));
                    }                 
                } 
            }
        }
        
        upsert ppToUpsertMap.values() ExternalID__c;
        
        for (ProductPerformance__c r : [SELECT Id, ExternalId__c, AsOfDate__c, Product__c, MorningstarCategoryName__c, MorningstarMonthEndDate__c,
                                        MorningstarNumberOfFunds10Year__c, MorningstarNumberOfFunds3Year__c, MorningstarNumberOfFunds5Year__c, MorningstarNumberOfFundsOverall__c,
                                        MorningstarRating10Year__c, MorningstarRating3Year__c, MorningstarRating5Year__c, MorningstarRatingOverall__c, 
                                        MorningstarAbsoluteRank10Year__c, MorningstarAbsoluteRank1Month__c, MorningstarAbsoluteRank1Year__c, MorningstarAbsoluteRank3Month__c,
                                        MorningstarAbsoluteRank3Year__c, MorningstarAbsoluteRank5Year__c, MorningstarAbsoluteRank6Month__c, MorningstarAbsoluteRankYTD__c,
                                        MorningstarCategorySize10Year__c, MorningstarCategorySize1Month__c, MorningstarCategorySize1Year__c, MorningstarCategorySize3Month__c,
                                        MorningstarCategorySize3Year__c, MorningstarCategorySize5Year__c, MorningstarCategorySize6Month__c, MorningstarCategorySizeYTD__c,
                                        MorningstarRank10Year__c, MorningstarRank1Month__c, MorningstarRank1Year__c, MorningstarRank3Month__c, MorningstarRank3Year__c,
                                        MorningstarRank5Year__c, MorningstarRank6Month__c, MorningstarRankYTD__c, MorningstarRatingDate__c
                                        FROM ProductPerformance__c
                                        WHERE AsOfDate__c >= : MSRatingDate
                                        AND AsOfDate__c <= : MSRatingDateNextME
                                        AND Product__c in : ppProduct.keySet()]) {
                                            
                                            r.MorningstarCategoryName__c = ppProduct.get(r.Product__c).MorningstarCategoryName__c;
                                            r.MorningstarMonthEndDate__c = ppProduct.get(r.Product__c).MorningstarMonthEndDate__c;
                                            r.MorningstarNumberOfFunds10Year__c = ppProduct.get(r.Product__c).MorningstarNumberOfFunds10Year__c;
                                            r.MorningstarNumberOfFunds3Year__c = ppProduct.get(r.Product__c).MorningstarNumberOfFunds3Year__c;
                                            r.MorningstarNumberOfFunds5Year__c = ppProduct.get(r.Product__c).MorningstarNumberOfFunds5Year__c;
                                            r.MorningstarNumberOfFundsOverall__c = ppProduct.get(r.Product__c).MorningstarNumberOfFundsOverall__c;
                                            r.MorningstarRating10Year__c = ppProduct.get(r.Product__c).MorningstarRating10Year__c;
                                            r.MorningstarRating3Year__c = ppProduct.get(r.Product__c).MorningstarRating3Year__c;
                                            r.MorningstarRating5Year__c = ppProduct.get(r.Product__c).MorningstarRating5Year__c;
                                            r.MorningstarRatingOverall__c = ppProduct.get(r.Product__c).MorningstarRatingOverall__c;
                                            r.MorningstarAbsoluteRank10Year__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank10Year__c;
                                            r.MorningstarAbsoluteRank1Month__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank1Month__c;
                                            r.MorningstarAbsoluteRank1Year__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank1Year__c;
                                            r.MorningstarAbsoluteRank3Month__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank3Month__c;
                                            r.MorningstarAbsoluteRank3Year__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank3Year__c;
                                            r.MorningstarAbsoluteRank5Year__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank5Year__c;
                                            r.MorningstarAbsoluteRank6Month__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRank6Month__c;
                                            r.MorningstarAbsoluteRankYTD__c = ppProduct.get(r.Product__c).MorningstarAbsoluteRankYTD__c;
                                            r.MorningstarCategorySize10Year__c = ppProduct.get(r.Product__c).MorningstarCategorySize10Year__c;
                                            r.MorningstarCategorySize1Month__c = ppProduct.get(r.Product__c).MorningstarCategorySize1Month__c;
                                            r.MorningstarCategorySize1Year__c = ppProduct.get(r.Product__c).MorningstarCategorySize1Year__c;
                                            r.MorningstarCategorySize3Month__c = ppProduct.get(r.Product__c).MorningstarCategorySize3Month__c;
                                            r.MorningstarCategorySize3Year__c = ppProduct.get(r.Product__c).MorningstarCategorySize3Year__c;
                                            r.MorningstarCategorySize5Year__c = ppProduct.get(r.Product__c).MorningstarCategorySize5Year__c;
                                            r.MorningstarCategorySize6Month__c = ppProduct.get(r.Product__c).MorningstarCategorySize6Month__c;
                                            r.MorningstarCategorySizeYTD__c = ppProduct.get(r.Product__c).MorningstarCategorySizeYTD__c;
                                            r.MorningstarRank10Year__c = ppProduct.get(r.Product__c).MorningstarRank10Year__c;
                                            r.MorningstarRank1Month__c = ppProduct.get(r.Product__c).MorningstarRank1Month__c;
                                            r.MorningstarRank1Year__c = ppProduct.get(r.Product__c).MorningstarRank1Year__c;
                                            r.MorningstarRank3Month__c = ppProduct.get(r.Product__c).MorningstarRank3Month__c;
                                            r.MorningstarRank3Year__c = ppProduct.get(r.Product__c).MorningstarRank3Year__c;
                                            r.MorningstarRank5Year__c = ppProduct.get(r.Product__c).MorningstarRank5Year__c;
                                            r.MorningstarRank6Month__c = ppProduct.get(r.Product__c).MorningstarRank6Month__c;
                                            r.MorningstarRankYTD__c = ppProduct.get(r.Product__c).MorningstarRankYTD__c;
                                            r.MorningstarRatingDate__c = ppProduct.get(r.Product__c).MorningstarRatingDate__c;
                                            
                                            ppToUpsertME.add(r);
                                            
                                        }
        
        
        upsert ppToUpsertME;
        
    }
    
    
}