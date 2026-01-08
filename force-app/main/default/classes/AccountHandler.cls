public  class AccountHandler {
     /**
     * Method Name : copyBillingToShipping
     * Description : This copys the data from the shipping to billing data.
     */
    public static void copyBillingToShipping(List<Account> newList,Map<Id,Account> oldMap) {
        System.debug('This Trigger is  executed');
                                                 


        if(newList.isEmpty())return;

        if(oldMap == null)
            oldMap = new Map<Id,Account>();

        for (Account acc : newList) {
            
            Account oldAcc = oldMap.get(acc.Id);

            Boolean isNew = (oldAcc == null);
            
           

            Boolean billingChanged =
                !isNew &&
                (
                    acc.BillingStreet     != oldAcc.BillingStreet ||
                    acc.BillingCity       != oldAcc.BillingCity ||
                    acc.BillingState      != oldAcc.BillingState ||
                    acc.BillingPostalCode != oldAcc.BillingPostalCode ||
                    acc.BillingCountry    != oldAcc.BillingCountry
                );

            if (isNew || billingChanged) {
                System.debug('This DML is  executed');
                acc.ShippingStreet     = acc.BillingStreet;
                acc.ShippingCity       = acc.BillingCity;
                acc.ShippingState      = acc.BillingState;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingCountry    = acc.BillingCountry;
            }
        }
    }

    /**
     * Method Name : updateUserAccountName
     * Description : Updates User Last_created_Account_Name__c using related Account Name.
     * @param accIds : Set of Account record Ids for which the owner User’s 
     * Last_created_Account_Name__c field needs to be updated.
     */
   @future
    public static void updateUserAccountName(Set<Id> accIds) {
        // Just call the synchronous helper
        updateUserAccountNameSync(accIds);
    }

    // 2. The Synchronous Helper (The actual logic)
    // This can be called safely from triggers, even if already in a batch or future context
    public static void updateUserAccountNameSync(Set<Id> accIds) {
        if (accIds == null || accIds.isEmpty()) return;

        List<Account> accountList = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :accIds];
        Map<Id, String> userAccountMap = new Map<Id, String>();

        for (Account acc : accountList) {
            userAccountMap.put(acc.OwnerId, acc.Name);
        }

        if (userAccountMap.isEmpty()) return;

        List<User> usersToUpdate = [SELECT Id, Last_created_Account_Name__c FROM User WHERE Id IN :userAccountMap.keySet()];
        
        for (User usr : usersToUpdate) {
            usr.Last_created_Account_Name__c = userAccountMap.get(usr.Id);
        }

        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }


    
    /**
 * Method Name : updateContactRelatedToAccount
 * Description : Updates related Contact records when Account Phone is changed.
 *
 * @param newAccList : List of new Account records from trigger context
 * @param oldAccMap  : Map of old Account records from trigger context
 */ 

	@future
    public static void updateContactOtherPhone(Set<Id> accountIds) {

        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact con : [
            SELECT Id, OtherPhone, Account.Phone
            FROM Contact
            WHERE AccountId IN :accountIds
        ]) {
            con.OtherPhone = con.Account.Phone;
            contactsToUpdate.add(con);
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    

}

}