/*
* User Name : Sukesh
* Date : 27/11/2025
* Description : Applies status and priority rules for Cases created or edited
*               with Origin = 'Email'.
*/
public class CaseEmailOriginHandler {

    public static void applyEmailCaseRules(List<Case> newList, Map<Id, Case> oldMap) {

        for (Case c : newList) {

            Boolean isNew = (oldMap == null || !oldMap.containsKey(c.Id));
            Case oldCase = (isNew ? null : oldMap.get(c.Id));

            // Condition: Origin = Email (create or update)
            if (c.Origin == 'Email') {

                // Prevent unnecessary updates
                if (isNew || oldCase.Origin != c.Origin) {
                    c.Status = 'New';
                    c.Priority = 'Medium';
                }
            }
        }
    }
}