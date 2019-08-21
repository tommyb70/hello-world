public class ProductCharacteristicTriggerHandler {
    
    public static List<ProductCharacteristic__c> SetPublishScheduleAndDate(List<ProductCharacteristic__c> myProdChar) {
        
        CDRSettings__c settings = CDRSettings__c.getvalues('NGAM');
        String BHName = settings.BusinessHoursName__c;
        businessHours bh = [SELECT Id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, 
                            WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, 
                            SaturdayStartTime, SundayEndTime, SundayStartTime 
                            FROM BusinessHours WHERE Name = :BHName LIMIT 1];
        
        List<Holiday> holidays = [SELECT Id, ActivityDate, RecurrenceType, RecurrenceDayOfMonth, RecurrenceMonthOfYear from Holiday];    
        
        Set<Id> productIdSet = new Set<Id>();
        for (ProductCharacteristic__c pc : myProdChar) {
            productIdSet.add(pc.Product__c);
        }
        
        Map<Id,Product2> prodMap = new Map<Id,Product2>([SELECT Id, Top10HoldingsPublishingSchedule__c
                                                         FROM Product2
                                                         WHERE Id in :productIdSet]);
        
        for (ProductCharacteristic__c pc : myProdChar) {
            
            switch on pc.Type__c {

                when 'Top ten holdings' {
                    pc.PublishingSchedule__c = prodMap.get(pc.Product__c).Top10HoldingsPublishingSchedule__c;
                }
                
                when else {
                    pc.PublishingSchedule__c = 'Immediately';
                } 
            }
         
            switch on pc.PublishingSchedule__c {                
                when 'Never' {
                    pc.PublishDate__c = null;  
                }
                when 'Immediately' {
                    pc.PublishDate__c = pc.AsOfDate__c;  
                }
                when '7th Business Day' {
                    Date startDate = pc.AsOfDate__c.addMonths(1).toStartOfMonth();
                    pc.PublishDate__c = getFutureBusinessDate(bh, holidays, startDate,7);    
                }
                when '8th Calendar Day' {
                    //setting to 7 because first day is the 1st day to which we are adding days               
                    pc.PublishDate__c = pc.AsOfDate__c.addMonths(1).toStartOfMonth().addDays(7);
                }
                when '1st Business Day After the Following Month-End' {
                    Date startDate = pc.AsOfDate__c.addMonths(2).toStartOfMonth();
                    pc.PublishDate__c = getFutureBusinessDate(bh, holidays, startDate,1);                
                }
                when '10th Business Day After Quarter-End' {
                    Date QEDate = getQuarterEndDate(pc.AsOfDate__c);
                    Date startDate = QEDate.addMonths(1).toStartOfMonth();
                    pc.PublishDate__c = getFutureBusinessDate(bh, holidays, startDate,10);
                }
            }
        }              
        return myProdChar;        
    }

    public static List<ProductCharacteristic__c> SetCharacteristicOutputText(List<ProductCharacteristic__c> myProdChar) {
                
        for (ProductCharacteristic__c pc : myProdChar) {
         
            switch on pc.CharacteristicsDataType__c {
                
                when 'Integer' {
                    if (pc.ProductCharacteristicsInteger__c != null) pc.ProductCharacteristicsOutputText__c = pc.ProductCharacteristicsInteger__c.format();
                    if (pc.IndexCharacteristicsInteger__c != null) pc.IndexCharacteristicsOutputText__c = pc.IndexCharacteristicsInteger__c.format();
                } 
                when 'Decimal' {
                    if (pc.ProductCharacteristicsDecimal__c != null) {
                        pc.ProductCharacteristicsOutputText__c = pc.ProductCharacteristicsDecimal__c.format();
                        pc.ProductCharacteristicsOutputText__c = pc.ProductCharacteristicsOutputText__c.substringBeforeLast('.') + '.' + pc.ProductCharacteristicsOutputText__c.substringAfterLast('.').rightpad(2,'0');
                    }
                    if (pc.IndexCharacteristicsDecimal__c != null) {
                        pc.IndexCharacteristicsOutputText__c = pc.IndexCharacteristicsDecimal__c.format();
                        pc.IndexCharacteristicsOutputText__c = pc.IndexCharacteristicsOutputText__c.substringBeforeLast('.') + '.' + pc.IndexCharacteristicsOutputText__c.substringAfterLast('.').rightpad(2,'0');
                    }
                }                                
                when 'Text' {
                    if (pc.ProductCharacteristicsText__c != null) pc.ProductCharacteristicsOutputText__c = pc.ProductCharacteristicsText__c;
                    if (pc.IndexCharacteristicsText__c != null) pc.IndexCharacteristicsOutputText__c = pc.IndexCharacteristicsText__c;
                }
            }            
        }       
        return myProdChar;
    }
    
    public static List<ProductCharacteristic__c> SetPublishedFlag(List<ProductCharacteristic__c> myProdChar) {
                
        for (ProductCharacteristic__c pc : myProdChar) {
            if (pc.PublishDate__c <= Date.today() && pc.Approved__c == TRUE) pc.Published__c = TRUE;
        }       
        return myProdChar;
    }    
    
    private static Date getQuarterEndDate(Date aod) {
        
        Date qed;
        
        switch on aod.month() {
            when 1,2,3 {
                qed = date.newInstance(aod.year(),3,31);  
            }
            when 4,5,6 {
                qed = date.newInstance(aod.year(),6,30);  
            }
            when 7,8,9 {
                qed = date.newInstance(aod.year(),9,30);  
            }
            when 10,11,12 {
                qed = date.newInstance(aod.year(),12,31);  
            }
        }
        return qed;
    }
    
    private static Date getFutureBusinessDate(BusinessHours bh, List<Holiday> h, Date myDate, Integer numberOfBusinessDays) {
        
        BusinessHoursMath businessHoursMath = new BusinessHoursMath();
        businessHoursMath.setBusinessHours(bh);
        businessHoursMath.setHolidays(h);
        Date returnDate;
          
        Integer BDCount = 0;
        Integer i = 0;
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