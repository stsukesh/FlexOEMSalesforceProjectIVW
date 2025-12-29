public class ContactService {

    public Set<Id> getActiveAccountContactIds() {

        System.debug('Method start');

        System.debug('Querying Contact whose related Account rating is Hot(active)');
        Set<Id> contactIds = new Set<Id>();

        for (Contact c : [
            SELECT Id
            FROM Contact
            WHERE Account.Rating = 'Hot'
        ]) {
            System.debug('Adding Contact Id into Set');
            contactIds.add(c.Id);
        }

        System.debug('Returning Contact Id Set, count: ' + contactIds.size());
        return contactIds;
    }
}