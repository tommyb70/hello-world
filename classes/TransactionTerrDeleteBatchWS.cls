@RestResource(urlMapping='/TransactionTerrDelete/*')
global with sharing class TransactionTerrDeleteBatchWS {

    @HttpGet
    global static List<id> TransactionTerrBatchDeleteIds() {
        List<id> TransactionTerrJobList = new List<id>();
        
        Integer TotDays = 32;
		DateTime Date0 = system.now();
		DateTime Date1 = system.now().addDays(-TotDays/5);
		DateTime Date2 = system.now().addDays(-TotDays*2/5);     
		DateTime Date3 = system.now().addDays(-TotDays*3/5);    
		DateTime Date4 = system.now().addDays(-TotDays*4/5); 
        
		TransactionTerrDeleteBatch ttj1 = new TransactionTerrDeleteBatch();
		ttj1.query = 'select id from TransactionTerr__c where ScrubDate__c <='+ Date0.format('yyyy-MM-dd')+'T'+ Date0.format('HH:mm')+':00.000Z';
        ttj1.query = ttj1.query + ' and ScrubDate__c >'+ Date1.format('yyyy-MM-dd')+'T'+ Date1.format('HH:mm')+':00.000Z';
        system.debug(ttj1.query);
        ID ttjid1 = database.executeBatch(ttj1,2000); 
        TransactionTerrJobList.add(ttjid1);
        
		TransactionTerrDeleteBatch ttj2 = new TransactionTerrDeleteBatch();
		ttj2.query = 'select id from TransactionTerr__c where ScrubDate__c <='+ Date1.format('yyyy-MM-dd')+'T'+ Date1.format('HH:mm')+':00.000Z';
        ttj2.query = ttj2.query + ' and ScrubDate__c >'+ Date2.format('yyyy-MM-dd')+'T'+ Date2.format('HH:mm')+':00.000Z';
        system.debug(ttj2.query);
        ID ttjid2 = database.executeBatch(ttj2,2000); 
        TransactionTerrJobList.add(ttjid2);
         
		TransactionTerrDeleteBatch ttj3 = new TransactionTerrDeleteBatch();
		ttj3.query = 'select id from TransactionTerr__c where ScrubDate__c <='+ Date2.format('yyyy-MM-dd')+'T'+ Date2.format('HH:mm')+':00.000Z';
        ttj3.query = ttj3.query + ' and ScrubDate__c >'+ Date3.format('yyyy-MM-dd')+'T'+ Date3.format('HH:mm')+':00.000Z';
        system.debug(ttj3.query);
        ID ttjid3 = database.executeBatch(ttj3,2000); 
        TransactionTerrJobList.add(ttjid3);       
         
		TransactionTerrDeleteBatch ttj4 = new TransactionTerrDeleteBatch();
		ttj4.query = 'select id from TransactionTerr__c where ScrubDate__c <='+ Date3.format('yyyy-MM-dd')+'T'+ Date3.format('HH:mm')+':00.000Z';
        ttj4.query = ttj4.query + ' and ScrubDate__c >'+ Date4.format('yyyy-MM-dd')+'T'+ Date4.format('HH:mm')+':00.000Z';
        system.debug(ttj4.query);
        ID ttjid4 = database.executeBatch(ttj4,2000); 
        TransactionTerrJobList.add(ttjid4);       
         
		TransactionTerrDeleteBatch ttj5 = new TransactionTerrDeleteBatch();
		ttj5.query = 'select id from TransactionTerr__c where ScrubDate__c <='+ Date4.format('yyyy-MM-dd')+'T'+ Date4.format('HH:mm')+':00.000Z';
        //ttj5.query = ttj5.query + ' and ScrubDate__c >'+ Date4.format('yyyy-MM-dd')+'T'+ Date4.format('HH:mm')+':00.000Z';
        system.debug(ttj5.query);
        ID ttjid5 = database.executeBatch(ttj5,2000); 
        TransactionTerrJobList.add(ttjid5);       


        return TransactionTerrJobList ;
    }
    
}