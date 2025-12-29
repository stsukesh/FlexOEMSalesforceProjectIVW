/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Batch class to update Account Rating to 'Hot' for high revenue accounts.
 */
public with sharing class AccountRatingUpdateBatch implements Database.Batchable<SObject> {

   
    /**
     * Method Name: start
     * Description: Collects the records to be passed to the execute method.
     * @param bc - BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        // Query only required columns 
        return Database.getQueryLocator([
            SELECT Id, Rating 
            FROM Account 
            WHERE AnnualRevenue > 1000000
        ]);
    }

    /**
     * Method Name: execute
     * Description: Logic to update Rating to Hot.
     * @param bc - BatchableContext
     * @param accountList - List of Accounts from the query
     */
    public void execute(Database.BatchableContext bc, List<Account> accountList) {
       

        List<Account> accountsToUpdateList = new List<Account>(); 

        if (accountList != null && !accountList.isEmpty()) {
            for (Account acc : accountList) {
                acc.Rating = 'Hot';
                accountsToUpdateList.add(acc);
            }
        }

        if (!accountsToUpdateList.isEmpty()) {
            update accountsToUpdateList;
        }

    }

    public void finish(Database.BatchableContext bc) {
    }
}