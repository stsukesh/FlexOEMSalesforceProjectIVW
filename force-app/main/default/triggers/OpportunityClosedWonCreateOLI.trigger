/**
 * @description Creates an Opportunity Line Item automatically when Opportunity stage becomes Closed Won.
 * @author Sukesh
 * @date 26-Nov-2025
 */
trigger OpportunityClosedWonCreateOLI on Opportunity (after update) {
    OpportunityClosedWonHandler.createLineItem(Trigger.new, Trigger.oldMap);
}