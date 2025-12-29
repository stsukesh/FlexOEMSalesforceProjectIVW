/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Scheduler to run the AccountRatingUpdateBatch daily.
 */
public with sharing class AccountRatingUpdateScheduler implements Schedulable {

 

    public void execute(SchedulableContext sc) {
    
        AccountRatingUpdateBatch ratingBatch = new AccountRatingUpdateBatch();
        Database.executeBatch(ratingBatch);

    }
}