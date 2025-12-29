public class GoogleSheetCaseSync {

    @future(callout=true)
    public static void syncCasesFuture() {
        HttpRequest req = new HttpRequest();
        
        // Using your specific Spreadsheet ID
        String spreadsheetId = '1OEaq2Wo_zCftIWBgRQCIDO1QTwtpddW7Qp2-qM1azc8';
        req.setEndpoint('callout:GoogleNamedCredentials/v4/spreadsheets/' + spreadsheetId + '/values/Sheet1!A:H');
        req.setMethod('GET');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> values = (List<Object>) root.get('values');

                if (values != null && values.size() > 1) {
                    processAndInsert(values);
                }
            } else {
                System.debug('Google API Error: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('System Error: ' + e.getMessage());
        }
    }

    private static void processAndInsert(List<Object> values) {
        List<Case> casesToInsert = new List<Case>();
        
        // 1. DUPLICATE CHECK: Convert Decimal field to String for the Set
        Set<String> existingSerials = new Set<String>();
        for(Case c : [SELECT Serial_Number__c FROM Case WHERE Serial_Number__c != null AND CreatedDate = TODAY]) {
            // String.valueOf fixes the 'void add(Decimal)' error
            existingSerials.add(String.valueOf(c.Serial_Number__c));
        }

        // 2. LOOP DATA: Skip Header (Index 0)
        for (Integer i = 1; i < values.size(); i++) {
            List<Object> row = (List<Object>) values[i];
            if (row.size() < 2) continue; 

            // Get Serial from Column D (Index 3)
            String serialNumStr = (row.size() > 3) ? String.valueOf(row[3]).trim() : null;

            // Skip if this serial was already processed today
            if (String.isNotBlank(serialNumStr) && existingSerials.contains(serialNumStr)) {
                continue; 
            }

            Case c = new Case();
            c.Origin = 'Google Sheet';
            c.Status = 'New';
            
            // Map Subject (Col F / Index 5)
            c.Subject = (row.size() > 5) ? 'OEM Error: ' + String.valueOf(row[5]) : 'Manual Entry from Sheet';
            
            // Map Description (Col C and G)
            String model = (row.size() > 2) ? String.valueOf(row[2]) : 'Unknown Model';
            String details = (row.size() > 6) ? String.valueOf(row[6]) : 'No details provided';
            c.Description = 'Model: ' + model + '\nDetails: ' + details;
            
            // Map Priority (Col H / Index 7)
            c.Priority = (row.size() > 7) ? String.valueOf(row[7]) : 'Medium';
            
            // 3. DATA TYPE CONVERSION: Convert Sheet String back to Decimal for the field
            if (String.isNotBlank(serialNumStr)) {
                try {
                    c.Serial_Number__c = Decimal.valueOf(serialNumStr);
                } catch (Exception e) {
                    System.debug('Could not convert serial to number at row ' + i);
                }
            }
            
            casesToInsert.add(c);
        }

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }
}