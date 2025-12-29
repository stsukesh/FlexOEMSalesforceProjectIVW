/*
* User Name : Sukesh
* Date : 27/11/25
* Description : Generic handler that copies all standard Billing Address fields
*               to Shipping Address on Account insert/update.
*/
public class AccountTriggerHandler {

    public static void copyBillingToShipping(List<Account> newList,Map<Id,Account> oldMap) {
        System.debug('This Trigger is  executed');
                                                 


        if(newList.isEmpty())
            return;

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
}