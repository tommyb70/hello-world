@isTest
public class ProductCharacteristicTriggerHandlerTest {
    
    static testMethod void SetPublishScheduleAndDate() {
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     BusinessHoursName__c = '24 Hours, Monday - Friday GMT');
        insert settings;
        
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        List<Product2> mfp = DataFactory.createProduct2(7,'MF_');
        
        mfp[0].RecordTypeId = MFRecTypeId;
        mfp[0].Top10HoldingsPublishingSchedule__c = 'Never';
        
        mfp[1].RecordTypeId = MFRecTypeId;
        mfp[1].Top10HoldingsPublishingSchedule__c = 'Immediately';
        
        mfp[2].RecordTypeId = MFRecTypeId;
        mfp[2].Top10HoldingsPublishingSchedule__c = '7th Business Day';
        
        mfp[3].RecordTypeId = MFRecTypeId;
        mfp[3].Top10HoldingsPublishingSchedule__c = '8th Calendar Day';
        
        mfp[4].RecordTypeId = MFRecTypeId;
        mfp[4].Top10HoldingsPublishingSchedule__c = '1st Business Day After the Following Month-End';
        
        mfp[5].RecordTypeId = MFRecTypeId;
        mfp[5].Top10HoldingsPublishingSchedule__c = '10th Business Day After Quarter-End';
        
        insert mfp;
        
