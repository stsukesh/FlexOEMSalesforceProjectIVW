public class InactiveContactService {

    public void upsertSecondaryForInactiveContacts() {


        System.debug('Querying contacts related to inactive accounts');
        List<Contact> contactList = [
            SELECT Id, AccountId, Account.Rating, Level__c
            FROM Contact
            WHERE Account.Rating = 'Cold'
        ];

        System.debug('Setting Level field to Secondary');
        for (Contact c : contactList) {
            c.Level__c = 'Secondary';
            System.debug('Updated Contact: ' + c.Id);
        }

        upsert contactList;

    }
}