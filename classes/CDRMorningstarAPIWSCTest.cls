@isTest
private class CDRMorningstarAPIWSCTest {
    
    @testSetup static void testCDRMorningstarAPIWSCSetup () {
        
        CDRSettings__c CDRSetting = new CDRSettings__c();
        CDRSetting.Name='NGAM';
        CDRSetting.MorningstarCreateAccessCodeURL__c = 'https://api.morningstar.com/v2/service/account/CreateAccesscode/1d';
        CDRSetting.MorningstarUniverseCode__c = 'f7z0f5lts94d5amb';
        // this must match what is in the static resource CDRMorningstarAPIResponseAC:
        String MSACTest = 'bdkoeh17jvcqx8iuimd2998scymthob5'; 
        CDRSetting.MorningstarDailyRatingsAndRankingsURL__c = 'https://api.morningstar.com/v2/service/mf/jsqitupp9ilr2tey/universeid/' +
            CDRSetting.MorningstarUniverseCode__c + ' ?accesscode=' + MSACTest;
        CDRSetting.MorningstarCreateAccessCodeBody__c = 'Foo';
        CDRSetting.UseThisStaticResourceForMSXML__c = null;
        insert CDRSetting; 
        
        List<Product2> products = DataFactory.createProduct2(2,'Test');
        products[0].MorningstarId__c = 'FAKEMS0001';
        products[1].MorningstarId__c = 'FAKEMS0002';
        insert products;        
    }
    
    
    @isTest static void testCDRMorningstarAPIWSC() {
        
        CDRSettings__c CDRSettings = CDRSettings__c.getValues('NGAM');
        String MSCreateAccessCodeBody = CDRSettings.MorningstarCreateAccessCodeBody__c;
        String MSCreateAccessCodeURL = CDRSettings.MorningstarCreateAccessCodeURL__c;
        String MSUniverseCode = CDRSettings.MorningstarUniverseCode__c;
        String MSDailyRatingsAndRankingsURL = CDRSettings.MorningstarDailyRatingsAndRankingsURL__c;
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(MSCreateAccessCodeURL, 'CDRMorningstarAPIResponseAC');
        multimock.setStaticResource(MSDailyRatingsAndRankingsURL, 'CDRMorningstarAPIResponseDailyRatingsAndRankings');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        MultiStaticResourceCalloutMock multimockDay2 = new MultiStaticResourceCalloutMock();
        multimockDay2.setStaticResource(MSCreateAccessCodeURL, 'CDRMorningstarAPIResponseAC');
        multimockDay2.setStaticResource(MSDailyRatingsAndRankingsURL, 'CDRMorningstarAPIResponseDailyRatingsAndRankingsDay2');
        multimockDay2.setStatusCode(200);
        multimockDay2.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        CDRMorningstarAPIWSC.callMorningstarCDR();
        Test.setMock(HttpCalloutMock.class, multimockDay2);        
        CDRMorningstarAPIWSC.callMorningstarCDR();
        Test.stoptest();
        
    }

    @isTest static void testCDRMorningstarXMLWSC() {
        
        CDRSettings__c CDRSettings = CDRSettings__c.getValues('NGAM');
        String MSCreateAccessCodeBody = CDRSettings.MorningstarCreateAccessCodeBody__c;
        String MSCreateAccessCodeURL = CDRSettings.MorningstarCreateAccessCodeURL__c;
        String MSUniverseCode = CDRSettings.MorningstarUniverseCode__c;
        String MSDailyRatingsAndRankingsURL = CDRSettings.MorningstarDailyRatingsAndRankingsURL__c;
        CDRSettings.UseThisStaticResourceForMSXML__c = 'CDRMorningstarAPIResponseDailyRatingsAndRankingsDay2';
        update CDRSettings;

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(MSCreateAccessCodeURL, 'CDRMorningstarAPIResponseAC');
        multimock.setStaticResource(MSDailyRatingsAndRankingsURL, 'CDRMorningstarAPIResponseDailyRatingsAndRankings');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        MultiStaticResourceCalloutMock multimockDay2 = new MultiStaticResourceCalloutMock();
        multimockDay2.setStaticResource(MSCreateAccessCodeURL, 'CDRMorningstarAPIResponseAC');
        multimockDay2.setStaticResource(MSDailyRatingsAndRankingsURL, 'CDRMorningstarAPIResponseDailyRatingsAndRankingsDay2');
        multimockDay2.setStatusCode(200);
        multimockDay2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        CDRMorningstarAPIWSC.callMorningstarCDR();
        Test.setMock(HttpCalloutMock.class, multimockDay2);        
        CDRMorningstarAPIWSC.callMorningstarCDR();
        Test.stoptest();
        
    }    
    
}