public class LeadsByTitleAndStatus {
    public List<Lead> getLeadsByTitleAndStatus(String titleValue, String statusValue) {
        if (String.isBlank(titleValue) || String.isBlank(statusValue)) {
        return new List<Lead>();
        }
        return [
        SELECT Id, FirstName, LastName, Company, Title, Status, Email, Phone FROM Lead
        WHERE Title = :titleValue
        AND Status = :statusValue
        ];
    }
}