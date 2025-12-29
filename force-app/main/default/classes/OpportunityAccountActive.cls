public class OpportunityAccountActive {

    public List<Opportunity> getActiveAccountOpportunities() {


        System.debug('Querying Opportunity where related Account has valid Type');
        List<Opportunity> oppList = [
            SELECT Id, Name, Amount, CloseDate, AccountId, Account.Type
            FROM Opportunity
            WHERE Account.Type != null
        ];

        System.debug('Opportunities fetched: ' + oppList.size());

        return oppList;
    }
}