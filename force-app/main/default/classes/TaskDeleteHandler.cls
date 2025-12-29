/**
 * @description Ensures that only users with System Administrator profile can delete Tasks.
 * @author Sukesh
 * @date 26-Nov-2025
 *
 * Logic:
 *   - Query current user's profile.
 *   - If not System Administrator → addError() on each Task.
 */
public class TaskDeleteHandler {

    public static void preventTaskDelete(List<Task> oldTasks) {

        // Fetch current user Profile Name
        String profileName = [
            SELECT Name 
            FROM Profile 
            WHERE Id = :UserInfo.getProfileId()
            LIMIT 1
        ].Name;

        Boolean isSysAdmin = profileName == 'System Administrator';

        if (!isSysAdmin) {
            for (Task t : oldTasks) {
                t.addError('Only System Administrators are allowed to delete Tasks.');
            }
        }
    }
}