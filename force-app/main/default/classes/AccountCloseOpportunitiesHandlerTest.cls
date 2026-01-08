/**
 * @name: AccountCloseOpportunitiesHandlerTest
 * @author: Sukesh Subash
 * @date: 03/01/2026
 * @description: Tests for AccountCloseOpportunitiesHandler covering positive, negative, and bulk scenarios.
 * @test class: AccountCloseOpportunitiesHandlerTest
 */
@IsTest
private class AccountCloseOpportunitiesHandlerTest {

    /**
     * @name: setupData
     * @description: Creates common data for tests using minimal valid graph
     */
    @TestSetup
    static void setupData() {
        // Create 3 Accounts
        List<Account> accts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accts.add(new Account(Name = 'ACC ' + i));
        }
        insert accts;

        // For each account, create opportunities across probability and stage combinations
        List<Opportunity> opps = new List<Opportunity>();
        for (Account a : accts) {
            // Should update: Prob > 90 and not Closed Won
            opps.add(new Opportunity(
                Name = 'HighProb Open ' + a.Name,
                AccountId = a.Id,
                StageName = 'Prospecting',
                CloseDate = System.today(),
                Probability = 95
            ));
            // Should NOT update: already Closed Won
            opps.add(new Opportunity(
                Name = 'HighProb Closed ' + a.Name,
                AccountId = a.Id,
                StageName = 'Closed Won',
                CloseDate = System.today(),
                Probability = 98
            ));
            // Should NOT update: Prob <= 90
            opps.add(new Opportunity(
                Name = 'LowProb Open ' + a.Name,
                AccountId = a.Id,
                StageName = 'Prospecting',
                CloseDate = System.today(),
                Probability = 50
            ));
        }
        insert opps;
    }

    /**
     * @name: testPositive_CloseHighProbabilityOpps
     * @description: Verifies that only opportunities with Probability > 90 and not already Closed Won are updated.
     */
    @IsTest
    static void testPositive_CloseHighProbabilityOpps() {
        List<Account> accts = [SELECT Id FROM Account LIMIT 3];
        System.assertEquals(3, accts.size(), 'Expected 3 accounts from setup');

        Test.startTest();
        AccountCloseOpportunitiesHandler.closeRelatedOpportunities(accts);
        Test.stopTest();

        // Fetch all opportunities to validate
        List<Opportunity> allOpps = [
            SELECT Id, StageName, Probability
            FROM Opportunity
            WHERE AccountId IN :accts
        ];

        Integer updated = 0;
        Integer alreadyClosed = 0;
        Integer lowProb = 0;

        for (Opportunity o : allOpps) {
            if (o.Probability > 90 && o.StageName == 'Closed Won') {
                updated++;
            } else if (o.StageName == 'Closed Won' && o.Probability > 90) {
                alreadyClosed++;
            } else if (o.Probability <= 90) {
                lowProb++;
            }
        }

        // Per account: 1 should update, 1 already closed-won remains closed, 1 low prob remains unchanged
        System.assertEquals(3, updated, 'Exactly one per account should be updated to Closed Won');
        System.assertEquals(3, alreadyClosed, 'Already Closed Won should remain as-is');
        System.assertEquals(3, lowProb, 'Low probability opportunities should remain unchanged');
    }

    /**
     * @name: testNegative_NullInput
     * @description: Validates graceful handling for null input (guarded/exception)
     */
    @IsTest
    static void testNegative_NullInput() {
        Test.startTest();
        Boolean threw = false;
        try {
            AccountCloseOpportunitiesHandler.closeRelatedOpportunities(null);
        } catch (Exception e) {
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Method should guard or throw for null input');
    }

    /**
     * @name: testNegative_EmptyInput
     * @description: Validates no-op behavior for empty input list
     */
    @IsTest
    static void testNegative_EmptyInput() {
        Test.startTest();
        try {
            AccountCloseOpportunitiesHandler.closeRelatedOpportunities(new List<Account>());
        } catch (Exception e) {
            System.assert(false, 'Empty input should not throw: ' + e.getMessage());
        }
        Test.stopTest();
        System.assert(true, 'Reached without errors for empty input');
    }

    /**
     * @name: testBulk_200Accounts
     * @description: Bulk scenario to ensure method performs within governor limits
     */
    @IsTest
    static void testBulk_200Accounts() {
        // Create 200 Accounts
        List<Account> bulkAccts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            bulkAccts.add(new Account(Name = 'Bulk ACC ' + i));
        }
        insert bulkAccts;

        // Create one qualifying opportunity and one non-qualifying per account
        List<Opportunity> bulkOpps = new List<Opportunity>();
        for (Account a : bulkAccts) {
            bulkOpps.add(new Opportunity(
                Name = 'Bulk HighProb Open ' + a.Name,
                AccountId = a.Id,
                StageName = 'Qualification',
                CloseDate = System.today(),
                Probability = 95
            ));
            bulkOpps.add(new Opportunity(
                Name = 'Bulk LowProb Open ' + a.Name,
                AccountId = a.Id,
                StageName = 'Qualification',
                CloseDate = System.today(),
                Probability = 25
            ));
        }
        insert bulkOpps;

        Test.startTest();
        AccountCloseOpportunitiesHandler.closeRelatedOpportunities(bulkAccts);
        Test.stopTest();

        // Assert that all high-probability opportunities are now Closed Won
        Integer highProbClosed = [
            SELECT COUNT()
            FROM Opportunity
            WHERE AccountId IN :bulkAccts
            AND Probability > 90
            AND StageName = 'Closed Won'
        ];
        System.assertEquals(200, highProbClosed, 'All high prob opportunities should be closed won in bulk');

        // Ensure low probability ones remain not Closed Won
        Integer lowProbCount = [
            SELECT COUNT()
            FROM Opportunity
            WHERE AccountId IN :bulkAccts
            AND Probability <= 90
            AND StageName != 'Closed Won'
        ];
        System.assertEquals(200, lowProbCount, 'All low probability opportunities should remain unclosed');
    }
}
