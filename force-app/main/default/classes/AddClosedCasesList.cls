/**
 * @name: AddClosedCasesList
 * @author: Sukesh Subash
 * @description: Service class to collect IDs of Closed Cases.
 * @test class: AddClosedCasesListTest
 */
public with sharing class AddClosedCasesList {

    /**
     * @name: getClosedCaseIds
     * @description: Returns a set of IDs for all Closed Cases visible to the user
     * @return Set<Id> - Set of Case IDs
     */
    public static Set<Id> getClosedCaseIds() {
        Set<Id> closedCaseIdsSet = new Set<Id>();
        try {
            // Assign to List to prevent exceptions, use Security Enforced
            List<Case> closedCasesList = [
                SELECT Id 
                FROM Case 
                WHERE IsClosed = true 
                WITH SECURITY_ENFORCED
            ];
            
            for (Case c : closedCasesList) {
                closedCaseIdsSet.add(c.Id);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
        }
        return closedCaseIdsSet;
    }
}