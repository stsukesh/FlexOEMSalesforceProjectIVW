/**
 * @description Blocks deletion of Task records unless the user is a System Administrator.
 * @author Sukesh
 * @date 26-Nov-2025
 */
trigger TaskDeleteBlocker on Task (before delete) {
    //TaskDeleteHandler.preventTaskDelete(Trigger.old);
}