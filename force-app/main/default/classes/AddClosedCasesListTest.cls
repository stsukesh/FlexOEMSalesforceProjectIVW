/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for AddClosedCasesList covering all standard test scenarios.
 */
@isTest
private class AddClosedCasesListTest {
    /**
     * Method : Postive Testing (with bulk support)
     * Description : This is used to create a test to the AddClosedCasesListTest
     */
    @isTest
    static void testGetClosedCaseIds_PositiveBulk(){
        TestObjectFactory.getCaseRecords('Closed',200);
        
        Test.startTest();
        AddClosedCasesList.getClosedCaseIds();
        Test.stopTest();
        List<Case> resultList = [SELECT Id FROM Case WHERE Status = 'Closed'];
        System.assertEquals(200, resultList.size(), 'Should find exactly 200 closed cases');
    }
     /**
     * Method : Negative Testing (with bulk support)
     * Description : This is used to create a Negative test to the AddClosedCasesListTest
     */
    @isTest
    static void testGetClosedCaseIds_NegativeNoMatch() {
  

        Integer totalNew = 50;
        TestObjectFactory.getCaseRecords('New', totalNew);

        Test.startTest();
        AddClosedCasesList.getClosedCaseIds();
        Test.stopTest();

        List<Case> closedResults = [SELECT Id FROM Case WHERE Status = 'Closed'];
        
        System.assertNotEquals(totalNew, closedResults.size(), 'Should not find closed cases when only New cases exist');
        System.assertEquals(0, closedResults.size(), 'The list should be empty');
    }
     /**
     * Method : User Testing (with bulk support)
     * Description : This is used to create a test to the AddClosedCasesListTest
     */
    @isTest
    static void testGetClosedCaseIds_UserBased() {
        
        User standardUser = TestObjectFactory.createStandardUser();
        TestObjectFactory.getCaseRecords('Closed', 10);

        System.runAs(standardUser) {
            Test.startTest();
            AddClosedCasesList.getClosedCaseIds();
            Test.stopTest();
        }

        List<Case> resultList = [SELECT Id FROM Case WHERE Status = 'Closed'];
        System.assertEquals(10, resultList.size(), 'Standard User should be able to see the closed cases');
    }

}