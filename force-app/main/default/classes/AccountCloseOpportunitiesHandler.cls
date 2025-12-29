/**
 * Author : Sukesh
 * Date : 30/11/2025
 * Description : Closes related Opportunities when Account checkbox is checked
 */
public with sharing class AccountCloseOpportunitiesHandler {

    static final String CLASS_NAME = 'AccountCloseOpportunitiesHandler - ';

    /**
     * Method Name : closeRelatedOpportunities
     * Description : Sets Stage to Closed Won for Opportunities
     *               with Probability > 90%
     * @param accountList - List of updated Accounts
     */
    public static void closeRelatedOpportunities(List<Account> accountList) {

        final String METHOD_NAME = 'closeRelatedOpportunities - ';
        System.debug('Begin - ' + CLASS_NAME + METHOD_NAME);

        Set<Id> accountIdSet = new Set<Id>();
        for (Account acc : accountList) {
            accountIdSet.add(acc.Id);
        }

        List<Opportunity> oppsToUpdate = [
            SELECT Id, StageName, Probability
            FROM Opportunity
            WHERE AccountId IN :accountIdSet
            AND Probability > 90
            AND StageName != 'Closed Won'
        ];

        for (Opportunity opp : oppsToUpdate) {
            opp.StageName = 'Closed Won';
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }

        System.debug('Exit - ' + CLASS_NAME + METHOD_NAME);
    }
}