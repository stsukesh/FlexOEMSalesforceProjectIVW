/**
 * @description Enforces that only System Administrators can create or edit Opportunities.
 * @author Sukesh
 * @date 26-Nov-2025
 */
public class OpportunityAccessControlHandler {

    public static void validateUserAccess(List<Opportunity> oppList) {

        // Check the running user's profile
        String userProfile = [SELECT Id, Name, Profile.Name 
                              FROM User 
                              WHERE Id = :UserInfo.getUserId()]
                              .Profile.Name;

        // If user is NOT System Admin → throw error
        if (userProfile != 'System Administrator') {
            for (Opportunity opp : oppList) {
                opp.addError('You are not allowed to create or edit Opportunity records.');
            }
        }
    }
}