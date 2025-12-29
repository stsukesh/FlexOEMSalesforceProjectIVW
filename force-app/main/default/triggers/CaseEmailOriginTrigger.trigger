/*
* Username : Sukesh
* Date : 27/11/2025
* Description : Trigger to apply rules for Email-origin Cases.
*/
trigger CaseEmailOriginTrigger on Case (before insert, before update) {

    CaseEmailOriginHandler.applyEmailCaseRules(Trigger.new, Trigger.oldMap);
}