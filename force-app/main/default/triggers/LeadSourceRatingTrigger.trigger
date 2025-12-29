/*
* Username : Sukesh
* Date : 27/11/2025
* Description : Trigger to set Lead Rating based on Lead Source.
*/
trigger LeadSourceRatingTrigger on Lead (before insert, before update) {
    LeadSourceRatingHandler.applyRating(Trigger.new, Trigger.oldMap);
}