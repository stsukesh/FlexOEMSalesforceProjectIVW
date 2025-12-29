/**
 * Author : Sukesh
 * Date : 06-Dec-2025
 * Description : Creates a Task whenever Opportunity Stage is changed
 */
trigger OpportunityStageChangeTrigger on Opportunity (after update) {
    OpportunityStageChangeHandler.createTaskOnStageChange(
        Trigger.new,
        Trigger.oldMap
    );
}