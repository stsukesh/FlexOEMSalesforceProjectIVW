/**
 * Date: 23/12/2025
 * Author: Sukesh
 * Description: This class is used to connect the Gdrive with the various API methods.
 */
public class GoogleDriveIntegrationService {
    
    // ============================
    // COMMON CONFIG
    // ============================
    private static final String BASE_ENDPOINT = 'callout:GoogleDriveAPI/drive/v3/files';

    /**
     * @description Creates a new folder in Google Drive.
     * @param folderName The name of the folder to be created.
     * @return String The unique ID of the created folder, or null if creation failed.
     */
    public static String createFolder(String folderName) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(BASE_ENDPOINT);

            Map<String, Object> body = new Map<String, Object>{
                'name' => folderName,
                'mimeType' => 'application/vnd.google-apps.folder'
            };

            req.setBody(JSON.serialize(body));
            HttpResponse res = new Http().send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String folderId = (String) resp.get('id');
                System.debug('SUCCESS: Folder Created. ID: ' + folderId);
                return folderId;
            } else {
                System.debug('POST Error: ' + res.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception in createFolder: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Retrieves a list of the first 10 files/folders from the root directory.
     * @return void
     */
    public static void listAllFiles() {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(BASE_ENDPOINT + '?pageSize=10&fields=files(id,name)');

            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Drive Files: ' + res.getBody());
            } else {
                System.debug('GET Error: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception in listAllFiles: ' + e.getMessage());
        }
    }

    /**
     * @description Updates the name of an existing file or folder in Google Drive.
     * @param fileId The unique Google Drive ID of the item to rename.
     * @param newName The new name to apply to the item.
     * @return void
     */
    public static void renameItem(String fileId, String newName) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('PATCH'); 
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(BASE_ENDPOINT + '/' + fileId);

            Map<String, Object> body = new Map<String, Object>{
                'name' => newName
            };

            req.setBody(JSON.serialize(body));
            HttpResponse res = new Http().send(req);
            
            System.debug('PATCH Status: ' + res.getStatusCode());
            System.debug('PATCH Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Exception in renameItem: ' + e.getMessage());
        }
    }

    /**
     * @description Deletes a file or folder (moves it to the Trash).
     * @param fileId The unique Google Drive ID of the item to delete.
     * @return void
     */
    public static void deleteItem(String fileId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('DELETE');
            req.setEndpoint(BASE_ENDPOINT + '/' + fileId);

            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 204) {
                System.debug('SUCCESS: Item deleted/trashed.');
            } else {
                System.debug('DELETE Error: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception in deleteItem: ' + e.getMessage());
        }
    }
}