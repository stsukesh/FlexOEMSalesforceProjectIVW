public class ActiveAccountContactService {

    public void insertContactsForActiveAccounts() {


        System.debug('Querying all accounts that follow active rule');
        List<Account> accList = [
            SELECT Id, Name, Type
            FROM Account
            WHERE Type != null
        ];

        System.debug('Accounts fetched: ' + accList.size());

        List<Contact> contactToInsert = new List<Contact>();

        System.debug('Preparing Contact records');
        for (Account a : accList) {
            Contact c = new Contact();
            c.FirstName = 'Auto';
            c.LastName  = a.Name;
            c.AccountId = a.Id;

            System.debug('Adding Contact for Account: ' + a.Name);
            contactToInsert.add(c);
        }

        System.debug('Contact list ready for insert: ' + contactToInsert.size());

        if (!contactToInsert.isEmpty()) {
            System.debug('Inserting Contact records');
            insert contactToInsert;
        }

    }
}