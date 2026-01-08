public with sharing class TopicController {

    /* =========================
       READ TOPICS
       ========================= */
    @AuraEnabled(cacheable=true)
    public static String getTopicField(Id recordId) {

        String objectName =
            recordId.getSObjectType().getDescribe().getName();

        List<Topic_Config__mdt> cfgList = [
            SELECT Enable_Topics__c, Topic_Field_API__c
            FROM Topic_Config__mdt
            WHERE DeveloperName = :objectName
            LIMIT 1
        ];

        if (cfgList.isEmpty() || !cfgList[0].Enable_Topics__c) {
            return null;
        }

        Topic_Config__mdt cfg = cfgList[0];

        SObject rec = Database.query(
            'SELECT ' + cfg.Topic_Field_API__c +
            ' FROM ' + objectName +
            ' WHERE Id = :recordId'
        );

        return (String) rec.get(cfg.Topic_Field_API__c);
    }

    /* =========================
       ADD TOPIC
       ========================= */
    @AuraEnabled
    public static void saveTopics(Id recordId, String topicInput) {

        if (String.isBlank(topicInput)) {
            throw new AuraHandledException('Topic cannot be empty');
        }

        String objectName =
            recordId.getSObjectType().getDescribe().getName();

        List<Topic_Config__mdt> cfgList = [
            SELECT Enable_Topics__c, Topic_Field_API__c
            FROM Topic_Config__mdt
            WHERE DeveloperName = :objectName
            LIMIT 1
        ];

        if (cfgList.isEmpty() || !cfgList[0].Enable_Topics__c) {
            throw new AuraHandledException('Topics are disabled');
        }

        Topic_Config__mdt cfg = cfgList[0];

        String normalized = topicInput.trim().toLowerCase();

        // Get or create Topic
        Topic topicRec;
        List<Topic> existing = [
            SELECT Id
            FROM Topic
            WHERE Name = :normalized
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            topicRec = new Topic(Name = normalized);
            insert topicRec;
        } else {
            topicRec = existing[0];
        }

        // Prevent duplicate assignment
        Integer cnt = [
            SELECT COUNT()
            FROM TopicAssignment
            WHERE EntityId = :recordId
            AND TopicId = :topicRec.Id
        ];

        if (cnt > 0) {
            throw new AuraHandledException('Topic already exists');
        }

        insert new TopicAssignment(
            EntityId = recordId,
            TopicId  = topicRec.Id
        );

        updateTopicText(recordId, cfg.Topic_Field_API__c);
    }

    /* =========================
       REMOVE TOPIC
       ========================= */
    @AuraEnabled
    public static void removeTopic(Id recordId, String topicName) {

        delete [
            SELECT Id
            FROM TopicAssignment
            WHERE EntityId = :recordId
            AND Topic.Name = :topicName
        ];

        String objectName =
            recordId.getSObjectType().getDescribe().getName();

        List<Topic_Config__mdt> cfgList = [
            SELECT Topic_Field_API__c
            FROM Topic_Config__mdt
            WHERE DeveloperName = :objectName
            LIMIT 1
        ];

        if (!cfgList.isEmpty()) {
            updateTopicText(recordId, cfgList[0].Topic_Field_API__c);
        }
    }

    /* =========================
       UPDATE LONG TEXT AREA
       ========================= */
    private static void updateTopicText(
        Id recordId,
        String fieldApi
    ) {
        List<TopicAssignment> tas = [
            SELECT Topic.Name
            FROM TopicAssignment
            WHERE EntityId = :recordId
            ORDER BY CreatedDate
        ];

        List<String> names = new List<String>();
        for (TopicAssignment ta : tas) {
            names.add(ta.Topic.Name);
        }

        SObject rec =
            recordId.getSObjectType().newSObject(recordId);

        rec.put(fieldApi, String.join(names, '; '));
        update rec;
    }
}