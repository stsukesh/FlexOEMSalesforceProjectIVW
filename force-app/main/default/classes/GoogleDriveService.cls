/**
 * Author      : Sukesh Subash
 * Date        : 23/12/2025
 * Description : Service class for Google Drive integration to handle folder creation.
 */
public with sharing class GoogleDriveService { // Enabled 'with sharing' based on standards 

    public static Boolean skipTrigger = false;
    public static final String GOOGLE_DRIVE_ENDPOINT = 'callout:GoogleDriveAPI/drive/v3/files';

    /**
     * Method Name : createFolderForAccounts
     * Description : Asynchronously creates Google Drive folders for the provided Account IDs.
     * @param accountIds - List of Account IDs to process.
     */
    @future(callout=true)
    public static void createFolderForAccounts(List<Id> accountIds) {
        

        // Evaluate the method input parameter for null 
        if (accountIds != null && !accountIds.isEmpty()) {

            // Always assign the Query result to a List object 
            // Query only the columns which are required 
            List<Account> accsToUpdateList = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
            List<Account> accountsWithFolderIdsList = new List<Account>();

            for (Account acc : accsToUpdateList) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(GOOGLE_DRIVE_ENDPOINT);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                
                // Variable names in camel case indicating purpose 
                String safeName = acc.Name.replace('"', '\\"');
                String body = '{"name": "' + safeName + '", "mimeType": "application/vnd.google-apps.folder"}';
                req.setBody(body);
                
                Http http = new Http();
                try {
                    HttpResponse res = http.send(req);
                    if (res.getStatusCode() == 200) {
                        Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        String folderId = (String) resultsMap.get('id');
                        
                        // Initialize variables/objects before use 
                        Account accountObj = new Account(
                            Id = acc.Id, 
                            Description = 'Google Folder ID: ' + folderId
                        );
                        accountsWithFolderIdsList.add(accountObj);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.Error, 'Callout Error: ' + e.getMessage());
                }
            }

            if (!accountsWithFolderIdsList.isEmpty()) {
                // Bulkified DML update outside of loop [cite: 2, 3]
                GoogleDriveService.skipTrigger = true;
                update accountsWithFolderIdsList;
                GoogleDriveService.skipTrigger = false; 
            }
        }

    }
}