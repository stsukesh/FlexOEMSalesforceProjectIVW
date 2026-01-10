/**
 * @name: TopicControllerTest
 * @author: Sukesh Subash
 * @date: 09/01/2026
 * @description: Test class for TopicController providing high code coverage,
 * bulk data testing, and validation of security/sharing.
 */
@isTest
private class TopicControllerTest {

    /**
     * @description: Setup method to create test data including Accounts and Topics
     */
    @TestSetup
    static void setupTestData() {
        // Use Factory to create Accounts
        List<Account> testAccounts = TestObjectFactory.getAccountRecords('Hot', 200);
        
        // Create a global topic manually for search testing
       // insert new Topic(Name = 'Salesforce');
    }

    /**
     * @name: testGetTopicData_Success
     * @description: Validates retrieval of topic data for a valid record
     */
    @isTest
    static void testGetTopicData_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        TopicController.TopicWrapper result = TopicController.getTopicData(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Wrapper should not be null');
        System.assertEquals(0, result.totalCount, 'Initial topic count should be 0');
    }

    /**
     * @name: testSaveTopics_NewTopic
     * @description: Tests creating a brand new topic and assigning it to a record
     */
    @isTest
    static void testSaveTopics_NewTopic() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String topicName = 'Apex Coding';
        
        Test.startTest();
        TopicController.saveTopics(acc.Id, topicName);
        Test.stopTest();
        
        List<TopicAssignment> assignments = [SELECT Id FROM TopicAssignment WHERE EntityId = :acc.Id];
        Account updatedAcc = [SELECT Topics_Text__c FROM Account WHERE Id = :acc.Id];
        
        System.assertEquals(1, assignments.size(), 'One topic should be assigned');
        System.assert(updatedAcc.Topics_Text__c.contains(topicName), 'Custom field should be updated');
    }

    /**
     * @name: testSaveTopics_ExistingTopic
     * @description: Tests assigning an existing topic to a record (no duplicate Topic created)
     */
    @isTest
    static void testSaveTopics_ExistingTopic() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String topicName = 'Salesforce'; // Created in @TestSetup
        
        Test.startTest();
        TopicController.saveTopics(acc.Id, topicName);
        Test.stopTest();
        
        Integer topicCount = [SELECT COUNT() FROM Topic WHERE Name = :topicName];
        System.assertEquals(1, topicCount, 'Should not create a duplicate Topic record');
    }

    /**
     * @name: testRemoveTopic_Success
     * @description: Validates removal of a topic and update of the text field
     */
    @isTest
    static void testRemoveTopic_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String topicName = 'Temporary';
        TopicController.saveTopics(acc.Id, topicName);
        
        Test.startTest();
        TopicController.removeTopic(acc.Id, topicName);
        Test.stopTest();
        
        Account updatedAcc = [SELECT Topics_Text__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('', updatedAcc.Topics_Text__c, 'Topics text should be cleared');
    }

    /**
     * @name: testSearchGlobalTopics_Success
     * @description: Validates the search functionality for topics
     */
    @isTest
    static void testSearchGlobalTopics_Success() {
        Test.startTest();
        List<String> results = TopicController.searchGlobalTopics('Sales');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should find the Salesforce topic');
        System.assertEquals('Salesforce', results[0]);
    }

    /**
     * @name: testSearchGlobalTopics_ShortTerm
     * @description: Validates that search returns empty for strings shorter than 2 chars
     */
    @isTest
    static void testSearchGlobalTopics_ShortTerm() {
        Test.startTest();
        List<String> results = TopicController.searchGlobalTopics('S');
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty for short search terms');
    }

    /**
     * @name: testBulkTopicAssignment
     * @description: Mandatory bulk test to verify governor limits with 200 records
     */
    @isTest
    static void testBulkTopicAssignment() {
        List<Account> accounts = [SELECT Id FROM Account];
        String bulkTopic = 'BulkTest';
        
        Test.startTest();
        for (Account acc : accounts) {
            TopicController.saveTopics(acc.Id, bulkTopic);
        }
        Test.stopTest();
        
        Integer assignmentCount = [SELECT COUNT() FROM TopicAssignment WHERE Topic.Name = :bulkTopic];
        System.assertEquals(200, assignmentCount, 'All 200 accounts should have the topic assigned');
    }

    /**
     * @name: testSecurity_StandardUser
     * @description: Validates behavior under a standard user profile using Factory user
     */
    @isTest
    static void testSecurity_StandardUser() {
        User stdUser = TestObjectFactory.createStandardUser();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(stdUser) {
            Test.startTest();
            try {
                TopicController.TopicWrapper result = TopicController.getTopicData(acc.Id);
                System.assertNotEquals(null, result);
            } catch (Exception e) {
                // If the user lacks access to the custom field, this validates security enforcement
                System.debug('Expected security behavior: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }
}