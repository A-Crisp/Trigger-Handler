public inherited sharing class TriggerInvokableAction {
    private final String namespace;
    private final String className;
    private final System.Type apexActionType;

    public TriggerInvokableAction(String namespace, String className) {
        this.namespace = namespace;
        this.className = className;

        this.apexActionType = Type.forName(this.namespace, this.className);
    }

    public void run(
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    ) {
        this.getInitialisedAction().run(oldList, newList, oldMap, newMap, operationType);
    }

    private TriggerAction getInitialisedAction() {
        return (TriggerAction) this.apexActionType.newInstance();
    }
}
