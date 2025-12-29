/**
 * Author: Sukesh Subash
 * Date: 27/11/2025
 * Description: Trigger on OpportunityLineItem to handle count rollups.
 */
trigger OpportunityLineItemCountTrigger on OpportunityLineItem (after insert, after update, after delete, after undelete) {
    
    // Check context and route to Handler
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            OpportunityLineItemHandler.updateOppLineItemCount(Trigger.new);
        }
        
        if (Trigger.isDelete) {
            OpportunityLineItemHandler.updateOppLineItemCount(Trigger.old);
        }
    }
}