public with sharing class TopicController {
    private static final String TOPICS_TEXT_FIELD = 'Topics_Text__c';

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

    @AuraEnabled
    public static void removeTopic(Id recordId, String topicName) {
        delete [SELECT Id FROM TopicAssignment WHERE EntityId = :recordId AND Topic.Name = :topicName];
        updateTopicText(recordId);
    }

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

    public class TopicWrapper {
        @AuraEnabled public String topicText { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        public TopicWrapper(String text, Integer count) {
            this.topicText = text;
            this.totalCount = count;
        }
    }
}