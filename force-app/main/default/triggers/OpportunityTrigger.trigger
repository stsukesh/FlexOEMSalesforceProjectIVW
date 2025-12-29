trigger OpportunityTrigger on Opportunity (before insert , before update) {
    if (Trigger.isBefore){
    OpportunityHandler.validateUserAccess(Trigger.new);
        
    }

}