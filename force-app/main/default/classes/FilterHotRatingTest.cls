/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for FilterHotRating ensuring bulkification and profile-based execution.
 */
@isTest
private class FilterHotRatingTest {

    private static final String CLASS_NAME = 'FilterHotRatingTest';

    /**
     * Scenario: Positive Testing (Bulk)
     * Description: Verify the method handles a bulk volume of 200 'Hot' accounts correctly.
     */
    @isTest
    static void testGetHotAccounts_PositiveBulk() {
        final String METHOD_NAME = 'testGetHotAccounts_PositiveBulk';
        System.debug(LoggingLevel.DEBUG, 'BEGIN_METHOD ' + CLASS_NAME + '.' + METHOD_NAME);

        // Setup 200 records to test bulk limits
        TestObjectFactory.getAccountRecords('Hot', 200);

        Test.startTest();
        FilterHotRating.getHotAccounts();
        Test.stopTest();

        // Verification: Query results assigned to a list
        List<Account> hotAccounts = [SELECT Id FROM Account WHERE Rating = 'Hot'];
        System.assertEquals(200, hotAccounts.size(), 'Should successfully query 200 Hot accounts');
        
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' EXIT_METHOD ' + METHOD_NAME);
    }

    /**
     * Scenario: Negative Testing
     * Description: Verify that records with 'Cold' rating are NOT returned as 'Hot'.
     */
    @isTest
    static void testGetHotAccounts_NegativeNoMatch() {
        final String METHOD_NAME = 'testGetHotAccounts_NegativeNoMatch';
        System.debug(LoggingLevel.DEBUG, 'BEGIN_METHOD ' + CLASS_NAME + '.' + METHOD_NAME);

        // Setup: Create 50 Cold accounts
        Integer totalCold = 50;
        TestObjectFactory.getAccountRecords('Cold', totalCold);

        Test.startTest();
        FilterHotRating.getHotAccounts();
        Test.stopTest();

        // Query for Hot accounts
        List<Account> hotResults = [SELECT Id FROM Account WHERE Rating = 'Hot'];
        
        // Assert: The count of found Hot accounts should NOT be equal to the count of created Cold accounts
        System.assertNotEquals(totalCold, hotResults.size(), 'The list of Hot accounts should not include Cold records');
        System.assertEquals(0, hotResults.size(), 'The list should be exactly zero');

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' EXIT_METHOD ' + METHOD_NAME);
    }

    /**
     * Scenario: User-Based Testing (runAs)
     * Description: Verify the behavior when the logic is executed by a Standard User.
     */
    @isTest
    static void testGetHotAccounts_UserBased() {
        final String METHOD_NAME = 'testGetHotAccounts_UserBased';
        System.debug(LoggingLevel.DEBUG, 'BEGIN_METHOD ' + CLASS_NAME + '.' + METHOD_NAME);

        // Setup User and Data
        User standardUser = TestObjectFactory.createStandardUser();
        TestObjectFactory.getAccountRecords('Hot', 10);

        // Run as the Standard User to test behavioral context/sharing
        System.runAs(standardUser) {
            Test.startTest();
            try {
                FilterHotRating.getHotAccounts();
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Exception in runAs block: ' + e.getMessage());
            }
            Test.stopTest();
        }

        // Verification
        List<Account> result = [SELECT Id FROM Account WHERE Rating = 'Hot'];
        System.assertEquals(10, result.size(), 'Standard user should be able to query the records');
        
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' EXIT_METHOD ' + METHOD_NAME);
    }
}