trigger AccountTrigger on Account (after insert, after update, before insert, before update) {
    
    // 1. BEFORE CONTEXT
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountHandler.copyBillingToShipping(Trigger.new, null);
        } else if (Trigger.isUpdate) {
            AccountHandler.copyBillingToShipping(Trigger.new, Trigger.oldMap);
        }
    }
    
    // 2. AFTER CONTEXT
    if (Trigger.isAfter) {
        
        // A. Update User Account Name (FIXED FOR ASYNC EXCEPTION)
        if (Trigger.newMap != null && !Trigger.newMap.isEmpty()) {
            Set<Id> accIds = Trigger.newMap.keySet();
            
            // Safe Context Check:
            if (!System.isFuture() && !System.isBatch()) {
                // Normal execution: Call the required @future method
                AccountHandler.updateUserAccountName(accIds);
            } else {
                // Already in Async: Call the Sync version to prevent Exception
                AccountHandler.updateUserAccountNameSync(accIds);
            }
        }

        // B. Google Drive Logic & Phone Change Logic
        List<Id> idsToProcessGDrive = new List<Id>();
        Set<Id> accIdsWithPhoneChange = new Set<Id>(); 

        for (Account acc : Trigger.new) {
            if (Trigger.isInsert) {
                idsToProcessGDrive.add(acc.Id);
                if (acc.Phone != null) {
                    accIdsWithPhoneChange.add(acc.Id);
                }
            } 
            else if (Trigger.isUpdate) {
                Account oldAcc = Trigger.oldMap.get(acc.Id);
                if (acc.Name != oldAcc.Name) {
                    idsToProcessGDrive.add(acc.Id);
                }
                if (acc.Phone != oldAcc.Phone) {
                    accIdsWithPhoneChange.add(acc.Id);
                }
            }
        }

        // C. Execute Service Calls
        if (!idsToProcessGDrive.isEmpty()) {
            GoogleDriveService.createFolderForAccounts(idsToProcessGDrive);
        }

        if (!accIdsWithPhoneChange.isEmpty() && !System.isFuture()) {
            AccountHandler.updateContactOtherPhone(accIdsWithPhoneChange);
        }
    }
}