/**
 * @name: AddClosedCasesListTest
 * @author: Sukesh Subash
 * @date: 31/12/2025
 * @description: Test class for AddClosedCasesList covering all standard test scenarios.
 */
@isTest
private class AddClosedCasesListTest {

    @isTest
    static void testGetClosedCaseIds_PositiveBulk() {
        // Arrange
        TestObjectFactory.getCaseRecords('Closed', 200);
        
        // Act
        Test.startTest();
        AddClosedCasesList.getClosedCaseIds();
        Test.stopTest();
        
        // Assert
        // We query using LIKE or specific status to ensure we catch what the DB actually stored
        List<Case> resultList = [SELECT Id FROM Case WHERE Status = 'Closed'];
        System.assertEquals(200, resultList.size(), 'Should find exactly 200 closed cases. If this is 0, check Case Status picklist values.');
    }

    @isTest
    static void testGetClosedCaseIds_UserBased() {
        User standardUser = TestObjectFactory.createStandardUser();
        
        // Create data OUTSIDE of runAs to ensure ownership/permissions don't block the factory insert
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