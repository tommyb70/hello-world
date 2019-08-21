public class ProductPerfHelper {
    
    public Boolean displayMSC = FALSE;

    public class MSRatingsItem {
        public string RowHeader {get;set;}
        public string Category {get;set;}
        public string Overall {get;set;}
        public string X3Year {get;set;}
        public string X5Year {get;set;}
        public string X10Year {get;set;}
        public decimal OverallNumberOfFunds {get;set;}
        public decimal X3YearNumberOfFunds {get;set;}
        public decimal X5YearNumberOfFunds {get;set;}
        public decimal X10YearNumberOfFunds {get;set;}
        public string RatingDate {get;set;}        
        
        public MSRatingsItem(String iRowHeader, String iCategory, String iOverall, String iX3Year, String iX5Year, String iX10Year, 
                             Decimal iOverallNumberOfFunds, Decimal iX3YearNumberOfFunds, Decimal iX5YearNumberOfFunds, Decimal iX10YearNumberOfFunds,
                             String iRatingDate) {
                                 RowHeader = iRowHeader;
                                 Category = iCategory;
                                 Overall = iOverall;
                                 X3Year = iX3Year;
                                 X5Year = iX5Year;
                                 X10Year = iX10Year;
                                 OverallNumberOfFunds = iOverallNumberOfFunds;
                                 X3YearNumberOfFunds = iX3YearNumberOfFunds;
                                 X5YearNumberOfFunds = iX5YearNumberOfFunds;
                                 X10YearNumberOfFunds = iX10YearNumberOfFunds;
                                 RatingDate = iRatingDate;
                             } 
        
    }
    
    public class MSRankingsItem {
        public string RowHeader {get;set;}
        public string Category {get;set;}
        public string X1Day {get;set;}
        public string X1Week {get;set;}
        public string X1Month {get;set;}
        public string X3Month {get;set;}
        public string X6Month {get;set;}
        public string X1Year {get;set;}
        public string X3Year {get;set;}
        public string X5Year {get;set;}
        public string X10Year {get;set;}
        public string MTD {get;set;}
        public string QTD {get;set;}
        public string YTD {get;set;}
        public string RankingDate {get;set;}   
        
        public MSRankingsItem(String iRowHeader, String iCategory, 
                              Decimal iX1Day, Decimal iX1Week, Decimal iX1Month, Decimal iX3Month, Decimal iMTD, Decimal iQTD, Decimal iYTD, Decimal iX1Year, Decimal iX3Year, Decimal iX5Year, Decimal iX10Year, 
                              Decimal iX1MonthSize, Decimal iX3MonthSize, Decimal iYTDSize, Decimal iX1YearSize, Decimal iX3YearSize, Decimal iX5YearSize, Decimal iX10YearSize, 
                              Decimal iX1MonthAbs, Decimal iX3MonthAbs, Decimal iYTDAbs, Decimal iX1YearAbs, Decimal iX3YearAbs, Decimal iX5YearAbs, Decimal iX10YearAbs,
                              Date iRankingDate) {
                                  RowHeader = iRowHeader;
                                  Category = iCategory;
                                  
                                  if (RowHeader == 'Daily') {
                                      if (iX1Day > 0) X1Day = iX1Day.format() + '%';
                                      if (iX1Day > 0) X1Week = iX1Week.format() + '%';
                                      if (iX1Month > 0) X1Month = iX1Month.format() + '%';
                                      if (iX3Month > 0) X3Month = iX3Month.format() + '%';
                                      if (iMTD > 0) MTD = iMTD.format() + '%';
                                      if (iQTD > 0) QTD = iQTD.format() + '%';
                                      if (iYTD > 0) YTD = iYTD.format() + '%';
                                      if (iX1Year > 0) X1Year = iX1Year.format() + '%';
                                      if (iX3Year > 0) X3Year = iX3Year.format() + '%';
                                      if (iX5Year > 0) X5Year = iX5Year.format() + '%';
                                      if (iX10Year > 0) X10Year = iX10Year.format() + '%';
                                  }
                                  
                                  if (RowHeader == 'Monthly') {
                                      if (iX1Month > 0) X1Month = iX1Month.format() + '% (' + iX1MonthAbs.format() + '/' + iX1MonthSize.format() + ')';
                                      if (iX3Month > 0) X3Month = iX3Month.format() + '% (' + iX3MonthAbs.format() + '/' + iX3MonthSize.format() + ')';                                  
                                      if (iYTD > 0) YTD = iYTD.format() + '% (' + iYTDAbs.format() + '/' + iYTDSize.format() + ')';                                  
                                      if (iX1Year > 0) X1Year = iX1Year.format() + '% (' + iX1YearAbs.format() + '/' + iX1YearSize.format() + ')';                                  
                                      if (iX3Year > 0) X3Year = iX3Year.format() + '% (' + iX3YearAbs.format() + '/' + iX3YearSize.format() + ')';                                  
                                      if (iX5Year > 0) X5Year = iX5Year.format() + '% (' + iX5YearAbs.format() + '/' + iX5YearSize.format() + ')';                                  
                                      if (iX10Year > 0) X10Year = iX10Year.format() + '% (' + iX10YearAbs.format() + '/' + iX10YearSize.format() + ')';
                                      X1Day = '-  ';
                                      X1Week = '-  ';
                                      MTD = '-  ';
                                      QTD = '-  ';
                                  }
                                  
                                  if (iRankingDate != null) RankingDate = iRankingDate.format();
                                  
                              } 
        
    }    
    
    
    
    public class DailyPerformanceItem {
        public string RowHeader { get; set; }
        public decimal Price {get;set;}
        public decimal PreviousPrice {get;set;}
        public decimal Change {get;set;}
        public decimal PercentChange {get;set;}
        public decimal MTD {get;set;}
        public decimal QTD {get;set;}
        public decimal YTD {get;set;}
        public decimal Distribution {get;set;}
        public decimal X7Day {get;set;}
        public decimal SECUnsub {get;set;}
        public decimal SECSub {get;set;}
        public decimal SECTax {get;set;}
        
        public DailyPerformanceItem(String iRh, 
                                    decimal iPrice, decimal iPreviousPrice, decimal iChange, decimal iPercentChange, 
                                    decimal iMTD, decimal iQTD, decimal iYTD, 
                                    decimal iDistribution, decimal iX7Day, decimal iSECUnsub, decimal iSECSub, decimal iSECTax) 
                                      {
                                        RowHeader = iRh;
                                        Price = iPrice;
                                        PreviousPrice = iPreviousPrice;
                                        Change = iChange;
                                        PercentChange = iPercentChange;
                                        MTD = iMTD;
                                        QTD = iQTD;
                                        YTD = iYTD;
                                        Distribution = iDistribution;
                                        X7Day = iX7Day;
                                        SECUnsub = iSECUnsub;
                                        SECSub = iSECSub;
                                        SECTax = iSECTax;
                                    }
    }
    
    public class YieldItem {
        public String RowHeader { get; set; }
        public Decimal Distribution {get;set;}
        public Decimal X7Day {get;set;}
        public Decimal SECUnsub {get;set;}
        public Decimal SECSub {get;set;}
        public Decimal SECTax {get;set;}
        
        public YieldItem(String iRh, 
                         decimal iDistribution, decimal iX7Day, decimal iSECSub, decimal iSECUnsub, decimal iSECTax) {
                             RowHeader = iRh;
                             Distribution = iDistribution;
                             X7Day = iX7Day;
                             SECUnsub = iSECUnsub;
                             SECSub = iSECSub;
                             SECTax = iSECTax;
                         }
    }
    
    public class DailyPerformanceItemROR {
        public string RowHeader { get; set; }
        public string RD {get;set;}
        public string RId {get;set;}
        public decimal MTD {get;set;}
        public decimal QTD {get;set;}
        public decimal YTD {get;set;}
        public decimal D1 {get;set;}
        public decimal M1 {get;set;}
        public decimal M3 {get;set;}
        public decimal Y1 {get;set;}
        public decimal Y3 {get;set;}
        public decimal Y5 {get;set;}
        public decimal Y10 {get;set;}
        public decimal Incept {get;set;}
        
        public DailyPerformanceItemROR(String iRh, date iRD, string iRId,
                                       decimal iMTD, decimal iQTD, decimal iYTD,
                                       decimal iD1, decimal iM1, decimal iM3, decimal iY1, decimal iY3, decimal iY5, decimal iY10, decimal iIncept) {
                                           RowHeader = iRh;
                                           RD = iRD.format();
                                           RId = iRId;
                                           MTD = iMTD;
                                           QTD = iQTD;
                                           YTD = iYTD;
                                           D1 = iD1;
                                           M1 = iM1;
                                           M3 = iM3;
                                           Y1 = iY1;
                                           Y3 = iY3;
                                           Y5 = iY5;
                                           Y10 = iY10;
                                           Incept = iIncept;
                                       }
    }
    
    public class AnnualPerformanceItem {
        public string RowHeader { get; set; }
        public decimal Y0 {get;set;}
        public decimal Y1 {get;set;}
        public decimal Y2 {get;set;}
        public decimal Y3 {get;set;}
        public decimal Y4 {get;set;}
        public decimal Y5 {get;set;}
        public decimal Y6 {get;set;}
        public decimal Y7 {get;set;}
        public decimal Y8 {get;set;}
        public decimal Y9 {get;set;} 
        
        public AnnualPerformanceItem(String iRh, 
                                     decimal iY0, decimal iY1, decimal iY2, decimal iY3, decimal iY4,
                                     decimal iY5, decimal iY6, decimal iY7, decimal iY8, decimal iY9) {
                                         RowHeader = iRh;
                                         Y0 = iY0;
                                         Y1 = iY1;
                                         Y2 = iY2;
                                         Y3 = iY3;
                                         Y4 = iY4;
                                         Y5 = iY5;
                                         Y6 = iY6;
                                         Y7 = iY7;
                                         Y8 = iY8;
                                         Y9 = iY9;
                                     }
    }
    
    public static ProductPerformance__c getProductPerformanceRow(Id p, Date d){
        
        List<ProductPerformance__c> ppl = [SELECT Id, AsOfDate__c, Product__c, Product__r.Name, Product__r.CUSIPFormatted__c, InceptionDate__c, ShareClass__c, LegalName__c, Product__r.DisplaySECTaxEquivalentYield__c,
                                           PriorBusinessDate__c, PriorMonthEndDate__c, PriorQuarterEndDate__c, PriorYearEndDate__c,
                                           PriorProductPerformance__c, PriorQuarterEndProductPerformance__c, PriorMonthEndProductPerformance__c, PriorYearEndProductPerformance__c,
                                           TotalNetAssets__c, SharesOutstanding__c,
                                           IsAsOfDateBusinessDate__c, 
                                           NAV__c, NAVChange__c, NAVPriorDay__c, NAVPercentChange__c, NAVMTD__c, NAVQTD__c, NAVYTD__c,
                                           NAV1Day__c, NAV1Month__c, NAV3Month__c, NAV1Year__c, NAV3Year__c, NAV5Year__c, NAV10Year__c, NAVInception__c,
                                           NAV1DayMonthEnd__c, NAV1DayQuarterEnd__c, NAV1DayYearEnd__c,
                                           NAV1MonthMonthEnd__c, NAV3MonthMonthEnd__c, NAV1YearMonthEnd__c, NAV3YearMonthEnd__c, NAV5YearMonthEnd__c, NAV10YearMonthEnd__c, NAVInceptionMonthEnd__c, NAVMTDMonthEnd__c, NAVQTDMonthEnd__c, NAVYTDMonthEnd__c,
                                           NAV1MonthQuarterEnd__c, NAV3MonthQuarterEnd__c, NAV1YearQuarterEnd__c, NAV3YearQuarterEnd__c, NAV5YearQuarterEnd__c, NAV10YearQuarterEnd__c, NAVInceptionQuarterEnd__c, NAVMTDQuarterEnd__c, NAVQTDQuarterEnd__c, NAVYTDQuarterEnd__c,
                                           NAV1MonthYearEnd__c, NAV3MonthYearEnd__c, NAV1YearYearEnd__c, NAV3YearYearEnd__c, NAV5YearYearEnd__c, NAV10YearYearEnd__c, NAVInceptionYearEnd__c, NAVMTDYearEnd__c, NAVQTDYearEnd__c,NAVYTDYearEnd__c,
                                           MSC__c, MSCChange__c, MSCPriorDay__c, MSCPercentChange__c, MSCMTD__c, MSCQTD__c, MSCYTD__c,
                                           MSC1Day__c, MSC1DayMonthEnd__c, MSC1DayQuarterEnd__c, MSC1DayYearEnd__c,
                                           MSC1Month__c, MSC3Month__c, MSC1Year__c, MSC3Year__c, MSC5Year__c, MSC10Year__c, MSCInception__c,
                                           MSC1MonthMonthEnd__c, MSC3MonthMonthEnd__c, MSC1YearMonthEnd__c, MSC3YearMonthEnd__c, MSC5YearMonthEnd__c, MSC10YearMonthEnd__c, MSCInceptionMonthEnd__c, MSCMTDMonthEnd__c, MSCQTDMonthEnd__c,MSCYTDMonthEnd__c,
                                           MSC1MonthQuarterEnd__c, MSC3MonthQuarterEnd__c, MSC1YearQuarterEnd__c, MSC3YearQuarterEnd__c, MSC5YearQuarterEnd__c, MSC10YearQuarterEnd__c, MSCInceptionQuarterEnd__c, MSCMTDQuarterEnd__c, MSCQTDQuarterEnd__c, MSCYTDQuarterEnd__c,
                                           MSC1MonthYearEnd__c, MSC3MonthYearEnd__c, MSC1YearYearEnd__c, MSC3YearYearEnd__c, MSC5YearYearEnd__c, MSC10YearYearEnd__c, MSCInceptionYearEnd__c, MSCMTDYearEnd__c, MSCQTDYearEnd__c, MSCYTDYearEnd__c,
                                           DistributionYield__c, X7DayYield__c, SEC30DaySubsidizedYield__c, SEC30DayUnsubsidizedYield__c, SECTaxEquivalentYield__c,
                                           Product__r.ThreadbackPerformanceShareClass__c, Product__r.ShareClassName__c, Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c, 
                                           MorningstarCategoryName__c, MorningstarRatingDate__c, MorningstarRatingOverallStars__c, MorningstarNumberOfFundsOverall__c, MorningstarRating3YearStars__c, MorningstarNumberOfFunds3Year__c,
                                           MorningstarRating5YearStars__c, MorningstarNumberOfFunds5Year__c, MorningstarRating10YearStars__c, MorningstarNumberOfFunds10Year__c,
                                           MorningstarAbsoluteRank1Month__c, MorningstarCategorySize1Month__c, MorningstarAbsoluteRank3Month__c, MorningstarCategorySize3Month__c, MorningstarAbsoluteRank6Month__c, MorningstarCategorySize6Month__c,
                                           MorningstarAbsoluteRank1Year__c, MorningstarCategorySize1Year__c, MorningstarAbsoluteRank3Year__c, MorningstarCategorySize3Year__c, MorningstarAbsoluteRank5Year__c, MorningstarCategorySize5Year__c,
                                           MorningstarAbsoluteRank10Year__c, MorningstarCategorySize10Year__c, MorningstarAbsoluteRankYTD__c, MorningstarCategorySizeYTD__c,
                                           MorningstarDailyRank1Day__c, MorningstarDailyCategorySize1Day__c, MorningstarDailyRank1Month__c, MorningstarDailyCategorySize1Month__c, MorningstarDailyRank3Month__c, MorningstarDailyCategorySize3Month__c, 
                                           MorningstarDailyRank6Month__c, MorningstarDailyCategorySize6Month__c, MorningstarDailyRank1Week__c, MorningstarDailyCategorySize1Week__c, MorningstarDailyRank1Year__c, MorningstarDailyCategorySize1Year__c, MorningstarDailyRank3Year__c, MorningstarDailyCategorySize3Year__c, 
                                           MorningstarDailyRank5Year__c, MorningstarDailyCategorySize5Year__c,
                                           MorningstarDailyRank10Year__c, MorningstarDailyCategorySize10Year__c, MorningstarDailyRankMTD__c, MorningstarDailyCategorySizeMTD__c, MorningstarDailyRankQTD__c, MorningstarDailyCategorySizeQTD__c, MorningstarDailyRankYTD__c, MorningstarDailyCategorySizeYTD__c,
                                           MorningstarRank1Month__c, MorningstarRank3Month__c, MorningstarRankYTD__c, MorningstarRank1Year__c, MorningstarRank3Year__c,
                                           MorningstarRank5Year__c, MorningstarRank10Year__c
                                           FROM ProductPerformance__c
                                           WHERE Product__c = :p
                                           AND AsOfDate__c = :d
                                           AND PublishInternally__c = TRUE
                                           LIMIT 1];
        
        if (!ppl.isEmpty()) {
            return ppl[0];
        }
        
        return null;
        
    }
    
    public static Boolean getDisplayMSC(ProductPerformance__c pp) {
        Boolean dMSC = FALSE;
        if(pp.ShareClass__c == 'A' || pp.ShareClass__c == 'C') dMSC = TRUE;
        return dMSC;
    }
    
    public static List<YieldItem> getYieldItemList(ProductPerformance__c pp) {
        
        List<YieldItem> yield = new List<YieldItem>();
        yield.add(new YieldItem('Yield',pp.DistributionYield__c, pp.X7DayYield__c, pp.SEC30DaySubsidizedYield__c, pp.SEC30DayUnsubsidizedYield__c, pp.SECTaxEquivalentYield__c));     
        
        return yield;
    }
    
    public static List<DailyPerformanceItem> getDailyPerformanceItemList(ProductPerformance__c pp) {
        
        Boolean displayMSC = getDisplayMSC(pp);
        
        List<DailyPerformanceItem> dailyPerf = new List<DailyPerformanceItem>();
        
        dailyPerf.add(new DailyPerformanceItem('NAV',pp.NAV__c, pp.NAVPriorDay__c, pp.NAVChange__c, pp.NAVPercentChange__c, pp.NAVMTD__c, pp.NAVQTD__c, pp.NAVYTD__c, pp.DistributionYield__c, pp.X7DayYield__c, pp.SEC30DaySubsidizedYield__c, pp.SEC30DayUnsubsidizedYield__c, pp.SECTaxEquivalentYield__c)); 
        if (displayMSC) dailyPerf.add(new DailyPerformanceItem('MSC',pp.MSC__c, pp.MSCPriorDay__c, pp.MSCChange__c, pp.MSCPercentChange__c, pp.MSCMTD__c, pp.MSCQTD__c, pp.MSCYTD__c, 0,0,0,0,0)); 
        
        return dailyPerf;
    }
    
    public static List<DailyPerformanceItemROR> getDailyPerformanceItemRORList(ProductPerformance__c pp) {
        
        Boolean displayMSC = getDisplayMSC(pp);
        
        List<DailyPerformanceItemROR> dailyPerfROR = new List<DailyPerformanceItemROR>();
        
        dailyPerfROR.add(new DailyPerformanceItemROR('NAV Daily', pp.AsOfDate__c, pp.Id, pp.NAVMTD__c, pp.NAVQTD__c, pp.NAVYTD__c, 
                                                     pp.NAV1Day__c, pp.NAV1Month__c,pp.NAV3Month__c,
                                                     pp.NAV1Year__c, pp.NAV3Year__c, pp.NAV5Year__c, pp.NAV10Year__c, pp.NAVInception__c));
        if (displayMSC) dailyPerfROR.add(new DailyPerformanceItemROR('MSC Daily', pp.AsOfDate__c, pp.Id, pp.MSCMTD__c, pp.MSCQTD__c, pp.MSCYTD__c,
                                                                     pp.MSC1Day__c, pp.MSC1Month__c,pp.MSC3Month__c,
                                                                     pp.MSC1Year__c, pp.MSC3Year__c, pp.MSC5Year__c, pp.MSC10Year__c, pp.MSCInception__c));
        dailyPerfROR.add(new DailyPerformanceItemROR('NAV Prior Month End', pp.PriorMonthEndDate__c, pp.PriorMonthEndProductPerformance__c, 
                                                     pp.NAVMTDMonthEnd__c, pp.NAVQTDMonthEnd__c,pp.NAVYTDMonthEnd__c,
                                                     pp.NAV1DayMonthEnd__c, pp.NAV1MonthMonthEnd__c,pp.NAV3MonthMonthEnd__c,
                                                     pp.NAV1YearMonthEnd__c, pp.NAV3YearMonthEnd__c, pp.NAV5YearMonthEnd__c, pp.NAV10YearMonthEnd__c, pp.NAVInceptionMonthEnd__c));        
        if (displayMSC)  dailyPerfROR.add(new DailyPerformanceItemROR('MSC Prior Month End', pp.PriorMonthEndDate__c, pp.PriorMonthEndProductPerformance__c, 
                                                                      pp.MSCMTDMonthEnd__c, pp.MSCQTDMonthEnd__c,pp.MSCYTDMonthEnd__c,
                                                                      pp.MSC1DayMonthEnd__c, pp.MSC1MonthMonthEnd__c,pp.MSC3MonthMonthEnd__c,
                                                                      pp.MSC1YearMonthEnd__c, pp.MSC3YearMonthEnd__c, pp.MSC5YearMonthEnd__c, pp.MSC10YearMonthEnd__c, pp.MSCInceptionMonthEnd__c));        
        dailyPerfROR.add(new DailyPerformanceItemROR('NAV Prior Quarter End', pp.PriorQuarterEndDate__c, pp.PriorQuarterEndProductPerformance__c, 
                                                     pp.NAVMTDQuarterEnd__c, pp.NAVQTDQuarterEnd__c,pp.NAVYTDQuarterEnd__c,
                                                     pp.NAV1DayQuarterEnd__c, pp.NAV1MonthQuarterEnd__c,pp.NAV3MonthQuarterEnd__c,
                                                     pp.NAV1YearQuarterEnd__c, pp.NAV3YearQuarterEnd__c, pp.NAV5YearQuarterEnd__c, pp.NAV10YearQuarterEnd__c, pp.NAVInceptionQuarterEnd__c));        
        if (displayMSC) dailyPerfROR.add(new DailyPerformanceItemROR('MSC Prior Quarter End', pp.PriorQuarterEndDate__c, pp.PriorQuarterEndProductPerformance__c, 
                                                                     pp.MSCMTDQuarterEnd__c, pp.MSCQTDQuarterEnd__c,pp.MSCYTDQuarterEnd__c,
                                                                     pp.MSC1DayQuarterEnd__c, pp.MSC1MonthQuarterEnd__c,pp.MSC3MonthQuarterEnd__c,
                                                                     pp.MSC1YearQuarterEnd__c, pp.MSC3YearQuarterEnd__c, pp.MSC5YearQuarterEnd__c, pp.MSC10YearQuarterEnd__c, pp.MSCInceptionQuarterEnd__c));        
        dailyPerfROR.add(new DailyPerformanceItemROR('NAV Prior Year End', pp.PriorYearEndDate__c, pp.PriorYearEndProductPerformance__c, 
                                                     pp.NAVMTDYearEnd__c, pp.NAVQTDYearEnd__c,pp.NAVYTDYearEnd__c,
                                                     pp.NAV1DayYearEnd__c, pp.NAV1MonthYearEnd__c,pp.NAV3MonthYearEnd__c,
                                                     pp.NAV1YearYearEnd__c, pp.NAV3YearYearEnd__c, pp.NAV5YearYearEnd__c, pp.NAV10YearYearEnd__c, pp.NAVInceptionYearEnd__c));        
        if (displayMSC) dailyPerfROR.add(new DailyPerformanceItemROR('MSC Prior Year End', pp.PriorYearEndDate__c, pp.PriorYearEndProductPerformance__c, 
                                                                     pp.MSCMTDYearEnd__c, pp.MSCQTDYearEnd__c,pp.MSCYTDYearEnd__c,
                                                                     pp.MSC1DayYearEnd__c, pp.MSC1MonthYearEnd__c,pp.MSC3MonthYearEnd__c,
                                                                     pp.MSC1YearYearEnd__c, pp.MSC3YearYearEnd__c, pp.MSC5YearYearEnd__c, pp.MSC10YearYearEnd__c, pp.MSCInceptionYearEnd__c));  
        
        return dailyPerfROR;
        
    }
    
    public static List<AnnualPerformanceItem> getAnnualPerformanceItemList(ProductPerformance__c pp) {
        
        Boolean displayMSC = getDisplayMSC(pp);
        
        List<AnnualPerformanceItem> annualPerf = new List<AnnualPerformanceItem>();
        
        String aY0 = pp.AsOfDate__c.addYears(-10).year().format().remove(',');
        String aY1 = pp.AsOfDate__c.addYears(-9).year().format().remove(',');
        String aY2 = pp.AsOfDate__c.addYears(-8).year().format().remove(',');
        String aY3 = pp.AsOfDate__c.addYears(-7).year().format().remove(',');
        String aY4 = pp.AsOfDate__c.addYears(-6).year().format().remove(',');
        String aY5 = pp.AsOfDate__c.addYears(-5).year().format().remove(',');
        String aY6 = pp.AsOfDate__c.addYears(-4).year().format().remove(',');
        String aY7 = pp.AsOfDate__c.addYears(-3).year().format().remove(',');
        String aY8 = pp.AsOfDate__c.addYears(-2).year().format().remove(',');
        String aY9 = pp.AsOfDate__c.addYears(-1).year().format().remove(',');
        
        Map<String,AnnualPerformanceItem> apiMap = new Map<String,AnnualPerformanceItem>();
        
        apiMap.put('NAV', new AnnualPerformanceItem('NAV',null,null,null,null,null,null,null,null,null,null));
        apiMap.put('MSC', new AnnualPerformanceItem('MSC',null,null,null,null,null,null,null,null,null,null));
        
        for (ProductPerformance__c app : [SELECT AsOfDate__c, NAVYTD__c, MSCYTD__c  
                                          FROM ProductPerformance__c
                                          WHERE Product__c = :pp.Product__c
                                          AND IsYearEnd__c = TRUE
                                          AND AsOfDate__c < :pp.AsOfDate__c
                                          ORDER BY AsOfDate__c DESC
                                          LIMIT 10]) {
                                              
                                              Decimal navA = app.NAVYTD__c;
                                              Decimal mscA = app.MSCYTD__c;
                                              String aoy = app.AsOfDate__c.year().format().remove(',');   
                                              
                                              AnnualPerformanceItem n = apiMap.get('NAV');
                                              AnnualPerformanceItem m = apiMap.get('MSC');
                                              AnnualPerformanceItem newN = new AnnualPerformanceItem('NAV',null,null,null,null,null,null,null,null,null,null);
                                              AnnualPerformanceItem newM = new AnnualPerformanceItem('MSC',null,null,null,null,null,null,null,null,null,null);
                                              
                                              if (aoy == aY0) {
                                                  newN = new AnnualPerformanceItem('NAV',navA,n.Y1,n.Y2,n.Y3,n.Y4,n.Y5,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',mscA,m.Y1,m.Y2,m.Y3,m.Y4,m.Y5,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              
                                              if (aoy == aY1) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,navA,n.Y2,n.Y3,n.Y4,n.Y5,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,mscA,m.Y2,m.Y3,m.Y4,m.Y5,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              
                                              if (aoy == aY2) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,navA,n.Y3,n.Y4,n.Y5,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,mscA,m.Y3,m.Y4,m.Y5,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              
                                              if (aoy == aY3) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,navA,n.Y4,n.Y5,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,mscA,m.Y4,m.Y5,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              if (aoy == aY4) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,navA,n.Y5,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,m.Y3,mscA,m.Y5,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              if (aoy == aY5) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,n.Y4,navA,n.Y6,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,m.Y3,m.Y4,mscA,m.Y6,m.Y7,m.Y8,m.Y9);
                                              }
                                              if (aoy == aY6) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,n.Y4,n.Y5,navA,n.Y7,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,m.Y3,m.Y4,m.Y5,mscA,m.Y7,m.Y8,m.Y9);
                                              }
                                              if (aoy == aY7) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,n.Y4,n.Y5,n.Y6,navA,n.Y8,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,m.Y3,m.Y4,m.Y5,m.Y6,mscA,m.Y8,m.Y9);
                                              }
                                              if (aoy == aY8) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,n.Y4,n.Y5,n.Y6,n.Y7,navA,n.Y9);
                                                  newM = new AnnualPerformanceItem('MSC',m.Y0,m.Y1,m.Y2,m.Y3,m.Y4,m.Y5,m.Y6,m.Y7,mscA,m.Y9);
                                              }
                                              if (aoy == aY9) {
                                                  newN = new AnnualPerformanceItem('NAV',n.Y0,n.Y1,n.Y2,n.Y3,n.Y4,n.Y5,n.Y6,n.Y7,n.Y8,navA);
                                                  newM = new AnnualPerformanceItem('MSC',n.Y0,m.Y1,m.Y2,m.Y3,m.Y4,m.Y5,m.Y6,m.Y7,m.Y8,mscA);
                                              }
                                              
                                              apiMap.put('NAV',newN);
                                              apiMap.put('MSC',newM);
                                          }
        if (!displayMSC) apiMap.remove('MSC');
        annualPerf = apiMap.values();
        return annualPerf;
    }
    
    public static Map<String,String> getMiscStrings(ProductPerformance__c pp) {
        
        Map<String,String> miscStrings = new Map<String,String>();
        
        miscStrings.put('prodPerfId', pp.Id);
        
        miscStrings.put('aY0', pp.AsOfDate__c.addYears(-10).year().format().remove(','));
        miscStrings.put('aY1', pp.AsOfDate__c.addYears(-9).year().format().remove(','));
        miscStrings.put('aY2', pp.AsOfDate__c.addYears(-8).year().format().remove(','));
        miscStrings.put('aY3', pp.AsOfDate__c.addYears(-7).year().format().remove(','));
        miscStrings.put('aY4', pp.AsOfDate__c.addYears(-6).year().format().remove(','));
        miscStrings.put('aY5', pp.AsOfDate__c.addYears(-5).year().format().remove(','));
        miscStrings.put('aY6', pp.AsOfDate__c.addYears(-4).year().format().remove(','));
        miscStrings.put('aY7', pp.AsOfDate__c.addYears(-3).year().format().remove(','));
        miscStrings.put('aY8', pp.AsOfDate__c.addYears(-2).year().format().remove(','));
        miscStrings.put('aY9', pp.AsOfDate__c.addYears(-1).year().format().remove(','));
        
        miscStrings.put('asOfDateDisp', pp.AsOfDate__c.format());
        miscStrings.put('prevDateDisp', pp.PriorBusinessDate__c.format());
        miscStrings.put('inceptionDt', pp.InceptionDate__c.format());
        
        return miscStrings;
        
    }

    public static List<MSRatingsItem> getMSRatingsItemList(ProductPerformance__c pp) {
        List<MSRatingsItem> msrating = new List<MSRatingsItem>();
        String MSRatingDate;
        
        if (pp.MorningstarRatingDate__c == null) {
            MSRatingDate = 'N/A';
        } else {
            MSRatingDate = pp.MorningstarRatingDate__c.format();
        }
        
        msrating.add(new MSRatingsItem('Month End',pp.MorningstarCategoryName__c, 
                                       pp.MorningstarRatingOverallStars__c, 
                                       pp.MorningstarRating3YearStars__c, 
                                       pp.MorningstarRating5YearStars__c, 
                                       pp.MorningstarRating10YearStars__c,
                                       pp.MorningstarNumberOfFundsOverall__c, 
                                       pp.MorningstarNumberOfFunds3Year__c, 
                                       pp.MorningstarNumberOfFunds5Year__c, 
                                       pp.MorningstarNumberOfFunds10Year__c,
                                       MSRatingDate)); 
        return msrating;
    }
    
    public static List<MSRankingsItem> getMSRankingsItemList (ProductPerformance__c pp) {
        List<MSRankingsItem> msranking = new List<MSRankingsItem>();
        
        msranking.add(new MSRankingsItem('Daily',pp.MorningstarCategoryName__c, pp.MorningstarDailyRank1Day__c, pp.MorningstarDailyRank1Week__c,
                                         pp.MorningstarDailyRank1Month__c, pp.MorningstarDailyRank3Month__c, pp.MorningstarDailyRankMTD__c, pp.MorningstarDailyRankQTD__c, 
                                         pp.MorningstarDailyRankYTD__c, pp.MorningstarDailyRank1Year__c, pp.MorningstarDailyRank3Year__c,
                                         pp.MorningstarDailyRank5Year__c, pp.MorningstarDailyRank10Year__c, 
                                         pp.MorningstarCategorySize1Month__c, pp.MorningstarCategorySize3Month__c, pp.MorningstarCategorySizeYTD__c, pp.MorningstarCategorySize1Year__c, pp.MorningstarCategorySize3Year__c,
                                         pp.MorningstarCategorySize5Year__c, pp.MorningstarCategorySize10Year__c, 
                                         pp.MorningstarAbsoluteRank1Month__c, pp.MorningstarAbsoluteRank3Month__c, pp.MorningstarAbsoluteRankYTD__c, pp.MorningstarAbsoluteRank1Year__c, pp.MorningstarAbsoluteRank3Year__c,
                                         pp.MorningstarAbsoluteRank5Year__c, pp.MorningstarAbsoluteRank10Year__c, 
                                         pp.AsOfDate__c));
        msranking.add(new MSRankingsItem('Monthly',pp.MorningstarCategoryName__c, 0, 0, 
                                         pp.MorningstarRank1Month__c, pp.MorningstarRank3Month__c, 0, 0, pp.MorningstarRankYTD__c, pp.MorningstarRank1Year__c, pp.MorningstarRank3Year__c,
                                         pp.MorningstarRank5Year__c, pp.MorningstarRank10Year__c, 
                                         pp.MorningstarCategorySize1Month__c, pp.MorningstarCategorySize3Month__c, pp.MorningstarCategorySizeYTD__c, pp.MorningstarCategorySize1Year__c, pp.MorningstarCategorySize3Year__c,
                                         pp.MorningstarCategorySize5Year__c, pp.MorningstarCategorySize10Year__c, 
                                         pp.MorningstarAbsoluteRank1Month__c, pp.MorningstarAbsoluteRank3Month__c, pp.MorningstarAbsoluteRankYTD__c, pp.MorningstarAbsoluteRank1Year__c, pp.MorningstarAbsoluteRank3Year__c,
                                         pp.MorningstarAbsoluteRank5Year__c, pp.MorningstarAbsoluteRank10Year__c, 
                                         pp.MorningstarRatingDate__c));
        
        return msranking;
    }
    
    public static List<ProductPerformance__c> getChildProductPerformance(Product2 p, Date a) {
        
        List<ProductPerformance__c> cpp = [SELECT Id, AsOfDate__c, Product__c, Product__r.Name, Product__r.ShareClassName__c, Product__r.CUSIPFormatted__c, Product__r.TradingSymbol__c,
                                           TotalNetAssets__c, SharesOutstanding__c, IsAsOfDateBusinessDate__c, 
                                           NAV1Day__c, NAV__c, MSC__c, NAVPercentChange__c, NAVMTD__c, NAVQTD__c, NAVYTD__c, 
                                           NAV1Year__c, NAV3Year__c, NAV5Year__c, NAV10Year__C, NAVInception__c, Product__r.FundNumber__c, InceptionDate__c,
                                           Product__r.ThreadbackPerformanceShareClass__r.ShareClassName__c
                                           FROM ProductPerformance__c 
                                           WHERE Product__r.ParentProduct__c = :p.Id AND AsOfDate__c = :a ORDER BY Product__r.Name];
        
        return cpp;
        
    }
    
    public static String getThreadbackPerformanceFootnote(String scName, String threadbackSCName, Date inceptionDate, Date ppDate) {
        
        String threadbackPerfFN = '';
        
        if (threadbackSCName != null && threadbackSCName != ''
                    && ppDate.addYears(-10) < inceptionDate) {                    
                    threadbackPerfFN = 'Prior to the inception of ' + scName + ' (' + inceptionDate.format() + '), performance is that of ' + 
                        threadbackSCName + '.';
                }
        
        return threadbackPerfFN;
    }
    
}