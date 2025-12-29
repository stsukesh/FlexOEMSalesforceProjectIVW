/**
 * Author : Sukesh
 * Date : 30/11/2025
 * Description : This class handles OpportunityLineItem trigger logic
 *               and updates Number_of_Products__c field on Account
 */
public with sharing class OpportunityLineItemTriggerHandler {

    static final String CLASS_NAME = 'OpportunityLineItemTriggerHandler - ';

    /**
     * Method Name : updateProductCountInAccount
     * Description : Updates total number of products related to all
     *               Opportunities under an Account
     * @param opportunityLineItemList - List of OpportunityLineItem records
     */
    public static void updateProductCountInAccount(
        List<OpportunityLineItem> opportunityLineItemList
    ) {

        final String METHOD_NAME = 'updateProductCountInAccount - ';
        System.debug('Begin - ' + CLASS_NAME + METHOD_NAME +
                     ' Records Size = ' + opportunityLineItemList.size());

        // Collect Opportunity Ids
        Set<Id> opportunityIdSet = new Set<Id>();
        for (OpportunityLineItem oli : opportunityLineItemList) {
            if (oli.OpportunityId != null) {
                opportunityIdSet.add(oli.OpportunityId);
            }
        }

        // Fetch related Opportunities
        List<Opportunity> parentOpportunities = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id IN :opportunityIdSet
        ];

        // Collect Account Ids
        Set<Id> accountIdSet = new Set<Id>();
        for (Opportunity opp : parentOpportunities) {
            if (opp.AccountId != null) {
                accountIdSet.add(opp.AccountId);
            }
        }

        // Aggregate OpportunityLineItem count per Account
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : [
            SELECT Opportunity.AccountId accId, COUNT(Id) productCount
            FROM OpportunityLineItem
            WHERE Opportunity.AccountId IN :accountIdSet
            GROUP BY Opportunity.AccountId
        ]) {
            accountsToUpdate.add(new Account(
                Id = (Id) ar.get('accId'),
                Number_of_Products__c = (Integer) ar.get('productCount')
            ));
        }

        // Update Accounts
        if (!accountsToUpdate.isEmpty()) {
            Database.update(accountsToUpdate, false);
        }

        System.debug('Exit' + CLASS_NAME + METHOD_NAME);
    }
}