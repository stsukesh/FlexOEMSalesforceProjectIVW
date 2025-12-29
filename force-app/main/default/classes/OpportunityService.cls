public class OpportunityService {

    public List<Opportunity> getClosedWonOpportunities() {


        System.debug('Executing SOQL query on Opportunity object');
        List<Opportunity> closedWonOpps = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName = 'Closed Won'
        ];

        System.debug('Query complete records fetched: ' + closedWonOpps.size());

        System.debug('Returning the result list from service method');
        return closedWonOpps;
    }
}