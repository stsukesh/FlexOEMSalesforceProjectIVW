/**
 * Author: Sukesh Subash
 * Date: 30/12/2025
 * Description: Factory class to support AccountHandler coverage.
 */
@isTest
public class TestObjectFactory {
    /**
     * Method Name: createAccountRecords
     * Description: Inserts a bulk list of accounts for testing purposes.
     */
    public static List<Account> createAccountRecords(String namePrefix, Integer count) {
        if (count == null || count <= 0) {
            return new List<Account>();
        }
        
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accList.add(new Account(Name = namePrefix + ' ' + i));
        }
        
        insert accList;
        return accList;
    }
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accList.add(new Account(
                Name = 'Test Account ' + i,
                BillingStreet = '123 Main St',
                BillingCity = 'Coimbatore',
                BillingState = 'TN',
                BillingPostalCode = '641001',
                BillingCountry = 'India',
                Phone = '1234567890'
            ));
        }
        if (doInsert) {
            insert accList;
        }
        return accList;
    }

    public static List<Contact> createContacts(List<Account> accounts, Integer perAcc) {
        List<Contact> conList = new List<Contact>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < perAcc; i++) {
                conList.add(new Contact(LastName = 'TestCon ' + i, AccountId = acc.Id));
            }
        }
        insert conList;
        return conList;
    }

    /**
     * Method Name: getCaseRecords
     * Description: Creates Case records with given Status. Inserts and returns the created list.
     * @param status - Status to set on Cases (e.g., 'Closed', 'New')
     * @param count - Number of Case records to create
     * @return List<Case> - Inserted Case records
     */
   public static List<Case> getCaseRecords(String status, Integer count) {
        if (count == null || count <= 0) {
            return new List<Case>();
        }

        String targetStatus = status;
        
        // FIX: If 'Closed' is requested, find a status that the Org recognizes as closed
        if (status == 'Closed') {
            List<CaseStatus> closedStatuses = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true LIMIT 1];
            if (!closedStatuses.isEmpty()) {
                targetStatus = closedStatuses[0].MasterLabel;
            }
        }

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < count; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = targetStatus, // Uses the validated status label
                Origin = 'Email',
                Priority = 'Medium'
            ));
        }
        insert cases;
        return cases;
    }
    /**
     * Method Name: getAccountRecords
     * Description: Creates Account records with given Rating. Inserts and returns the created list.
     * @param rating - Rating to set on Accounts (e.g., 'Hot', 'Warm', 'Cold')
     * @param count - Number of Account records to create
     * @return List<Account> - Inserted Account records
     */
    public static List<Account> getAccountRecords(String rating, Integer count) {
        if (count == null || count <= 0) {
            return new List<Account>();
        }
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accs.add(new Account(
                Name = 'Factory Account ' + i,
                Rating = rating
            ));
        }
        insert accs;
        return accs;
    }

    /**
     * Method Name: createStandardUser
     * Description: Creates and inserts a standard user suitable for runAs tests.
     * @return User - Inserted standard user
     */
    public static User createStandardUser() {
        // Ensure a standard profile exists
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            FirstName = 'Std',
            LastName = 'User',
            Alias = 'stdusr',
            Email = 'std.user@example.com',
            Username = 'std.user.' + System.now().getTime() + '@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }
}