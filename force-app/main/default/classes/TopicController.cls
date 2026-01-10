/**
 * @name: TopicController
 * @author: Sukesh Subash
 * @date: 09/01/2026
 * @description: Controller class for LWC to manage Topic Assignments and 
 * synchronize topic names to a custom text field on records.
 * @test class: TopicControllerTest
 */
public with sharing class TopicController {
    private static final String TOPICS_TEXT_FIELD = 'Topics_Text__c';

    /**
     * @name: getTopicData
     * @description: Retrieves the concatenated topic text and total count for a specific record
     * @param recordId - The ID of the record to fetch topic data for
     * @return TopicWrapper - Wrapper containing the topic text and total count
     */
    @AuraEnabled(cacheable=true)
    public static TopicWrapper getTopicData(Id recordId) {
        if (recordId == null) return null;

        String objectName = recordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT ' + String.escapeSingleQuotes(TOPICS_TEXT_FIELD) + 
                       ' FROM ' + String.escapeSingleQuotes(objectName) + 
                       ' WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1';
        
        List<SObject> records = Database.query(query);
        String textValue = records.isEmpty() ? '' : (String)records[0].get(TOPICS_TEXT_FIELD);
        Integer count = [SELECT COUNT() FROM TopicAssignment WHERE EntityId = :recordId];

        return new TopicWrapper(textValue, count);
    }

    /**
     * @name: saveTopics
     * @description: Creates a new Topic if it doesn't exist and assigns it to the record
     * @param recordId - The ID of the record to associate the topic with
     * @param topicInput - The name of the topic to save
     */
    @AuraEnabled
    public static void saveTopics(Id recordId, String topicInput) {
        String normalized = topicInput.trim();
        Topic topicRec;
        List<Topic> existing = [SELECT Id FROM Topic WHERE Name = :normalized LIMIT 1];

        if (existing.isEmpty()) {
            topicRec = new Topic(Name = normalized);
            insert topicRec;
        } else {
            topicRec = existing[0];
        }

        Integer cnt = [SELECT COUNT() FROM TopicAssignment WHERE EntityId = :recordId AND TopicId = :topicRec.Id];
        if (cnt == 0) {
            insert new TopicAssignment(EntityId = recordId, TopicId = topicRec.Id);
        }
        updateTopicText(recordId);
    }

    /**
     * @name: removeTopic
     * @description: Deletes a TopicAssignment based on the record ID and topic name
     * @param recordId - The ID of the record to remove the topic from
     * @param topicName - The name of the topic to remove
     */
    @AuraEnabled
    public static void removeTopic(Id recordId, String topicName) {
        delete [SELECT Id FROM TopicAssignment WHERE EntityId = :recordId AND Topic.Name = :topicName];
        updateTopicText(recordId);
    }

    /**
     * @name: updateTopicText
     * @description: Private helper to sync all related Topic names into a semi-colon delimited field
     * @param recordId - The ID of the record to update
     */
    private static void updateTopicText(Id recordId) {
        List<TopicAssignment> tas = [SELECT Topic.Name FROM TopicAssignment WHERE EntityId = :recordId ORDER BY CreatedDate ASC];
        List<String> names = new List<String>();
        for (TopicAssignment ta : tas) {
            names.add(ta.Topic.Name);
        }

        SObject rec = recordId.getSObjectType().newSObject(recordId);
        rec.put(TOPICS_TEXT_FIELD, String.join(names, '; '));
        update rec;
    }

    /**
     * @name: searchGlobalTopics
     * @description: Searches for existing global Topics based on a search string
     * @param searchTerm - The string to search for in Topic names
     * @return List<String> - List of matching topic names
     */
    @AuraEnabled(cacheable=true)
    public static List<String> searchGlobalTopics(String searchTerm) {
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) return new List<String>();
        String queryTerm = '%' + searchTerm.trim() + '%';
        List<String> results = new List<String>();
        for (Topic t : [SELECT Name FROM Topic WHERE Name LIKE :queryTerm LIMIT 5]) {
            results.add(t.Name);
        }
        return results;
    }

    /**
     * @name: TopicWrapper
     * @description: Wrapper class to hold Topic-related data for LWC consumption
     */
    public class TopicWrapper {
        @AuraEnabled public String topicText { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        
        /**
         * @name: TopicWrapper (Constructor)
         * @description: Initializes the wrapper with text and count
         * @param text - The concatenated topic text
         * @param count - The total count of topics
         */
        public TopicWrapper(String text, Integer count) {
            this.topicText = text;
            this.totalCount = count;
        }
    }
}