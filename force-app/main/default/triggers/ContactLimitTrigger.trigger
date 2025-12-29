/**
 * @description Restricts users from creating more than 3 Contacts under the same Account.
 * @author Sukesh
 * @date 26-Nov-2025
 */
trigger ContactLimitTrigger on Contact (before insert) {
    ContactLimitHandler.enforceContactLimit(Trigger.new);
}