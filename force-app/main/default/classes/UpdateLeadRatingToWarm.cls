public class UpdateLeadRatingToWarm {
	public void updateWarmRatingForWorkingContactedLeads() {
        List<Lead> leadsToUpdate = [
        SELECT Id, Status, Rating
        FROM Lead
        WHERE Status = 'Working - Contacted'
        ];
        for (Lead l : leadsToUpdate) {
        l.Rating = 'Warm';
        }
        if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
        }
        System.debug('Leads with Working - Contacted status: '+leadsToUpdate);
        }
}