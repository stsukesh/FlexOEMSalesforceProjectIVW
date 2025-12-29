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
        
        // A. Update User Account Name
        if (Trigger.newMap != null && !Trigger.newMap.isEmpty()) {
            AccountHandler.updateUserAccountName(Trigger.newMap.keySet());
        }

        // B. Google Drive Logic & Phone Change Logic
        List<Id> idsToProcessGDrive = new List<Id>();
        Set<Id> accIdsWithPhoneChange = new Set<Id>(); 

        for (Account acc : Trigger.new) {
            // Logic for INSERT
            if (Trigger.isInsert) {
                idsToProcessGDrive.add(acc.Id);
                // If phone is provided on creation, you might want to sync it
                if (acc.Phone != null) {
                    accIdsWithPhoneChange.add(acc.Id);
                }
            } 
            // Logic for UPDATE (Safe to use oldMap here)
            else if (Trigger.isUpdate) {
                Account oldAcc = Trigger.oldMap.get(acc.Id);

                // Check for Name change (Google Drive)
                if (acc.Name != oldAcc.Name) {
                    idsToProcessGDrive.add(acc.Id);
                }

                // Check for Phone change (Contact Sync)
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