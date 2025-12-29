/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Batch class to sum all related Opportunity Amounts and update the Total_Amount__c field on Account.
 */
global class UpdateAccountTotalAmountBatch 
    implements Database.Batchable<SObject> {

   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Account'
        );
    }

   
    global void execute(Database.BatchableContext bc, List<Account> scope) {

        Set<Id> accIds = new Set<Id>();
        for (Account acc : scope) {
            accIds.add(acc.Id);
        }

        
        Map<Id, Decimal> accIdToTotalAmount = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            accIdToTotalAmount.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('totalAmount')
            );
        }

        // Update Accounts
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : scope) {
            Decimal totalAmt = accIdToTotalAmount.containsKey(acc.Id)
                ? accIdToTotalAmount.get(acc.Id)
                : 0;

            accountsToUpdate.add(new Account(
                Id = acc.Id
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    
    global void finish(Database.BatchableContext bc) {
        System.debug('Account Total Amount Batch Completed');
    }
}