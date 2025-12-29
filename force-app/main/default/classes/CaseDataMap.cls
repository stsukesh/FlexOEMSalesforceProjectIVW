/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Service class to map Case data into various Map collections for processing.
 * Test class: CaseDataMapTest
 */
public class CaseDataMap {

    /**
     * Method Name: getMappedCaseData
     * Description: Queries cases and maps them by ID to the record and status.
     */
    public static void getMappedCaseData() {

        try {
            // list gets all the data about the case according to the queery
            List<Case> casesList = [
                SELECT Id, Subject, Status, Priority 
                FROM Case 
                LIMIT 3
            ];

            Map<Id, Case> caseRecordMap = new Map<Id, Case>();
            Map<Id, String> caseStatusMap = new Map<Id, String>();

            if (!casesList.isEmpty()) {
                for (Case caseRecord : casesList) {
                    caseRecordMap.put(caseRecord.Id, caseRecord);
                    caseStatusMap.put(caseRecord.Id, caseRecord.Status);
                }
                
                System.debug(LoggingLevel.DEBUG, 'Final Case Record Map: ' + caseRecordMap);
                System.debug(LoggingLevel.DEBUG, 'Final Case Status Map: ' + caseStatusMap);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,  ': ' + e.getMessage());
        }

    }
}