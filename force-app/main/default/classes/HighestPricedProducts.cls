public class HighestPricedProducts {
    public List<PricebookEntry> getTop10HighestPricedProducts() {
        return [
        SELECT Id, Name, UnitPrice, Product2.Name
        FROM PricebookEntry
        ORDER BY UnitPrice DESC
        LIMIT 10
        ];
    }
}