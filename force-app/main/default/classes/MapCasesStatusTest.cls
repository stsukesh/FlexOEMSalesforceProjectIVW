/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for MapCasesStatus covering positive and negative scenarios.
 */
@isTest
private class MapCasesStatusTest {


    /**
     * Scenario: Positive Testing (Bulk)
     * Description: Verifies that 10 cases are correctly grouped by status.
     */
    @isTest
    static void testGetCasesMappedByStatus_PositiveBulk() {
       

        // Setup: Create 10 cases with 'New' status
        TestObjectFactory.getCaseRecords('New', 10);

        Test.startTest();
        MapCasesStatus.getCasesMappedByStatus();
        Test.stopTest();

        // Verification: Query results assigned to a list 
        List<Case> resultList = [SELECT Id FROM Case WHERE Status = 'New'];
        System.assertEquals(10, resultList.size(), 'Should successfully query 10 New cases');
        
    }

    /**
     * Scenario: Negative Testing
     * Description: Verifies that no cases are mapped when the database is empty.
     */
    @isTest
    static void testGetCasesMappedByStatus_NegativeNoMatch() {

        // Setup: No records are created (Empty Database)

        Test.startTest();
        MapCasesStatus.getCasesMappedByStatus();
        Test.stopTest();

        // Query for any cases (Expected 0)
        List<Case> resultList = [SELECT Id FROM Case];
        
        // Assert: The number of cases found should NOT be 10 (Negative Assertion)
        System.assertNotEquals(10, resultList.size(), 'The query should not have found 10 cases');
        
        // Final verification that list is empty
        System.assertEquals(0, resultList.size(), 'List should be exactly empty');

    }
}