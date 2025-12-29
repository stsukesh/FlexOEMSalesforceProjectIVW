public class ContactHandler {

    /**
     * Method Name : handleAfterInsert
     * Parameters  : List<Contact> newContacts
     * Description :
     * Executes after Contact creation.
     */
    public static void handleAfterInsert(List<Contact> newContacts) {

        Set<Id> accountIds = new Set<Id>();

        List<Messaging.SingleEmailMessage> emailList =
            new List<Messaging.SingleEmailMessage>();

        for (Contact con : newContacts) {

            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }

            // Prepare email only if Contact has an email address
            if (con.Email != null) {

                Messaging.SingleEmailMessage mail =
                    new Messaging.SingleEmailMessage();

                mail.setToAddresses(new String[] { con.Email });
                mail.setSubject('Welcome to Our Organization');

                mail.setPlainTextBody(
                    'Hi ' + con.FirstName + ',\n\n' +
                    'Welcome! Your contact has been successfully created.'
                );

                emailList.add(mail);
            }		
        }

        // Send all emails in a single call (bulk-safe)
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }

        // Update related Accounts
        if (!accountIds.isEmpty()) {

            // Query accounts linked to contacts
            List<Account> accountsToUpdate = [
                SELECT Id, Email_Sent__c
                FROM Account
                WHERE Id IN :accountIds
            ];

            // Set Email_Sent__c to true
            for (Account acc : accountsToUpdate) {
                acc.Email_Sent__c = true;
            }

            // Perform DML update
            update accountsToUpdate;
        }
    }
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
    
    /**
 * @description Detects and prevents duplicate Contacts by checking Email and Phone during insert or update.
 * @author Sukesh
 * @date 26-Nov-2025
 *
 * Usage:
 *   ContactDuplicateHandler.preventDuplicates(Trigger.new, Trigger.oldMap);
 */
    public static void preventDuplicates(List<Contact> newList, Map<Id, Contact> oldMap) {

        // Collect incoming emails/phones (normalized)
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();

        for (Contact c : newList) {
            if (c.Email != null) emailSet.add(c.Email.trim().toLowerCase());
            if (c.Phone != null) phoneSet.add(c.Phone.trim());
        }

        if (emailSet.isEmpty() && phoneSet.isEmpty()) return;

        // Query existing contacts that match incoming email or phone
        List<Contact> existing = [
            SELECT Id, Email, Phone
            FROM Contact
            WHERE (Email IN :emailSet OR Phone IN :phoneSet)
        ];

        // Build maps for quick lookup if you prefer (optional)
        // Now compare and add errors when duplicate found
        for (Contact newC : newList) {

            // Determine if this is an insert (no oldMap entry) or update
            Boolean isInsert = (oldMap == null || !oldMap.containsKey(newC.Id));

            for (Contact oldC : existing) {
                // If update, don't compare the record to itself
                if (!isInsert && oldC.Id == newC.Id) continue;

                Boolean emailMatch = false;
                Boolean phoneMatch = false;

                if (newC.Email != null && oldC.Email != null) {
                    emailMatch = newC.Email.trim().toLowerCase() == oldC.Email.trim().toLowerCase();
                }

                if (newC.Phone != null && oldC.Phone != null) {
                    phoneMatch = newC.Phone.trim() == oldC.Phone.trim();
                }

                if (emailMatch || phoneMatch) {
                    newC.addError('Duplicate Contact detected: Email or Phone already exists.');
                    // stop checking more existing records once we flagged this one
                    break;
                }
            }
        }
    }

}