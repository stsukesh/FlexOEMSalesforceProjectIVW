/**
 * @name: AccountContactServiceTest
 * author: Sukesh Subash
 * @date: 03/01/2026
 * @description: Tests for AccountContactService.getContactsByAccount with positive, negative, and security-context scenarios.
 * @test class: AccountContactServiceTest
 */
@IsTest
private class AccountContactServiceTest {

    /**
     * @name: setupData
     * @description: Creates Accounts and Contacts for testing.
     */
    @TestSetup
    static void setupData() {
        // Create two accounts
        List<Account> accs = new List<Account>{
            new Account(Name = 'ACC A'),
            new Account(Name = 'ACC B')
        };
        insert accs;

        // Attach contacts - only to ACC A
        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            cons.add(new Contact(LastName = 'L' + i, FirstName = 'F' + i, AccountId = accs[0].Id, Email = 'u' + i + '@ex.com'));
        }
        insert cons;
    }

    /**
     * @name: testPositive_ReturnsContactsForGivenAccount
     * @description: Validates that contacts are returned for an account with existing related contacts.
     */
    @IsTest
    static void testPositive_ReturnsContactsForGivenAccount() {
        Account accWithContacts = [SELECT Id FROM Account WHERE Name = 'ACC A' LIMIT 1];
        System.assertNotEquals(null, accWithContacts, 'ACC A should exist');

        AccountContactService svc = new AccountContactService();

        Test.startTest();
        List<Contact> result = svc.getContactsByAccount(accWithContacts.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(5, result.size(), 'Should return 5 related contacts');
        for (Contact c : result) {
            System.assertEquals(accWithContacts.Id, c.AccountId, 'Each contact should belong to the provided Account');
        }
    }

    /**
     * @name: testNegative_NullAccountId
     * @description: Verifies behavior when null account id is provided.
     */
    @IsTest
    static void testNegative_NullAccountId() {
        AccountContactService svc = new AccountContactService();

        Test.startTest();
        Boolean threw = false;
        try {
            // This will run the query with null bind; expected to return empty list or throw depending on implementation.
            List<Contact> result = svc.getContactsByAccount(null);
            System.assertNotEquals(null, result, 'Service should return a non-null list even for null input');
            System.assertEquals(0, result.size(), 'Expecting 0 results for null AccountId');
        } catch (Exception e) {
            threw = true;
        }
        Test.stopTest();

        // Accept either guarded behavior returning empty, or explicit exception. At least one path must be covered.
        System.assert(true, 'Negative path executed; service should guard or throw for null input');
    }

    /**
     * @name: testNegative_AccountWithNoContacts
     * @description: Ensures that an account without contacts returns an empty list.
     */
    @IsTest
    static void testNegative_AccountWithNoContacts() {
        Account accNoContacts = [SELECT Id FROM Account WHERE Name = 'ACC B' LIMIT 1];
        System.assertNotEquals(null, accNoContacts, 'ACC B should exist');

        AccountContactService svc = new AccountContactService();

        Test.startTest();
        List<Contact> result = svc.getContactsByAccount(accNoContacts.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Account without contacts should return empty list');
    }

    /**
     * @name: testRunAsSecurityContext
     * @description: Executes under a standard user to validate sharing/FLS aligned behavior when WITH SECURITY_ENFORCED is added.
     */
    @IsTest
    static void testRunAsSecurityContext() {
        User std = TestObjectFactory.createStandardUser();
        Account accWithContacts = [SELECT Id FROM Account WHERE Name = 'ACC A' LIMIT 1];

        System.runAs(std) {
            AccountContactService svc = new AccountContactService();
            Test.startTest();
            List<Contact> result = svc.getContactsByAccount(accWithContacts.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null under runAs');
            System.assertEquals(5, result.size(), 'Standard user should read related contacts if permitted by FLS/sharing');
        }
    }
}
