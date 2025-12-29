public class CreeateTaskForLeads {
	public void createFollowUpTasksForLeads(Set<Id> leadIds) {
if (leadIds == null || leadIds.isEmpty()) {
return;
}
List<Lead> leadsToProcess = [SELECT Id, Status FROM Lead WHERE Id IN :leadIds
AND Status = 'Working - Contacted'];
List<Task> tasksToInsert = new List<Task>();
for (Lead leadRecord : leadsToProcess) {
Task t = new Task(
WhoId = leadRecord.Id,
Subject = 'Follow-Up Required',
Status = 'Not Started',
Priority = 'High',
ActivityDate = Date.today().addDays(7)
);
tasksToInsert.add(t);
}
if (!tasksToInsert.isEmpty()) {
insert tasksToInsert;
}
System.debug('Leads with Working - Contacted status:'+leadsToProcess);
}
}