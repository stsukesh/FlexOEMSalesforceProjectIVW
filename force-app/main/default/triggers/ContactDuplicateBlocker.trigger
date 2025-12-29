/**
 * @description Blocks creation of duplicate Contacts based on Email or Phone.
 * @author Sukesh
 * @date 26-Nov-2025
 */
trigger ContactDuplicateBlocker on Contact (before insert, before update) {
    ContactDuplicateHandler.preventDuplicates(Trigger.new, Trigger.oldMap);
}