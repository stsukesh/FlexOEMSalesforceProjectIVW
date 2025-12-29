public class OpportunityProductCreator {

    public static void createOpportunityProduct() {

        // Step 1: Get existing Opportunity
        Opportunity opp = [
            SELECT Id, Name, Pricebook2Id
            FROM Opportunity
            WHERE Name = 'Test Opportunity'
            LIMIT 1
        ];

        // Step 2: Ensure Pricebook is assigned to Opportunity
        if (opp.Pricebook2Id == null) {
            // Get Standard Price Book
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            opp.Pricebook2Id = standardPB.Id;
            update opp;
        }

        // Step 3: Get a Product from Price Book
        PricebookEntry pbe = [
            SELECT Id, Product2.Name
            FROM PricebookEntry
            WHERE Product2.Name = 'Laptop'
            AND Pricebook2Id = :opp.Pricebook2Id
            LIMIT 1
        ];

        // Step 4: Create OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 50000
        );

        insert oli;

        System.debug('✅ Opportunity Product created for: ' + opp.Name);
    }
}