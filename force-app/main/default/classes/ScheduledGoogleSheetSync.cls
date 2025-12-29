global class ScheduledGoogleSheetSync implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Calls the future method to start the background sync
        GoogleSheetCaseSync.syncCasesFuture();
    }
}