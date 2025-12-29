/*
* Username : Sukesh
* Date : 27/11/2025
* Description : Applies rating rules for Leads based on Lead Source.
*/
public class LeadSourceRatingHandler {

    public static void applyRating(List<Lead> newList, Map<Id, Lead> oldMap) {

        for (Lead ld : newList) {

            Boolean isNew = (oldMap == null || !oldMap.containsKey(ld.Id));
            Lead oldLead = isNew ? null : oldMap.get(ld.Id);

            // If Lead Source = Web → Rating = Cold
            // Otherwise → Rating = Hot
            // Only update when new OR Lead Source changed
            if (isNew || ld.LeadSource != oldLead.LeadSource) {

                if (ld.LeadSource == 'Web') {
                    ld.Rating = 'Cold';
                } else {
                    ld.Rating = 'Hot';
                }
            }
        }
    }
}