/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Service class to group Case records by their Status into a Map.
 * Test class: MapCasesStatusTest
 */
public with sharing class MapCasesStatus {

    

    /**
     * Method Name: getCasesMappedByStatus
     * Description: Queries up to 10 cases and groups them into a Map where key is Status.
     */
    public static void getCasesMappedByStatus() {
        
        try {
            // Standard: Always assign the Query result to List object 
            List<Case> caseList = [
                SELECT Id, Subject, Status 
                FROM Case 
                LIMIT 10
            ];

            // Standard: Initialize the Map variable
            Map<String, List<Case>> statusCaseMap = new Map<String, List<Case>>();

            if (!caseList.isEmpty()) {
                for (Case caseRecord : caseList) {
                    // Spacing after 'if' statement
                    if (!statusCaseMap.containsKey(caseRecord.Status)) {
                        statusCaseMap.put(caseRecord.Status, new List<Case>());
                    }
                    statusCaseMap.get(caseRecord.Status).add(caseRecord);
                }
                System.debug(LoggingLevel.DEBUG, 'Final Status to Case Map: ' + statusCaseMap);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,  e.getMessage());
        }

   
    }
}