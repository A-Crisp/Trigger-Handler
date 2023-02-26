public with sharing class TriggerActionExample implements TriggerAction {
    public void run(
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    ) {
        //Do stuff
    }
}
