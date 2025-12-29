/*
* Username : Sukesh
* Date : 27/11/2025
* Description : Trigger to copy standard Billing Address fields to Shipping
*               Address fields during insert and update.
*/
trigger AccountTriggers1 on Account (before insert, before update) {

    if (Trigger.isInsert) {
        AccountTriggerHandler.copyBillingToShipping(Trigger.new, null);
    }

    if (Trigger.isUpdate) {
        AccountTriggerHandler.copyBillingToShipping(Trigger.new, Trigger.oldMap);
    }
}