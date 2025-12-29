/**
 * Author : Sukesh
 * Date : 30/11/2025
 * Description : This class handles OpportunityLineItem trigger logic
 *               and updates Number_of_Products__c field on Account
 */
trigger OpportunityLineItemTrigger on OpportunityLineItem (
    before insert,
    after insert,
    after delete,
    after undelete
) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) {
            OpportunityLineItemTriggerHandler.updateProductCountInAccount(
                Trigger.isDelete ? Trigger.old : Trigger.new
            );
        }
    }
}