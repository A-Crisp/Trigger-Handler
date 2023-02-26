@IsTest
public with sharing class TestTriggerAction implements TriggerAction {
    public static Boolean wasInvoked = false;

    public void run(
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    ) {
        wasInvoked = true;
    }
}
