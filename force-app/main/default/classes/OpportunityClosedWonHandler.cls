/**
 * @description Contains logic to auto-create an Opportunity Line Item when an Opportunity becomes Closed Won.
 * @author Sukesh
 * @date 26-Nov-2025
 *
 * Requirements:
 *  - When stage changes to Closed Won → create 1 OpportunityLineItem
 *  - Uses standard fields only
 *  - Requires: Pricebook, PricebookEntry, OpportunityLineItem
 */
public class OpportunityClosedWonHandler {

    public static void createLineItem(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();

        // Query Standard Pricebook & any Product to use
        Pricebook2 stdPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE IsActive = true LIMIT 1];
        PricebookEntry pbe = [
            SELECT Id, UnitPrice 
            FROM PricebookEntry 
            WHERE Product2Id = :prod.Id AND Pricebook2Id = :stdPB.Id 
            LIMIT 1
        ];

        for (Opportunity opp : newList) {

            Opportunity oldOpp = oldMap.get(opp.Id);

            // Only act if stage changed to Closed Won
            if (oldOpp != null &&
                oldOpp.StageName != 'Closed Won' &&
                opp.StageName == 'Closed Won') {

                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                oli.PricebookEntryId = pbe.Id;
                oli.Quantity = 1;
                oli.TotalPrice = pbe.UnitPrice;

                oliToInsert.add(oli);
            }
        }

        if (!oliToInsert.isEmpty()) {
            insert oliToInsert;
        }
    }
}