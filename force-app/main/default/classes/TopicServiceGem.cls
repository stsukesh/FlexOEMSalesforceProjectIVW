public with sharing class TopicServiceGem {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAssignedTopics(Id recordId) {
        List<Map<String, String>> topicList = new List<Map<String, String>>();
        for (TopicAssignment ta : [SELECT Topic.Id, Topic.Name FROM TopicAssignment WHERE EntityId = :recordId WITH SECURITY_ENFORCED]) {
            topicList.add(new Map<String, String>{'label' => ta.Topic.Name, 'name' => ta.Topic.Id});
        }
        return topicList;
    }

    @AuraEnabled
    public static void createTopicAssignment(Id recordId, String topicName) {
        if (String.isBlank(topicName)) return;
        String trimmedName = topicName.trim();
        List<Topic> existing = [SELECT Id FROM Topic WHERE Name = :trimmedName LIMIT 1];
        
        Id targetId;
        if (existing.isEmpty()) {
            Topic t = new Topic(Name = trimmedName);
            insert t;
            targetId = t.Id;
        } else {
            targetId = existing[0].Id;
        }

        if ([SELECT Count() FROM TopicAssignment WHERE EntityId = :recordId AND TopicId = :targetId] == 0) {
            insert new TopicAssignment(EntityId = recordId, TopicId = targetId);
            updateTopicSummary(recordId);
        }
    }

    @AuraEnabled
    public static void removeTopicAssignment(Id recordId, String topicId) {
        delete [SELECT Id FROM TopicAssignment WHERE EntityId = :recordId AND TopicId = :topicId LIMIT 1];
        updateTopicSummary(recordId);
    }

    private static void updateTopicSummary(Id recordId) {
        List<String> names = new List<String>();
        for (TopicAssignment ta : [SELECT Topic.Name FROM TopicAssignment WHERE EntityId = :recordId]) {
            names.add(ta.Topic.Name);
        }
        
        SObject record = recordId.getSObjectType().newSObject(recordId);
        record.put('Topics__c', String.join(names, ' : '));
        
        // Fix for "fields being inaccessible" error
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{record});
        update decision.getRecords();
    }
}