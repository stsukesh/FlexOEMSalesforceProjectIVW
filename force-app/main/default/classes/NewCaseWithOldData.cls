public class NewCaseWithOldData {

    public static void createNewCasesFromExisting() {

        System.debug('STEP 1: Starting case query');

        List<Case> existingCases = [
            SELECT Id, Subject, Status
            FROM Case
            LIMIT 5
        ];
        System.debug('STEP 2: Existing Cases Fetched: ' + existingCases);

        List<Case> newCasesList = new List<Case>();
        System.debug(' Created empty list to store new Case records');

        for (Case c : existingCases) {
            System.debug(' Iterating Case: ' + c.Id);

            Case newC = new Case(
                Subject = 'Created from Case ' + c.Id,
                Status = 'New',
                Origin = 'Phone'
            );
            System.debug(' New Case Prepared: ' + newC);

            newCasesList.add(newC);
            System.debug(' Added new Case to List');
        }

        insert newCasesList;
        System.debug('Inserted new Case records: ' + newCasesList);
    }
}