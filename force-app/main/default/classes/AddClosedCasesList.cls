/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Service class to retrieve and collect IDs of Closed Cases.
 * Test class: AddClosedCasesListTest
 */
public with sharing class AddClosedCasesList {

    private static final String CLASS_NAME = 'AddClosedCasesList';

    /**
     * Method Name: getClosedCaseIds
     * Description: Queries cases with 'Closed' status and adds their IDs to a Set.
     */
    public static void getClosedCaseIds() {

        try {
            Set<Id> closedCaseIdsSet = new Set<Id>();

            List<Case> closedCasesList = [
                SELECT Id 
                FROM Case 
                WHERE Status = 'Closed'
            ];
            
            if (!closedCasesList.isEmpty()) {
                for (Case caseRecord : closedCasesList) {
                    closedCaseIdsSet.add(caseRecord.Id);
                }
                System.debug(LoggingLevel.DEBUG, 'Final Closed Case ID Set: ' + closedCaseIdsSet);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

    }
}