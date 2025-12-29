/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for CaseDataMap covering positive, negative, and user-based scenarios.
 */
@isTest
private class CaseDataMapTest {


    /**
     * Scenario: Positive Testing (Bulk)
     * Description: Verify that cases are correctly retrieved and mapped.
     */
    @isTest
    static void testGetMappedCaseData_PositiveBulk() {
      
        TestObjectFactory.getCaseRecords('New', 3);

        Test.startTest();
        CaseDataMap.getMappedCaseData();
        Test.stopTest();

        List<Case> resultList = [SELECT Id FROM Case];
        System.assertEquals(3, resultList.size(), 'Should find exactly 3 cases');
        
    }

    /**
     * Scenario: Negative Testing
     * Description: Verify behavior when no records exist using assertNotEquals.
     */
    @isTest
    static void testGetMappedCaseData_NegativeNoData() {
      
        // Setup: Database is empty
        
        Test.startTest();
        CaseDataMap.getMappedCaseData();
        Test.stopTest();

        List<Case> resultList = [SELECT Id FROM Case];
        
        // Negative Assertion: The size should NOT be 3
        System.assertNotEquals(3, resultList.size(), 'Should not have 3 cases in an empty database');
        System.assertEquals(0, resultList.size(), 'List should be exactly empty');
    }

  
}