public class MassUpdateIndustryController {
    public List<Account> selectedAccounts { get; set; }

    public MassUpdateIndustryController(ApexPages.StandardSetController controller) {
        selectedAccounts = (List<Account>) controller.getSelected();
    }

    public PageReference updateIndustry() {
        for(Account acc : selectedAccounts) {
            acc.Industry = 'Technology';
        }
        update selectedAccounts;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Industry updated to Technology!'));
        return null;
    }
}