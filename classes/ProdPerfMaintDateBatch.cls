global class ProdPerfMaintDateBatch implements Database.Batchable<sObject> {
    
    public CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
    String BHName = settings.BusinessHoursName__c;
    String lastNDaysParm = settings.ProdPerfBatchLASTNDAYS__c;
    
    public String  query = ' SELECT Id, AsOfDate__c, Product__c, PriorDate__c, PriorBusinessDate__c, MonthEndDate__c, PriorMonthEndDate__c, PriorMonthEndBusinessDate__c, IsAsOfDateBusinessDate__c, ' +
        ' QuarterEndDate__c, PriorQuarterEndDate__c, PriorQuarterEndBusinessDate__c, YearEndDate__c, PriorYearEndDate__c, PriorYearEndBusinessDate__c, IsYearEnd__c, IsMonthEnd__c, ' +
        ' IsQuarterEnd__c, PriorProductPerfExtId__c, PriorMonthEndProdPerfExtId__c, PriorQuarterEndProdPerfExtId__c, PriorYearEndProdPerfExtId__c, ' +
        ' TotalNetAssets__c, SharesOutstanding__c, ExternalID__c, NextBusinessDate__c, NextBusinessDateProdPerfExtId__c ' +
        ' FROM ProductPerformance__c ' +
        ' WHERE AsOfDate__c = LAST_N_DAYS:' + lastNDaysParm + ' ' +
        ' ORDER BY AsOfDate__c ' ;
    
    public businessHours bh = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, 
                               WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, 
                               SaturdayStartTime, SundayEndTime, SundayStartTime 
                               FROM BusinessHours WHERE Name = :BHName LIMIT 1];
    
    public List<Holiday> holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday];    
    
    global ProdPerfMaintDateBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {      
        System.Debug('Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ProductPerformance__c> scope) {
        
        Map<Date, ProductPerformance__c> dateMap = new Map<Date, ProductPerformance__c>();
        List<ProductPerformance__c> prodPerfToUpdate = new List<ProductPerformance__c>();
        
        for (ProductPerformance__c npp : scope) {
            
            if (!dateMap.containsKey(npp.AsOfDate__c)) {
                
                ProductPerformance__c ppDateWork = new ProductPerformance__c(AsOfDate__c = npp.AsOfDate__c);
                
                // Dates
                ppDateWork.PriorDate__c = ppDateWork.AsOfDate__c.addDays(-1);
                
                ppDateWork.PriorBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.AsOfDate__c);
                ppDateWork.NextBusinessDate__c = getFutureBusinessDate(bh, holidays, ppDateWork.AsOfDate__c, 1);
                ppDateWork.IsAsOfDateBusinessDate__c = BusinessHours.isWithin(bh.Id, ppDateWork.AsOfDate__c);
                
                // Month-End Dates
                Integer daysInMonth = Date.daysInMonth(ppDateWork.AsOfDate__c.year(),ppDateWork.AsOfDate__c.month());
                ppDateWork.MonthEndDate__c = Date.newInstance(ppDateWork.AsOfDate__c.year(),ppDateWork.AsOfDate__c.month(),daysInMonth);    
                
                Date priorMonthDate = ppDateWork.AsOfDate__c.addMonths(-1);
                Date priorPriorMonthDate = ppDateWork.AsOfDate__c.addMonths(-2);
                Integer priorDaysInMonth = Date.daysInMonth(priorMonthDate.year(),priorMonthDate.month());
                Integer priorPriorDaysInMonth = Date.daysInMonth(priorPriorMonthDate.year(),priorPriorMonthDate.month());
                ppDateWork.PriorMonthEndDate__c = Date.newInstance(priorMonthDate.year(),priorMonthDate.month(),priorDaysInMonth);   
                ppDateWork.PriorMonthEndBusinessDate__c = getPriorBusinessDate(bh, holidays,ppDateWork.PriorMonthEndDate__c);
                ppDateWork.PriorPriorMonthEndDate__c = Date.newInstance(priorPriorMonthDate.year(),priorPriorMonthDate.month(),priorPriorDaysInMonth); 
                ppDateWork.PriorPriorMonthEndBusinessDate__c = getPriorBusinessDate(bh, holidays, priorPriorMonthDate);
                
                //Quarter End Dates
                If (ppDateWork.AsOfDate__c.month() == 1 || ppDateWork.AsOfDate__c.month() == 2 || ppDateWork.AsOfDate__c.month() == 3){
                    ppDateWork.QuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),3,31);
                    ppDateWork.PriorQuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year()-1,12,31);
                    ppDateWork.PriorQuarterEndBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.PriorQuarterEndDate__c);
                }
                If (ppDateWork.AsOfDate__c.month() == 4 || ppDateWork.AsOfDate__c.month() == 5 || ppDateWork.AsOfDate__c.month() == 6){
                    ppDateWork.QuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),6,30);
                    ppDateWork.PriorQuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),3,31);
                    ppDateWork.PriorQuarterEndBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.PriorQuarterEndDate__c);
                    
                }
                If (ppDateWork.AsOfDate__c.month() == 7 || ppDateWork.AsOfDate__c.month() == 8 || ppDateWork.AsOfDate__c.month() == 9){
                    ppDateWork.QuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),9,30);
                    ppDateWork.PriorQuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),6,30);
                    ppDateWork.PriorQuarterEndBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.PriorQuarterEndDate__c);
                }
                If (ppDateWork.AsOfDate__c.month() == 10 || ppDateWork.AsOfDate__c.month() == 11 || ppDateWork.AsOfDate__c.month() == 12){
                    ppDateWork.QuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),12,31);
                    ppDateWork.PriorQuarterEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),9,30);
                    ppDateWork.PriorQuarterEndBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.PriorQuarterEndDate__c);
                }
                
                //Year End Dates            
                ppDateWork.YearEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year(),12,31);
                ppDateWork.PriorYearEndDate__c = date.newInstance(ppDateWork.AsOfDate__c.year()-1,12,31);
                ppDateWork.PriorYearEndBusinessDate__c = getPriorBusinessDate(bh, holidays, ppDateWork.PriorYearEndDate__c);
                
                //Period Checkboxes
                if (ppDateWork.AsOfDate__c.isSameDay(ppDateWork.YearEndDate__c)) ppDateWork.IsYearEnd__c = TRUE;
                if (ppDateWork.AsOfDate__c.isSameDay(ppDateWork.MonthEndDate__c)) ppDateWork.IsMonthEnd__c = TRUE;
                if (ppDateWork.AsOfDate__c.isSameDay(ppDateWork.QuarterEndDate__c)) ppDateWork.IsQuarterEnd__c = TRUE;
                
                dateMap.put(ppDateWork.AsOfDate__c, ppDateWork);
            }
            
            ProductPerformance__c ppDates = dateMap.get(npp.AsOfDate__c);
            
            npp.PriorDate__c = ppDates.PriorDate__c;
            npp.PriorBusinessDate__c = ppDates.PriorBusinessDate__c;
            npp.MonthEndDate__c = ppDates.MonthEndDate__c;   
            npp.PriorMonthEndDate__c = ppDates.PriorMonthEndDate__c;
            npp.PriorMonthEndBusinessDate__c = ppDates.PriorMonthEndBusinessDate__c;
            npp.IsAsOfDateBusinessDate__c = ppDates.IsAsOfDateBusinessDate__c;
            npp.QuarterEndDate__c = ppDates.QuarterEndDate__c;
            npp.PriorQuarterEndDate__c = ppDates.PriorQuarterEndDate__c;
            npp.PriorQuarterEndBusinessDate__c = ppDates.PriorQuarterEndBusinessDate__c;
            npp.YearEndDate__c = ppDates.YearEndDate__c;
            npp.PriorYearEndDate__c = ppDates.PriorYearEndDate__c;
            npp.PriorYearEndBusinessDate__c = ppDates.PriorYearEndBusinessDate__c;
            npp.IsYearEnd__c = ppDates.IsYearEnd__c;
            npp.IsMonthEnd__c = ppDates.IsMonthEnd__c;
            npp.IsQuarterEnd__c = ppDates.IsQuarterEnd__c;
            npp.PriorProductPerfExtId__c = ppDates.PriorProductPerfExtId__c;
            npp.PriorMonthEndProdPerfExtId__c = ppDates.PriorMonthEndProdPerfExtId__c;
            npp.PriorQuarterEndProdPerfExtId__c = ppDates.PriorQuarterEndProdPerfExtId__c;
            npp.PriorYearEndProdPerfExtId__c = ppDates.PriorYearEndProdPerfExtId__c;
            npp.PriorPriorMonthEndBusinessDate__c = ppDates.PriorPriorMonthEndBusinessDate__c;
            npp.PriorPriorMonthEndDate__c = ppDates.PriorPriorMonthEndDate__c;
            npp.NextBusinessDate__c = ppDates.NextBusinessDate__c;
            
            if (npp.IsAsofDateBusinessDate__c) {
                npp.NextBusinessDateProdPerfExtId__c = npp.Product__c + '|' + npp.NextBusinessDate__c.format();
            } else if (npp.IsMonthEnd__c && !npp.IsAsofDateBusinessDate__c) {
                npp.NextBusinessDateProdPerfExtId__c = npp.Product__c + '|' + npp.NextBusinessDate__c.format() + 'ME';
            }
            
            npp.PriorProductPerfExtId__c = npp.Product__c + '|' + npp.PriorBusinessDate__c.format();
            npp.PriorMonthEndProdPerfExtId__c = npp.Product__c + '|' + npp.PriorMonthEndDate__c.format();
            npp.PriorQuarterEndProdPerfExtId__c = npp.Product__c + '|' + npp.PriorQuarterEndDate__c.format();
            npp.PriorYearEndProdPerfExtId__c = npp.Product__c + '|' + npp.PriorYearEndDate__c.format();
            
            prodPerfToUpdate.add(npp);
            
        }
        
        upsert prodPerfToUpdate;
    }  
    
    public date getPriorBusinessDate(BusinessHours bh, List<Holiday> h, Date myDate) {
        
        BusinessHoursMath businessHoursMath = new BusinessHoursMath();
        businessHoursMath.setBusinessHours(bh);
        businessHoursMath.setHolidays(h);
        Date returnDate;
        
        Integer i = 1;
        while (1==1) {
            
            if (businessHoursMath.isBusinessDay(myDate.addDays(-i))) {
                returnDate = myDate.addDays(-i);
                break;
            }
            i++;
        }
        return returnDate;
    }
    
    global void finish(Database.BatchableContext BC) {
        
        Id batchJobId = Database.executeBatch(new ProdPerfMaintRefBatch());
        
    }
    
    public date getFutureBusinessDate(BusinessHours bh, List<Holiday> h, Date myDate, Integer numberOfBusinessDays) {
        
        BusinessHoursMath businessHoursMath = new BusinessHoursMath();
        businessHoursMath.setBusinessHours(bh);
        businessHoursMath.setHolidays(h);
        Date returnDate;
        
        Integer BDCount = 0;
        Integer i = 1;
        while (BDCount < numberOfBusinessDays) {
            
            if (businessHoursMath.isBusinessDay(myDate.addDays(i))) {
                returnDate = myDate.addDays(i);
                BDCount++;
            }
            i++;
        }
        
        return returnDate;
    }    
    
}