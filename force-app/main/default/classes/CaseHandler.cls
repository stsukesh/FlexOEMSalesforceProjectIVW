/**
 * Author: Sukesh Subash
 * Date: 30/12/2025
 * Description: Applies status and priority rules for Cases created or edited with Origin = 'Email'.
 * Test class: CaseHandlerTest
 */
public inherited sharing class CaseHandler {

    /**
     * Method Name : updateEmailCaseRules
     * Description : Applies business logic to cases with Email origin.
     * @param newList : Trigger.new
     * @param oldMap : Trigger.oldMap
     */
    public static void updateEmailCaseRules(List<Case> newList, Map<Id, Case> oldMap) {
        // Evaluate the method input parameter for null - Return Early Pattern
        if (newList == null || newList.isEmpty()) {
            return;
        }

        // Ensure oldMap is initialized to avoid NullPointerException
        Map<Id, Case> safeOldMap = (oldMap != null) ? oldMap : new Map<Id, Case>();

        for (Case c : newList) {
            // Check if record is new or if Origin was changed
            Boolean isNew = (c.Id == null || !safeOldMap.containsKey(c.Id));
            
            Case oldCase = !isNew ? safeOldMap.get(c.Id) : null;

            Boolean isEmailOrigin = (c.Origin == 'Email');
            Boolean originChangedToEmail = !isNew && 
                                           oldCase.Origin != 'Email' && 
                                           isEmailOrigin;

            // Spacing after if statements as per coding standards
            if ((isNew && isEmailOrigin) || originChangedToEmail) {
                c.Status = 'New';
                c.Priority = 'Medium';
            }
        }
    }
    /**
     * Method Name : applyEmailCaseRules
     * Description : Applies business logic to cases with Email origin. 
     * Signature matches trigger call: (List<Case>, Map<Id, Case>).
     * @param newList : Trigger.new
     * @param oldMap : Trigger.oldMap
     */
    public static void applyEmailCaseRules(List<Case> newList, Map<Id, Case> oldMap) {
        // Evaluate the method input parameter for null - Return Early Pattern
        if (newList == null || newList.isEmpty()) {
            return;
        }

        // Initialize safe map to prevent NullPointerException as per standards
        Map<Id, Case> safeOldMap = (oldMap != null) ? oldMap : new Map<Id, Case>();

        for (Case c : newList) {
            // Check if record is being created (isNew)
            Boolean isNew = (c.Id == null || !safeOldMap.containsKey(c.Id));
            
            // Get old version of the record safely
            Case oldCase = !isNew ? safeOldMap.get(c.Id) : null;

            Boolean isEmailOrigin = (c.Origin == 'Email');
            
            // Logic to check if Origin was changed to 'Email'
            Boolean originChangedToEmail = !isNew && 
                                           oldCase.Origin != 'Email' && 
                                           isEmailOrigin;

            // Spacing after 'if' statements as per Performa IT standards
            if ((isNew && isEmailOrigin) || originChangedToEmail) {
                c.Status = 'New';
                c.Priority = 'Medium';
            }
        }
    }
}