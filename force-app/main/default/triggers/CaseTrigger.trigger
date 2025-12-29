trigger CaseTrigger on Case (before insert, before update, after update, after insert) {
    
    if(Trigger.isBefore){
		CaseHandler.applyEmailCaseRules(Trigger.new, Trigger.oldMap);
        

}
}