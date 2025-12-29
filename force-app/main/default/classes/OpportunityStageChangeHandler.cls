/**
 * Author : Sukesh
 * Date : 06-Dec-2025
 * Description : Handles logic to create Task when Opportunity stage changes
 */
public with sharing class OpportunityStageChangeHandler {

    static final String CLASS_NAME = 'OpportunityStageChangeHandler - ';

    /**
     * Method Name : createTaskOnStageChange
     * Description : Creates a Task whenever Opportunity StageName changes
     */
    public static void createTaskOnStageChange(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap
    ) {

        final String METHOD_NAME = 'createTaskOnStageChange - ';
        System.debug('Begin - ' + CLASS_NAME + METHOD_NAME);

        List<Task> tasksToInsert = new List<Task>();

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            // Check stage change
            if (oldOpp != null && opp.StageName != oldOpp.StageName) {

                Task t = new Task();
                t.WhatId = opp.Id;
                t.Subject = 'Opportunity stage changed';
                t.Description =
                    'Stage changed from ' + oldOpp.StageName +
                    ' to ' + opp.StageName;
                t.Status = 'Not Started';
                t.Priority = 'Normal';

                tasksToInsert.add(t);
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

        System.debug('Exit - ' + CLASS_NAME + METHOD_NAME);
    }
}