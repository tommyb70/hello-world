@isTest
public class ProductCharApprovalControllerTest {
    
    static testMethod void myTest() {
        
        CDRSettings__c settings = new CDRSettings__c(Name = 'NGAM', 
                                                     BusinessHoursName__c = '24 Hours, Monday - Friday GMT');
        insert settings;
        
        Id MFRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Mutual Fund').getRecordTypeId();
        List<Product2> mfp = DataFactory.createProduct2(2,'MF_');
        
        mfp[0].RecordTypeId = MFRecTypeId;
        mfp[0].LegalName__c = 'Mutual Fund Legal Name';
        mfp[1].RecordTypeId = MFRecTypeId;
        mfp[1].LegalName__c = '';
        insert mfp;
        
        List<ProductCharacteristic__c> prodChar = new List<ProductCharacteristic__c>();
        Date AsOfDate = Date.newInstance(2018,04,30);
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id, Approved__c = FALSE, Source__c = 'State Street Top 10 Holdings File'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id, Approved__c = TRUE, Source__c = 'State Street Top 10 Holdings File'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[1].Id, Approved__c = FALSE, Source__c = 'State Street Top 10 Holdings File'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Characteristics', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id, Approved__c = FALSE, Source__c = 'State Street Top 10 Holdings File'));
        prodChar.add(new ProductCharacteristic__c(Type__c = 'Top ten holdings', AsOfDate__c = AsOfDate, Product__c = mfp[0].Id, Approved__c = FALSE, Source__c = 'IPM ASG Characteristics File'));
        insert prodChar;
        
        Test.startTest();                       

        Test.setCurrentPage(Page.ProductCharacteristicApproval);
        List<ProductCharacteristic__c> selectedProdCharList = new List<ProductCharacteristic__c>();

        ProductCharApprovalController c = new ProductCharApprovalController();
        c.go();
        c.choiceProduct = prodChar[0].Product__c;
		c.selections();
        c.choiceType = prodChar[0].Type__c;
        c.selections();
        c.choiceSource = prodChar[0].Source__c;
        c.selections();
        c.go();
        c.wrapProdCharList[0].selected = TRUE;
        selectedProdCharList.add(c.wrapProdCharList[0].pc);
        c.approveSelected();
        
        Test.stopTest();		        

        List<ProductCharacteristic__c> testCheck = [SELECT Id, Approved__c
                                                    FROM ProductCharacteristic__c];

        for (ProductCharacteristic__c tc : testCheck) {
            if (tc.Id == prodChar[0].Id) system.assertEquals(TRUE, tc.Approved__c, 'Newly Approved Product Characteristic');
            if (tc.Id == prodChar[1].Id) system.assertEquals(TRUE, tc.Approved__c, 'Still Approved Product Characteristic');
            if (tc.Id == prodChar[2].Id) system.assertEquals(FALSE, tc.Approved__c, 'Still Not Approved Product Characteristic');
            if (tc.Id == prodChar[3].Id) system.assertEquals(FALSE, tc.Approved__c, 'Still Not Approved Product Characteristic');
            if (tc.Id == prodChar[3].Id) system.assertEquals(FALSE, tc.Approved__c, 'Still Not Approved Product Characteristic');
        }
        
    }    
    

}