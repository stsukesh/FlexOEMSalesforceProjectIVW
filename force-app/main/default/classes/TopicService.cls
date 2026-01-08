/**
 * @name: TopicService
 * @author: Sukesh Subash
 * @date: 06/01/2026
 * @description: Fixed version with @AuraEnabled and optimized DML logic.
 *               Now includes real-time event publishing for topic changes.
 */
public with sharing class TopicService {
    // Constants per org rules
    private enum ACTION { create, assign, remove }
    private static final String DEFAULT_DELIMITER = ' : ';

    @AuraEnabled(cacheable=true)
    public static List<TopicDTO.TopicItem> getRecordTopics(Id recordId) {
        List<TopicDTO.TopicItem> result = new List<TopicDTO.TopicItem>();
        // Fetch all assignments for this record
        Map<Id, TopicAssignment> taMap = new Map<Id, TopicAssignment>();
        for (TopicAssignment ta : [
            SELECT Id, TopicId, Topic.Name 
            FROM TopicAssignment 
            WHERE EntityId = :recordId 
            WITH SECURITY_ENFORCED
            ORDER BY Topic.Name ASC
        ]) {
            taMap.put(ta.TopicId, ta);
            TopicDTO.TopicItem item = new TopicDTO.TopicItem(ta.Topic.Id, ta.Topic.Name);
            // Check if the current user is following this topic
            item.isFollowed = isUserFollowingTopic(ta.TopicId);
            result.add(item);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTopicCount(Id recordId) {
        return [SELECT COUNT() FROM TopicAssignment WHERE EntityId = :recordId];
    }

    @AuraEnabled(cacheable=true)
    public static List<TopicDTO.TopicItem> searchTopics(String searchKey) {
        List<TopicDTO.TopicItem> result = new List<TopicDTO.TopicItem>();
        if (String.isBlank(searchKey)) return result;

        // Normalize search for permutation-like inputs by collapsing whitespace
        String normalized = normalizeForCompare(searchKey);
        String queryKey = '%' + normalized.replace('%', '\\%').replace('_', '\\_') + '%';

        for (Topic t : [
            SELECT Id, Name 
            FROM Topic 
            WHERE Name LIKE :queryKey 
            ORDER BY Name 
            LIMIT 20
        ]) {
            result.add(new TopicDTO.TopicItem(t.Id, t.Name));
        }
        return result;
    }

    @AuraEnabled
    public static TopicDTO.TopicItem createTopicEnforcingCaseInsensitive(String name) {
        if (String.isBlank(name)) throw new AuraHandledException('Name is required');

        // Canonicalize for display and compare
        String canonical = canonicalizeDisplayName(name);
        String cmp = normalizeForCompare(canonical);

        // Prevent duplicates and permutations (case-insensitive, collapse spaces)
        // Query candidates and compare normalized keys in Apex to catch permutations like "Su kesh"
        List<Topic> candidates = [
            SELECT Id, Name 
            FROM Topic 
            WHERE Name = :canonical 
               OR Name LIKE :('%' + canonical.replace('%','\\%').replace('_','\\_') + '%')
            WITH SECURITY_ENFORCED
            LIMIT 200
        ];
        for (Topic tExisting : candidates) {
            if (normalizeForCompare(tExisting.Name) == cmp) {
                throw new AuraHandledException('The topic "' + tExisting.Name + '" already exists.');
            }
        }

        Topic t = new Topic(Name = canonical);
        Database.SaveResult sr = Database.insert(t, AccessLevel.USER_MODE);
        if (!sr.isSuccess()) {
            throw new AuraHandledException('Failed to create topic');
        }

        publishEvent(null, t.Id, t.Name, ACTION.create);

        return new TopicDTO.TopicItem(t.Id, t.Name);
    }

    @AuraEnabled
    public static void assignTopicToRecord(Id topicId, Id recordId) {
        try {
            Database.insert(new TopicAssignment(TopicId = topicId, EntityId = recordId), AccessLevel.USER_MODE);

            Topic t = [SELECT Id, Name FROM Topic WHERE Id = :topicId WITH SECURITY_ENFORCED LIMIT 1];
            publishEvent(recordId, topicId, t.Name, ACTION.assign);

            // Update long text field if configured via default targets (created separately)
            upsertLongTextField(recordId, null);
        } catch (DmlException e) {
            throw new AuraHandledException('Topic already assigned or error occurred: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeTopicFromRecord(Id topicId, Id recordId) {
        List<TopicAssignment> tas = [SELECT Id FROM TopicAssignment WHERE TopicId = :topicId AND EntityId = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        if (tas.isEmpty()) return;
        Database.delete(tas, AccessLevel.USER_MODE);

        Topic t = [SELECT Id, Name FROM Topic WHERE Id = :topicId WITH SECURITY_ENFORCED LIMIT 1];
        publishEvent(recordId, topicId, t.Name, ACTION.remove);

        upsertLongTextField(recordId, null);
    }

    @AuraEnabled
    public static void upsertRecordTopicsFromDelimitedString(Id recordId, String topicsDelimited, String delimiter) {
        if (String.isBlank(recordId)) return;

        String delim = String.isBlank(delimiter) ? DEFAULT_DELIMITER : delimiter;

        // 1. Parse incoming names with canonicalization and compare normalization
        Map<String, String> compareToDisplay = new Map<String, String>(); // cmp -> display
        if (String.isNotBlank(topicsDelimited)) {
            for (String s : topicsDelimited.split(delim)) {
                if (String.isNotBlank(s)) {
                    String display = canonicalizeDisplayName(s);
                    String cmp = normalizeForCompare(display);
                    compareToDisplay.put(cmp, display);
                }
            }
        }
        Set<String> incomingCompare = compareToDisplay.keySet();

        // 2. Existing assignments for this record
        Map<String, TopicAssignment> existingByCmp = new Map<String, TopicAssignment>();
        for (TopicAssignment ta : [
            SELECT Id, TopicId, Topic.Name 
            FROM TopicAssignment 
            WHERE EntityId = :recordId
            WITH SECURITY_ENFORCED
        ]) {
            existingByCmp.put(normalizeForCompare(ta.Topic.Name), ta);
        }

        // 3. Resolve existing topics by display names; also scan for permutations
        Set<String> displayNames = new Set<String>(compareToDisplay.values());
        Map<String, Id> cmpToId = new Map<String, Id>();
        if (!displayNames.isEmpty()) {
            for (Topic t : [SELECT Id, Name FROM Topic WHERE Name IN :displayNames WITH SECURITY_ENFORCED]) {
                cmpToId.put(normalizeForCompare(t.Name), t.Id);
            }
        }

        // Create missing Topics
        List<Topic> toCreate = new List<Topic>();
        for (String cmp : incomingCompare) {
            if (!cmpToId.containsKey(cmp)) {
                toCreate.add(new Topic(Name = compareToDisplay.get(cmp)));
            }
        }
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] cr = Database.insert(toCreate, false, AccessLevel.USER_MODE);
            for (Integer i = 0; i < cr.size(); i++) {
                if (cr[i].isSuccess()) {
                    Topic t = toCreate[i];
                    cmpToId.put(normalizeForCompare(t.Name), t.Id);
                    publishEvent(null, t.Id, t.Name, ACTION.create);
                }
            }
        }

        // 4. Identify Inserts and Deletes
        List<TopicAssignment> toInsert = new List<TopicAssignment>();
        List<TopicAssignment> toDelete = new List<TopicAssignment>();

        for (String cmp : incomingCompare) {
            if (!existingByCmp.containsKey(cmp)) {
                Id tid = cmpToId.get(cmp);
                if (tid != null) {
                    toInsert.add(new TopicAssignment(EntityId = recordId, TopicId = tid));
                }
            }
        }

        for (String cmpExisting : existingByCmp.keySet()) {
            if (!incomingCompare.contains(cmpExisting)) {
                toDelete.add(existingByCmp.get(cmpExisting));
            }
        }

        // Publish events for deletions
        if (!toDelete.isEmpty()) {
            Map<Id, Topic> tMap = new Map<Id, Topic>([
                SELECT Id, Name FROM Topic WHERE Id IN :new Map<Id, TopicAssignment>(toDelete).keySet()
                WITH SECURITY_ENFORCED
            ]);
            for (TopicAssignment ta : toDelete) {
                Topic t = tMap.get(ta.TopicId);
                publishEvent(recordId, ta.TopicId, t != null ? t.Name : null, ACTION.remove);
            }
        }

        // Publish events for creations/assignments
        if (!toInsert.isEmpty()) {
            Map<Id, Topic> tMap2 = new Map<Id, Topic>([
                SELECT Id, Name FROM Topic WHERE Id IN :new Map<Id, TopicAssignment>(toInsert).keySet()
                WITH SECURITY_ENFORCED
            ]);
            for (TopicAssignment ta : toInsert) {
                Topic t = tMap2.get(ta.TopicId);
                publishEvent(recordId, ta.TopicId, t != null ? t.Name : null, ACTION.assign);
            }
        }

        if (!toDelete.isEmpty()) Database.delete(toDelete, AccessLevel.USER_MODE);
        if (!toInsert.isEmpty()) Database.insert(toInsert, AccessLevel.USER_MODE);

        upsertLongTextField(recordId, null);
    }
    // ===================== Helpers =====================

    /**
     * Normalize a topic name for comparison:
     * - Trim
     * - Collapse all internal whitespace to single spaces
     * - Remove leading/trailing common separators
     * - Lowercase
     */
    @TestVisible
    private static String normalizeForCompare(String input) {
        if (String.isBlank(input)) return '';
        String s = input.trim();
        // replace multiple whitespace with single space
        s = s.replaceAll('\\s+', ' ');
        // strip leading/trailing separators like ":" "-" "|" "," "."
        s = s.replaceAll('^[\\:\\-\\|\\,\\.\\s]+', '');
        s = s.replaceAll('[\\:\\-\\|\\,\\.\\s]+$', '');
        return s.toLowerCase();
    }

    /**
     * Canonical display form:
     * - Trim
     * - Collapse whitespace
     * - Preserve original casing of remaining characters
     */
    @TestVisible
    private static String canonicalizeDisplayName(String input) {
        if (String.isBlank(input)) return '';
        String s = input.trim();
        s = s.replaceAll('\\s+', ' ');
        s = s.replaceAll('^[\\:\\-\\|\\,\\.\\s]+', '');
        s = s.replaceAll('[\\:\\-\\|\\,\\.\\s]+$', '');
        return s;
    }

    /**
     * Publish a TopicEvent__e for real-time UI refresh
     */
    private static void publishEvent(Id recordId, Id topicId, String topicName, ACTION action) {
        // Use EventBus.publish for Platform Events (System.publishEvent doesn't exist)
        TopicEvent__e event = new TopicEvent__e(
            Action__c = String.valueOf(action),
            TopicId__c = topicId,
            TopicName__c = topicName,
            RecordId__c = recordId
        );
        EventBus.publish(event);
    }

    /**
     * Build and upsert the long text area field for the record.
     * If targetFieldApiName is null, determine default field per sObject type:
     *  Account/Case/Lead/Opportunity => Topics__c
     */
    @TestVisible
    private static void upsertLongTextField(Id recordId, String targetFieldApiName) {
        if (recordId == null) return;

        // Collect assigned topics ordered by created date of assignment
        List<TopicAssignment> tas = [
            SELECT Id, CreatedDate, Topic.Name 
            FROM TopicAssignment 
            WHERE EntityId = :recordId 
            ORDER BY CreatedDate ASC
        ];
        List<String> names = new List<String>();
        for (TopicAssignment ta : tas) {
            names.add(ta.Topic.Name);
        }
        String value = String.join(names, DEFAULT_DELIMITER);

        String sObjectTypeName = String.valueOf(recordId.getSObjectType());
        String fieldApi = resolveDefaultField(sObjectTypeName, targetFieldApiName);
        if (String.isBlank(fieldApi)) {
            return; // nothing to update
        }

        // FLS check
        if (!hasFieldWriteAccess(sObjectTypeName, fieldApi)) {
            return;
        }

        SObject sob = recordId.getSObjectType().newSObject(recordId);
        sob.put(fieldApi, value);
        Database.update(sob, AccessLevel.USER_MODE);
    }

    @TestVisible
    private static String resolveDefaultField(String sObjectTypeName, String overrideFieldApi) {
        if (!String.isBlank(overrideFieldApi)) return overrideFieldApi;
        // default Topics__c for common standard objects
        if (sObjectTypeName == 'Account' || sObjectTypeName == 'Case' || sObjectTypeName == 'Lead' || sObjectTypeName == 'Opportunity') {
            return 'Topics__c';
        }
        return null;
    }

    @TestVisible
    private static Boolean hasFieldWriteAccess(String sObjectTypeName, String fieldApi) {
        try {
            Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeName);
            if (t == null) return false;
            Schema.DescribeSObjectResult d = t.getDescribe();
            Schema.DescribeFieldResult f = d.fields.getMap().get(fieldApi).getDescribe();
            return f.isAccessible() && f.isUpdateable();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Check if the current user is following a specific topic
     */
    @TestVisible
    private static Boolean isUserFollowingTopic(Id topicId) {
        try {
            // Use ConnectApi to check if user is following the topic
            // This is a simplified approach - in practice, you'd use ConnectApi
            // For now, we'll return false to indicate no follow functionality
            // In a real implementation, this would check the ConnectApi
            return false;
        } catch (Exception e) {
            // If we can't determine follow status, assume not following
            return false;
        }
    }

    /**
     * Follow a topic for the current user
     */
    @AuraEnabled
    public static void followTopic(Id topicId) {
        try {
            // In a real implementation, this would use ConnectApi to follow the topic
            // For now, we'll just validate the topic exists
            Topic t = [SELECT Id FROM Topic WHERE Id = :topicId WITH SECURITY_ENFORCED LIMIT 1];
            // In a real implementation, we would call ConnectApi to follow the topic
            // For now, we'll just publish an event to indicate the action
            publishEvent(null, topicId, t.Name, ACTION.assign); // Using assign action for simplicity
        } catch (Exception e) {
            throw new AuraHandledException('Failed to follow topic: ' + e.getMessage());
        }
    }

    /**
     * Unfollow a topic for the current user
     */
    @AuraEnabled
    public static void unfollowTopic(Id topicId) {
        try {
            // In a real implementation, this would use ConnectApi to unfollow the topic
            // For now, we'll just validate the topic exists
            Topic t = [SELECT Id FROM Topic WHERE Id = :topicId WITH SECURITY_ENFORCED LIMIT 1];
            // In a real implementation, we would call ConnectApi to unfollow the topic
            // For now, we'll just publish an event to indicate the action
            publishEvent(null, topicId, t.Name, ACTION.remove); // Using remove action for simplicity
        } catch (Exception e) {
            throw new AuraHandledException('Failed to unfollow topic: ' + e.getMessage());
        }
    }
}