        List<ProductCharacteristic__c> prodChar = new List<ProductCharacteristic__c>();
        Date AsOfDate = Date.newInstance(2018,04,30);
        Date AsOfDateFirstIsNotBusiness = Date.newInstance(2018,05,31);
        Date AsOfDateQ1 = Date.newInstance(2018,01,31);
        Date AsOfDateQ2 = Date.newInstance(2018,05,31);
        Date AsOfDateQ3 = Date.newInstance(2018,08,30);        
        Date AsOfDateQ4 = Date.newInstance(2018,10,31);        
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[1].Id));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[2].Id));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[3].Id));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[4].Id, SecurityName__c = '1st is Business'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDateFirstIsNotBusiness, Product__c = mfp[4].Id, SecurityName__c = '1st is not Business'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[5].Id));        
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDateQ1, Product__c = mfp[5].Id, SecurityName__c = 'Q1'));       
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDateQ2, Product__c = mfp[5].Id, SecurityName__c = 'Q2'));       
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDateQ3, Product__c = mfp[5].Id, SecurityName__c = 'Q3'));       
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDateQ4, Product__c = mfp[5].Id, SecurityName__c = 'Q4'));       
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Foo', AsOfDate__c = AsOfDate, Product__c = mfp[5].Id, SecurityName__c = 'Not Top ten holdings'));       

        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id,CharacteristicsDataType__c='Integer',ProductCharacteristicsInteger__c=433,IndexCharacteristicsInteger__c=200));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id,CharacteristicsDataType__c='Decimal',ProductCharacteristicsDecimal__c=4.2,IndexCharacteristicsDecimal__c=4));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id,CharacteristicsDataType__c='Text',ProductCharacteristicsText__c='ABC',IndexCharacteristicsText__c='DEF'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, PublishDate__c = date.today(), Approved__c = TRUE, Product__c = mfp[0].Id,CharacteristicsDataType__c='Text',ProductCharacteristicsText__c='ABC',IndexCharacteristicsText__c='DEF'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, PublishDate__c = date.today(), Approved__c = FALSE, Product__c = mfp[0].Id,CharacteristicsDataType__c='Text',ProductCharacteristicsText__c='ABC',IndexCharacteristicsText__c='DEF'));        
        
        Test.startTest();
        insert prodChar;
        prodChar[15].Approved__c = TRUE;
        update prodChar;
        Test.stopTest();		        
        
        List<ProductCharacteristic__c> testCheck = [SELECT Id, Type__c,
                                                    Product__r.Top10HoldingsPublishingSchedule__c,
                                                    PublishingSchedule__c, 
                                                    PublishDate__c, 
                                                    SecurityName__c,
                                                    CharacteristicsDataType__c,
                                                    ProductCharacteristicsOutputText__c,
                                                    IndexCharacteristicsOutputText__c FROM ProductCharacteristic__c
                                                    WHERE Id in :prodChar];
        
        for (ProductCharacteristic__c tc : testCheck) {
            if (tc.Type__c == 'Top ten holdings') {
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == 'Never') {
                    system.assertEquals('Never', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - Never'); 
                    system.assertEquals(null, tc.PublishDate__c, 'Top 10 Holdings Publish Date - Never'); 
                }
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == 'Immediately') {
                    system.assertEquals('Immediately', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - Immediately'); 
                    system.assertEquals(AsOfDate, tc.PublishDate__c, 'Top 10 Holdings Publish Date - Never'); 
                } 
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == '7th Business Day') {
                    system.assertEquals('7th Business Day', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - 7th Business Day'); 
                    system.assertEquals(Date.newInstance(2018,05,09), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 7th Business Day'); 
                }
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == '8th Calendar Day') {
                    system.assertEquals('8th Calendar Day', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - 8th Calendar Day'); 
                    system.assertEquals(Date.newInstance(2018,05,08), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 8th Calendar Day'); 
                }
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == '1st Business Day After the Following Month-End') {
                    system.assertEquals('1st Business Day After the Following Month-End', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - 1st Business Day After the Following Month-End'); 
                    if (tc.SecurityName__c == '1st is not Business') system.assertEquals(Date.newInstance(2018,07,02), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 1st Business Day After the Following Month-End - First Not Business'); 
                    if (tc.SecurityName__c == '1st is Business') system.assertEquals(Date.newInstance(2018,06,01), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 1st Business Day After the Following Month-End'); 
                }
                if (tc.Product__r.Top10HoldingsPublishingSchedule__c == '10th Business Day After Quarter-End') {
                    system.assertEquals('10th Business Day After Quarter-End', tc.PublishingSchedule__c, 'Top 10 Holdings Publishing Schedule - 10th Business Day After Quarter-End'); 
                    if (String.isBlank(tc.SecurityName__c)) system.assertEquals(Date.newInstance(2018,07,16), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 10th Business Day After Quarter-End'); 
                    if (tc.SecurityName__c == 'Q1') system.assertEquals(Date.newInstance(2018,04,13), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 10th Business Day After Quarter-End');                 
                    if (tc.SecurityName__c == 'Q2') system.assertEquals(Date.newInstance(2018,07,16), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 10th Business Day After Quarter-End'); 
                    if (tc.SecurityName__c == 'Q3') system.assertEquals(Date.newInstance(2018,10,12), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 10th Business Day After Quarter-End'); 
                    if (tc.SecurityName__c == 'Q4') system.assertEquals(Date.newInstance(2019,01,15), tc.PublishDate__c, 'Top 10 Holdings Publish Date - 10th Business Day After Quarter-End'); 
                }
            }
            if (tc.Type__c == 'Foo') {
                system.assertEquals(Date.newInstance(2018,04,30), tc.PublishDate__c, 'Characteristics - Immediately'); 
            }

            if (tc.Type__c == 'Characteristics' && tc.CharacteristicsDataType__c == 'Integer') {
                system.assertEquals('433', tc.ProductCharacteristicsOutputText__c, 'Characteristics - Integer Product Output Text'); 
                system.assertEquals('200', tc.IndexCharacteristicsOutputText__c, 'Characteristics - Integer Index Output Text');                 
            }
            
            if (tc.Type__c == 'Characteristics' && tc.CharacteristicsDataType__c == 'Decimal') {
                system.assertEquals('4.20', tc.ProductCharacteristicsOutputText__c, 'Characteristics - Decimal Product Output Text'); 
                system.assertEquals('4.00', tc.IndexCharacteristicsOutputText__c, 'Characteristics - Decimal Index Output Text');                 
            }
            
            if (tc.Type__c == 'Characteristics' && tc.CharacteristicsDataType__c == 'Text') {
                system.assertEquals('ABC', tc.ProductCharacteristicsOutputText__c, 'Characteristics - Text Product Output Text'); 
                system.assertEquals('DEF', tc.IndexCharacteristicsOutputText__c, 'Characteristics - Text Index Output Text');                 
            }
            
        }        
    }        
}