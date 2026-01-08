/**
 * Author: Sukesh Subash
 * Date: 30/12/2025
 * Description: Test class for Case Queueables using TestObjectFactory.
 */
@isTest
private with sharing class UpdateCaseStatusTest {

    @isTest
    static void testCaseEscalationChaining() {
        // Use Factory to create Accounts/Contacts
        List<Account> accs = TestObjectFactory.createAccounts(1, true);
        List<Contact> cons = TestObjectFactory.createContacts(accs, 1);
        
        Case c = new Case(
            Subject = 'Escalation Test',
            ContactId = cons[0].Id,
            Status = 'New'
        );
        Database.insert(c, AccessLevel.USER_MODE);

        Test.startTest();
        System.enqueueJob(new UpdateCaseStatus(new Set<Id>{c.Id}));
        Test.stopTest();

        Case updatedCase = [SELECT Status FROM Case WHERE Id = :c.Id WITH USER_MODE LIMIT 1];
        System.assertEquals('Escalated', updatedCase.Status, 'Status should be Escalated');
    }
}