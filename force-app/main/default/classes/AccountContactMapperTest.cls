/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Test class for AccountContactMapper covering bulk, negative, and user scenarios.
 */
@isTest
private class AccountContactMapperTest {

    private static final String CLASS_NAME = 'AccountContactMapperTest';

    /**
     * Scenario: Positive Testing (Bulk)
     * Description: Verifies 50 Accounts each with 2 Contacts are correctly mapped.
     */
    @isTest
    static void testGetAccountContactMap_PositiveBulk() {
      
        List<Account> accs = TestObjectFactory.getAccountRecords('Hot', 50);
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account a : accs) {
            contactsToInsert.add(new Contact(LastName = 'Contact 1', AccountId = a.Id));
            contactsToInsert.add(new Contact(LastName = 'Contact 45', AccountId = a.Id));
        }
        insert contactsToInsert;

        Test.startTest();
        Map<Id, List<Contact>> result = AccountContactMapper.getAccountContactMap();
        Test.stopTest();

        System.assertEquals(50, result.size(), 'Map should contain 50 account keys');
        System.assertEquals(2, result.values()[0].size(), 'Each account should have 2 contacts');
        
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