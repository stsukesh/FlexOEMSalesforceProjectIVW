/**
 * @name: TopicServiceTestCaseInsensitiveTest
 * @author: Sukesh Subash
 * @date: 06/01/2026
 * @description: Additional test class to verify case-insensitive topic creation behavior.
 * This test verifies that "Sukesh" and "sukesh" are treated as the same topic.
 */
@isTest
public class TopicServiceTestCaseInsensitiveTest {
    
    @isTest
    static void testSukeshAndSukeshAreSameTopic() {
        // Setup - Create topic with uppercase name
        String upperCaseName = 'Sukesh';
        String lowerCaseName = 'sukesh';
        
        // Create first topic
        TopicDTO.TopicItem result1 = TopicService.createTopicEnforcingCaseInsensitive(upperCaseName);
        
        // Verify the topic was created
        System.assertNotEquals(null, result1, 'Should return created topic');
        System.assertEquals(upperCaseName, result1.name, 'Name should match original case');
        
        // Try to create topic with different case - should fail with duplicate error
        Test.startTest();
        try {
            TopicService.createTopicEnforcingCaseInsensitive(lowerCaseName);
            System.assert(false, 'Should have thrown exception for duplicate case-insensitive topic');
        } catch (AuraHandledException e) {
            System.assertEquals(upperCaseName + ' already exists', e.getMessage(), 'Should return correct error message');
        }
        Test.stopTest();
        
        // Verify only one topic exists in the system
        List<Topic> topics = [SELECT Id, Name FROM Topic WHERE Name = :upperCaseName OR Name = :lowerCaseName];
        System.assertEquals(1, topics.size(), 'Should only have one topic despite different cases');
        
        // Verify the topic name is stored with original case (uppercase in this case)
        System.assertEquals(upperCaseName, topics[0].Name, 'Topic should be stored with original case');
    }
}