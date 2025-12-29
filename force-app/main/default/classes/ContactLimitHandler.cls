/**
 * @description Contains logic to ensure no Account exceeds 3 Contacts.
 * @author Sukesh
 * @date 26-Nov-2025
 * 
 * Working:
 *  - Collect AccountIds from incoming Contacts
 *  - Query existing Contact count
 *  - If existing + new exceeds 3 → block insert
 */
public class ContactLimitHandler {

    public static void enforceContactLimit(List<Contact> newContacts) {
        // Collect AccountIds from the incoming contact list
        Set<Id> accountIds = new Set<Id>();
        for (Contact c : newContacts) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return; // nothing to validate
        }

        // Count existing Contacts for these Accounts
        Map<Id, Integer> contactCountMap = new Map<Id, Integer>();

        for (AggregateResult agg : [
            SELECT AccountId accId, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            contactCountMap.put((Id)agg.get('accId'), (Integer)agg.get('cnt'));
        }

        // Validate limits
        for (Contact c : newContacts) {
            if (c.AccountId == null) continue;

            Integer existing = contactCountMap.get(c.AccountId);
            if (existing == null) existing = 0;

            if (existing >= 3) {
                c.addError('This account already has 3 Contacts. Cannot create more.');
            } else {
                // Predict creation of multiple contacts in the same transaction
                contactCountMap.put(c.AccountId, existing + 1);
            }
        }
    }
}