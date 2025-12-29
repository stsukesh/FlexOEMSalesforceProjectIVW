/**
 * Author      : Sukesh
 * Date        : 12/12/2025
 * Description : Queueable job to update Account activity dates.
 */
public class UpdateAccountLastActivity implements Queueable {
    private Set<Id> accountIds;

    public UpdateAccountLastActivity(Set<Id> accIds) {
        this.accountIds = accIds;
    }

    public void execute(QueueableContext context) {

        // Query tasks ordered by latest ActivityDate
        List<Task> taskList = [
            SELECT WhatId, ActivityDate
            FROM Task
            WHERE WhatId IN :accountIds
            AND ActivityDate != NULL
            ORDER BY ActivityDate DESC
        ];

        Map<Id, Date> accToLatestDate = new Map<Id, Date>();

        // First occurrence per Account will be the latest date
        for (Task t : taskList) {
            if (!accToLatestDate.containsKey(t.WhatId)) {
                accToLatestDate.put(t.WhatId, t.ActivityDate);
            }
        }

        List<Account> accsToUpdate = new List<Account>();

        for (Id accId : accToLatestDate.keySet()) {
            accsToUpdate.add(new Account(
                Id = accId,
                Last_Activity__c = accToLatestDate.get(accId)
            ));
        }

        if (!accsToUpdate.isEmpty()) {
            update accsToUpdate;
        }
    }
}