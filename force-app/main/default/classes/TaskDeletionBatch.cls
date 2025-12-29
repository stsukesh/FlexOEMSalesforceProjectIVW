/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Batch class to delete Task records created more than 2 years ago to maintain data hygiene.
 * Test class: TaskDeletionBatchTest
 */
public class TaskDeletionBatch implements Database.Batchable<sObject> {


    /**
     * Method Name: start
     * Description: Collects Task records created more than 2 years ago using a QueryLocator. 
     * @param bc - BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        
        // Requirement: Delete tasks created for the last 2 years (older than 2 years from today)
        // Query only required columns 
        return Database.getQueryLocator([
            SELECT Id 
            FROM Task 
            WHERE CreatedDate < LAST_N_YEARS:2
        ]);
    }

    /**
     * Method Name: execute
     * Description: Processes the deletion of task records in batches. 
     * @param bc - BatchableContext
     * @param taskList - List of Tasks to be deleted
     */
    public void execute(Database.BatchableContext bc, List<Task> taskList) {
        
        // Evaluate input parameter for null 
        if (taskList != null && !taskList.isEmpty()) {
            // Assigning query result/list to a List object for bulk processing 
            delete taskList;
        }

    }

    /**
     * Method Name: finish
     * Description: Finalize the batch process.
     * @param bc - BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
     
       
    }
}