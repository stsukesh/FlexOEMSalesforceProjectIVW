/**
 * Author: Sukesh Subash
 * Date: 27/11/2025
 * Description: Handler class for OpportunityLineItem triggers to manage record counts.
 */
public with sharing class OpportunityLineItemHandler {

     /**
     * Method Name: updateOppLineItemCount
     * Description: Processes the count of line items for parent Opportunities.
     * @param oliList - List of OpportunityLineItems from Trigger context.
     */
    public static void updateOppLineItemCount(List<OpportunityLineItem> oliList) {

        try {
            if (oliList == null || oliList.isEmpty()) {
                return;
            }

            List<Opportunity> parentOppsToUpdate = [
                SELECT Id, (SELECT Id FROM OpportunityLineItems) 
                FROM Opportunity 
                WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Id IN :oliList)
            ];

            if (!parentOppsToUpdate.isEmpty()) {
                for (Opportunity oppRecord : parentOppsToUpdate) {
                     oppRecord.Number_of_Line_items__c  = oppRecord.OpportunityLineItems.size();
                }
                update parentOppsToUpdate;
            }

        } catch (Exception e) {
            System.debug(e);
          
        }

    }
}