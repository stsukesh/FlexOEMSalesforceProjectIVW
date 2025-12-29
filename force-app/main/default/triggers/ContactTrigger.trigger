trigger ContactTrigger on Contact (before insert ,before update, after insert , after update) {
    /**
* Trigger Name : ContactAfterInsert
* Object       : Contact
* Event        : After Insert
* Description  : When a new Contact is created,
*                1. Send a welcome email to the Contact
*                2. Update related Account.Email_Sent__c = true
*/
    
    ContactHandler.handleAfterInsert(Trigger.new);
    
    /**
* Trigger Name : ContactEnforceLimit
* Object       : Contact
* Event        : After Insert
* Description  : sets max of 3 contacts
*/
    
    
    if(Trigger.isInsert){
        ContactHandler.enforceContactLimit(Trigger.new);
    }
    /**
* @description Blocks creation of duplicate Contacts based on Email or Phone.
* @author Sukesh
* @date 26-Nov-2025
*/
    if(Trigger.isBefore){
        ContactHandler.preventDuplicates(Trigger.new, Trigger.oldMap);
        
    }
    
}