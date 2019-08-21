/**
 * @author Pratibha Potluri
 * @Created Date: 09/04/2018
 * @description : handler class for BenchmarkPerformanceApprovalTrigger. 
**/

public class BenchmarkPerformApprovalTriggerHandler {
    
    /**
    Method called after insert or after update to process Approved BenchmarkPerformanceApproval records 
    and create BenchmarkPerformance records 
    and delete BenchmarkPerformanceApproval records once converted
    **/
    
    public static void afterActions(List<BenchmarkPerformanceApproval__c> lstNew){
    
        List<BenchmarkPerformanceApproval__c> benchmarkApprovalsToDelete = new List<BenchmarkPerformanceApproval__c>(); 
        List<BenchmarkPerformance__c> lstToInsert = new List<BenchmarkPerformance__c>();
        
        for(BenchmarkPerformanceApproval__c ba:lstNew){
            
            if(ba.Approved__c){
            BenchmarkPerformanceApproval__c del = new BenchmarkPerformanceApproval__c();
            del.Id = ba.Id;
            benchmarkApprovalsToDelete.add(del);
            lstToInsert.add(frameBP(ba));
            }
        }
        
        if(!benchmarkApprovalsToDelete.IsEmpty()){
            delete benchmarkApprovalsToDelete; 
        }
        
        if(!lstTOInsert.IsEmpty()){  
           //  List<Database.UpsertResult> upsrtResultList = Database.upsert(s_targetRecordList, s_externalIdField, false);  
            Schema.SObjectField ftoken = BenchmarkPerformance__c.Fields.ExternalID__c;
            Database.UpsertResult[] srList = Database.upsert(lstTOInsert,ftoken);        
            //insert lstTOInsert;
        }
    }
    
    
    /** 
    Method framing the BenchmarkPerformance record from the values of 
    BenchmarkPerformanceApproval Record
    taking BenchmarkPerformanceApproval record as Input
    **/
    
    public static BenchmarkPerformance__c frameBP(BenchmarkPerformanceApproval__c bpa){
        
        BenchmarkPerformance__c  bp = new BenchmarkPerformance__c();
        bp.X10Year__c= bpa.X10Year__c;
        bp.X1DayGross__c= bpa.X1DayGross__c;
        bp.X1DayNet__c= bpa.X1DayNet__c;
        bp.X1DayPriceChange__c= bpa.X1DayPriceChange__c;
        bp.X1Month__c= bpa.X1Month__c;
        bp.X1Year__c= bpa.X1Year__c;
        bp.X3Month__c= bpa.X3Month__c;
        bp.X3Year__c= bpa.X3Year__c;
        bp.X5Year__c= bpa.X5Year__c;
        bp.Approved__c= bpa.Approved__c;
        bp.AsOfDate__c= bpa.AsOfDate__c;
        bp.Benchmark__c= bpa.Benchmark__c;
        bp.ExternalID__c= bpa.ExternalID__c;
        bp.InceptionDate__c= bpa.InceptionDate__c;
        bp.MTD__c = bpa.MTD__c;
        bp.price__c = bpa.price__c;
        bp.QTD__c = bpa.QTD__c;
        bp.SinceInception__c= bpa.SinceInception__c;
        bp.TotalGross__c= bpa.TotalGross__c;
        bp.TotalNet__c = bpa.TotalNet__c;
        bp.YTD__c = bpa.YTD__c;
        bp.Source__c = bpa.Source__c;
        bp.SourceFile__c = bpa.SourceFile__c;
        bp.FileType__c = bpa.FileType__c;
        bp.Tickers__c = bpa.Tickers__c;   
        bp.ReturnSinceInceptionCumulative__c = bpa.ReturnSinceInceptionCumulative__c;
        bp.ReturnSinceInceptionAnnualized__c = bpa.ReturnSinceInceptionAnnualized__c;     
        
        return bp;                
    }

}