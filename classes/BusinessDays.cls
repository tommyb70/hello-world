public class BusinessDays {
    
   public void DailyStoreInCS()
   		{
        Date myYesterday = LastBusinessDay();
        Date firstDayOfMonth = myYesterday.toStartOfMonth();

        Date lastDayOfPreviousMonth = firstDayOfMonth -1;
        Date firstDayOfPreviousMonth = (lastDayOfPreviousMonth).toStartOfMonth();
        
        Decimal curQd = ((Decimal)firstDayOfMonth.month()/3).setScale(2);
        Long curQ = curQd.round(System.RoundingMode.UP);
        Integer curY = firstDayOfMonth.year();
        Integer curQfM = (Integer)curQ*3-2;
       	Date firstDayOfQ = Date.newInstance(curY, curQfM, 1);
        
        Date LastDayOfPreviousQ = firstDayOfQ -1;
            
        Decimal curQdm1 = ((Decimal)LastDayOfPreviousQ.month()/3).setScale(2);
        Long curQm1 = curQdm1.round(System.RoundingMode.UP);
        Integer curYm1 = LastDayOfPreviousQ.year();
        Integer curQfMm1 = (Integer)curQm1*3-2;
       	Date firstDayOfQm1 = Date.newInstance(curYm1, curQfMm1, 1); 
            
        Date FirstDayOfPreviousQ = Date.newInstance(curYm1, curQfMm1, 1); 
               
        Integer WDmtd = calculateWorkingDaysBetweenTwoDates  (firstDayOfMonth,myYesterday);
        Integer WDlm = calculateWorkingDaysBetweenTwoDates  (firstDayOfPreviousMonth,lastDayOfPreviousMonth);
        Integer WDqtd = calculateWorkingDaysBetweenTwoDates  (firstDayOfQ,myYesterday);
        Integer WDlq = calculateWorkingDaysBetweenTwoDates  (FirstDayOfPreviousQ,LastDayOfPreviousQ);        
        
		//fetches or creates a Custom Setting at the organization level 
		OrgBusinessDays__c setting = OrgBusinessDays__c.getOrgDefaults();
		if (setting == null) setting = new OrgBusinessDays__c();
		setting.LastMonthProductionDays__c = WDlm;
        setting.LastQuarterProductionDays__c = WDlq;
        setting.MTDProductionDays__c = WDmtd;
        setting.QTDProductionDays__c = WDqtd;
		upsert setting;    
 
   		}
    
   public Date LastBusinessDay()
   		{
        Date myLastBusinessDay; 
        Date myToday = System.today().adddays(-1); 
        //myToday = Date.newInstance(2015,8,2);
        
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
            
		//Integer k = 1;
        Boolean FoundLast = false;
            
        While (!FoundLast) 
            {
            if (checkifItisWorkingDay(myToday,holidays))   
            	{
            	myLastBusinessDay = myToday;
                FoundLast = true;
                }
            myToday = myToday.adddays(-1);
            }
       	return myLastBusinessDay;
   		}
    
    
   public Integer calculateWorkingDaysBetweenTwoDates(Date date1,Date date2){
				
       			system.debug('date1 ' + date1);
       			system.debug('date2 ' + date2);
       
               List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];

                Integer allDaysBetween = date1.daysBetween(date2) + 1;
                //Integer allDaysBetween = date2 - date1;
       			system.debug('allDaysBetween ' + allDaysBetween);
                Integer allWorkingDays=0;
                for(Integer k=0;k<allDaysBetween ;k++ ){
                    if(checkifItisWorkingDay(date1.addDays(k),holidays)){
                        allWorkingDays++;
                    } 
                }

                return allWorkingDays;
      }

	public boolean checkifItisWorkingDay(Date currentDate,List<Holiday> holidays){
                 Date weekStart  = currentDate.toStartofWeek();
                for(Holiday hDay:holidays){
                        if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                                 return false;
                        }
                }
               if(weekStart.daysBetween(currentDate) == 0 || weekStart.daysBetween(currentDate) == 6){
                       return false;
                } else 
                       return true;
  }

}