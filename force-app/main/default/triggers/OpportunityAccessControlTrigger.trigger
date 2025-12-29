trigger OpportunityAccessControlTrigger on Opportunity (before insert, before update) {
    OpportunityAccessControlHandler.validateUserAccess(Trigger.new);
}