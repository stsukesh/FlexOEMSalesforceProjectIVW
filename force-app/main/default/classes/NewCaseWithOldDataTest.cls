/**
 * Author : Sukesh Subash
 * Date : 26/12/2025
 * Description : This is the test class that is used to test the class with postive, negative and userBasedTesting.
 */
@isTest
private class NewCaseWithOldDataTest {
    /**
     * Description : This is used to create the postive testing for this class.
     */
    @isTest
    static void testNewCasesPostive(){
       // Setup: Create 5 existing cases
        TestObjectFactory.getCaseRecords('Closed', 5);

        Test.startTest();
        NewCaseWithOldData.createNewCasesFromExisting();
        Test.stopTest();

        List<Case> totalCases = [SELECT Id FROM Case];
        // Result should be 5 (original) + 5 (newly created)
        System.assertEquals(10, totalCases.size(), 'Total cases should be 10');
    }
    /**
     * Description : This is used to create the Negative testing for this class.
     */
    @isTest
    static void testNewCasesNegative(){
        
        
       
        Test.startTest();
        NewCaseWithOldData.createNewCasesFromExisting();
        Test.stopTest();

        List<Case> resultList = [SELECT Id FROM Case];
        
        // Assert: The list size should NOT be 5
        System.assertNotEquals(5, resultList.size(), 'System should not have created cases when source data was missing');
        System.assertEquals(0, resultList.size(), 'List should be empty');
        
        
    }
     /**
     * Description : This is used to create the USER based testing for this class.
     */
    @isTest
    static void testNewCasesUser(){
        User StandardUser = TestObjectFactory.createStandardUser();
        TestObjectFactory.getCaseRecords('New',2);
        
        System.runAs(StandardUser){
            Test.startTest();
            NewCaseWithOldData.createNewCasesFromExisting();
            Test.stopTest();
        }
        
        List<Case> toatlCases = [SELECT Id FROM Case];
        System.assertEquals(4,toatlCases.size());
        
        
    }

}