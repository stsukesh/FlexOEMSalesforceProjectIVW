/*
* User Name : Sukesh
* Date : 27/11/2025
* Description : Applies status and priority rules for Cases created or edited
* with Origin = 'Email'.
*/
public class CaseHandler {

    public static void applyEmailCaseRules(List<Case> newList, Map<Id, Case> oldMap) {
        if (newList == null) return;
        if(oldMap == null)
            oldMap = new Map<Id,Case>();

        

        for (Case c : newList) {
            // Check if the record is being created (isNew) or if Origin was changed to 'Email'
            Boolean isNew = (oldMap == null);
            Boolean originChangedToEmail = !isNew && 
                                          oldMap.get(c.Id).Origin != 'Email' && 
                                          c.Origin == 'Email';

            // Apply rules ONLY if it's a new Email case OR Origin just changed to Email
            if ((isNew && c.Origin == 'Email') || originChangedToEmail) {
                c.Status = 'New';
                c.Priority = 'Medium';
            }
        }
    }
}