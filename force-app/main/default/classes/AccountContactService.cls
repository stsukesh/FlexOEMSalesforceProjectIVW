public class AccountContactService {

    public List<Contact> getContactsByAccount(Id accId) {


        System.debug('Querying Contact records for given Account');
        List<Contact> contactList = [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE AccountId = :accId
        ];

        System.debug('Contacts fetched: ' + contactList.size());

        System.debug('Returning Contact list');
        return contactList;
    }
}