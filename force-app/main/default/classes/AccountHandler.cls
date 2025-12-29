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
        

        // Evaluate the method input parameter for null 
        if (accIds == null || accIds.isEmpty()) {
            return;
        }

        // Query only the columns which are required and assign result to List object 
        List<Account> accountList = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :accIds];
        
        // Ensure variables are initialized 
        Map<Id, String> userAccountMap = new Map<Id, String>();

        for (Account acc : accountList) {
             //If user owns multiple accounts, this gets the last one's name
            userAccountMap.put(acc.OwnerId, acc.Name);
        }

        if (userAccountMap.isEmpty()) {
            return;
        }


        List<User> usersToUpdate = [SELECT Id, Last_created_Account_Name__c FROM User WHERE Id IN :userAccountMap.keySet()];
        
        for (User usr : usersToUpdate) {
            usr.Last_created_Account_Name__c = userAccountMap.get(usr.Id);
        }

        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }

        
}
    /**
     * Method Name : handleAfterUpdate
     * Description : Handles after update logic for Account.
     *               Detects Account Phone change and updates related Contacts.
     *
     * @param newAccList : List of new Account records from trigger context
     * @param oldAccMap  : Map of old Account records from trigger context
     */
    public static void handleAfterUpdate(
        List<Account> newAccList,
        Map<Id, Account> oldAccMap
    ) {

        Set<Id> accIdsWithPhoneChange = new Set<Id>();

        for (Account acc : newAccList) {
            Account oldAcc = oldAccMap.get(acc.Id);

            if (acc.Phone != oldAcc.Phone) {
                accIdsWithPhoneChange.add(acc.Id);
            }
        }

        if (!accIdsWithPhoneChange.isEmpty()) {
            updateContactOtherPhone(accIdsWithPhoneChange);
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