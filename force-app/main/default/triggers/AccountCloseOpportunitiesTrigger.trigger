trigger AccountCloseOpportunitiesTrigger on Account (after update) {

    List<Account> accountsToProcess = new List<Account>();

    for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        // Run only when checkbox changes from false → true
        if (acc.Close_Opportunities__c == true &&
            oldAcc.Close_Opportunities__c == false) {
            accountsToProcess.add(acc);
        }
    }

    if (!accountsToProcess.isEmpty()) {
        AccountCloseOpportunitiesHandler.closeRelatedOpportunities(accountsToProcess);
    }
}