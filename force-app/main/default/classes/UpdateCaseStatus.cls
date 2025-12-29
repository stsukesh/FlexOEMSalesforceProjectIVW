/**
 * Author:Sukesh
 * Date: 26/12/2025
 * Description: Queueable class to update Case status to Escalated.
 */
public with sharing class UpdateCaseStatus implements Queueable {
    private static final String CLASS_NAME = 'UpdateCaseStatus - ';
    private Set<Id> caseIds;

    public UpdateCaseStatus(Set<Id> caseIds) {
        // Evaluate input parameter for null 
        this.caseIds = (caseIds != null) ? caseIds : new Set<Id>();
    }

    public void execute(QueueableContext context) {
       
        List<Case> casesToUpdate = [
            SELECT Id, Status, ContactId
            FROM Case
            WHERE Id IN :caseIds
        ];

        Set<Id> contactIds = new Set<Id>();
        for (Case c : casesToUpdate) {
            c.Status = 'Escalated';
            if (c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
        
        if (!contactIds.isEmpty()) {
            System.enqueueJob(new SendEscalationEmailQueueable(contactIds));
        }

        System.debug(LoggingLevel.DEBUG);
    }
}