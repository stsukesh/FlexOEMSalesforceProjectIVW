/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for AccountContactMapper covering bulk, negative, and user scenarios.
 */
@isTest
private class AccountContactMapperTest {

    @isTest
static void testGetAccountContactMap_PositiveBulk() {
    // 1. Setup data (Triggers will fire here)
    List<Account> accs = TestObjectFactory.getAccountRecords('Hot', 50);
    List<Contact> contactsToInsert = new List<Contact>();
    for (Account a : accs) {
        contactsToInsert.add(new Contact(LastName = 'Contact 1', AccountId = a.Id));
    }
    
    // If the error happens HERE, the issue is strictly in your Trigger/Handler logic
    insert contactsToInsert; 

    // 2. Execute the actual code being tested
    Test.startTest();
    Map<Id, List<Contact>> result = AccountContactMapper.getAccountContactMap();
    Test.stopTest();

    // 3. Assert
    System.assertEquals(50, result.size(), 'Map should contain 50 account keys');
}

    /**
     * Scenario: Negative Testing
     * Description: Verifies map behavior when no records exist.
     */
    @isTest
    static void testGetAccountContactMap_NegativeNoData() {
        
        // No setup - database is empty

        Test.startTest();
        Map<Id, List<Contact>> result = AccountContactMapper.getAccountContactMap();
        Test.stopTest();

        System.assertNotEquals(50, result.size(), 'Should not have records in map');
        System.assertEquals(0, result.size(), 'Map should be exactly empty');
    }

  
}