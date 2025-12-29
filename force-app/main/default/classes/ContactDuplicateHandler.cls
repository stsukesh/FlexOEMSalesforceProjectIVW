/**
 * @description Detects and prevents duplicate Contacts by checking Email and Phone during insert or update.
 * @author Sukesh
 * @date 26-Nov-2025
 *
 * Usage:
 *   ContactDuplicateHandler.preventDuplicates(Trigger.new, Trigger.oldMap);
 */
public class ContactDuplicateHandler {

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