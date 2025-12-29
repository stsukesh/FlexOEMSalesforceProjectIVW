/**
 * Author: Sukesh Subash
 * Date: 26/12/2025
 * Description: Service class to map Accounts with their related Contact records.
 * Test class: AccountContactMapperTest
 */
public with sharing class AccountContactMapper {


    /**
     * Method Name: getAccountContactMap
     * Description: Queries Accounts and their child Contacts, then populates a Map.
     * @return Map<Id, List<Contact>> - Map of Account ID to List of related Contacts.
     */
    public static Map<Id, List<Contact>> getAccountContactMap() {
        
        Map<Id, List<Contact>> accContactMap = new Map<Id, List<Contact>>();

        try {
            List<Account> accountWithContactsList = [
                SELECT Id, Name, (SELECT Id, LastName, Email FROM Contacts)
                FROM Account
                LIMIT 200
            ];

            if (!accountWithContactsList.isEmpty()) {
                for (Account accountRecord : accountWithContactsList) {
                    // acc.Contacts returns a List<Contact> from the subquery
                    accContactMap.put(accountRecord.Id, accountRecord.Contacts);
                    
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        
        return accContactMap;
    }
}