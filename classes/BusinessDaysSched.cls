global class BusinessDaysSched implements Schedulable{

    global void execute(SchedulableContext sc) {
        
		BusinessDays myBD = new BusinessDays();
		myBD.DailyStoreInCS();
        	
    }
}