/**
*  Class name  :   SL_CloneListView_test
*  Created by  :   Alex Zhurylo
*  Created on  :   8/01/2019
*  Description :   test class for SL_CloneListView
**/
@isTest
public class SL_CloneListView_test {

    @isTest
    public static void cloneListView_test() {
        Test.startTest();
            Group testGroup = new Group();
                testGroup.Name = 'Test Group';
            insert testGroup;

            SL_CloneListView.cloneListView(testGroup.Id, '00B5C000001dCA3UAM');
        Test.stopTest();
    }

}