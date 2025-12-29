/**
 * Author : Sukesh
 * Date : 06-Dec-2025
 * Description : Handler class to update Total Opportunity Amount on Account
 */
public with sharing class ContactOpportunityAmountHandler {

    /**
     * Method Name : updateTotalOpportunityAmount
     * Description : Calculates sum of Opportunity Amounts and updates Account
     * @param accountIds - Set of Account Ids
     */
    public static void updateTotalOpportunityAmount(Set<Id> accountIds) {

        Map<Id, Decimal> accountAmountMap = new Map<Id, Decimal>();

        // Aggregate Opportunity Amounts
        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) totalAmt
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountAmountMap.put(
                (Id) ar.get('accId'),
                (Decimal) ar.get('totalAmt')
            );
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Decimal totalAmount =
                accountAmountMap.containsKey(accId)
                ? accountAmountMap.get(accId)
                : 0;

            accountsToUpdate.add(new Account(
                Id = accId,
                Total_Opportunity_Amount__c = totalAmount
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}