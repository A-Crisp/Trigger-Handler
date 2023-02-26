public interface TriggerAction {
    void run(
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    );
}
