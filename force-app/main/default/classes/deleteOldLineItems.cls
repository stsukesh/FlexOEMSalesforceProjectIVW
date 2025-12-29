public class deleteOldLineItems {
public void deleteOldLineItemsForClosedWonOpps() {

        System.debug('Querying ');
        List<OpportunityLineItem> allOpplis = [
            SELECT Id, OpportunityId, CreatedDate
            FROM OpportunityLineItem
            WHERE Opportunity.StageName = 'Closed Won'
            ORDER BY OpportunityId, CreatedDate DESC
        ];

        Map<Id, Id> latestOliByOpp = new Map<Id, Id>();
        List<OpportunityLineItem> oliToDelete = new List<OpportunityLineItem>();

        for (OpportunityLineItem oli : allOpplis) {
            if (!latestOliByOpp.containsKey(oli.OpportunityId)) {
                latestOliByOpp.put(oli.OpportunityId, oli.Id); 
                System.debug('Marked latest OLI for Opportunity: ' + oli.OpportunityId);
            } else {
                oliToDelete.add(oli);
                System.debug('Marked for deletion: ' + oli.Id);
            }
        }

        if (!oliToDelete.isEmpty()) {
            System.debug('Deleting older line items now');
            delete oliToDelete;
        }

        System.debug('Operation complete. Latest line items retained successfully.');
    }
}