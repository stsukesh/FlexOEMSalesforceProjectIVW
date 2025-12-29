public class OpportunityHandler {
    public static void validateUserAccess(List<Opportunity> oppList) {

        // Check the running user's profile
        String userProfile = [SELECT Id, Name, Profile.Name 
                              FROM User 
                              WHERE Id = :UserInfo.getUserId()]
                              .Profile.Name;

        // If user is NOT System Admin throw error
        if (userProfile != 'System Administrator') {
            for (Opportunity opp : oppList) {
                opp.addError('You are not allowed to create or edit '+ opp.Name+' Opportunity records.');
            }
        }
    }
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