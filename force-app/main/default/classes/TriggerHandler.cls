public without sharing class TriggerHandler {
    private static final List<Schema.SObjectType> SPECIAL_SOBJECT_TYPES = new List<Schema.SObjectType>{
        Task.getSObjectType(),
        EmailMessage.getSObjectType(),
        Event.getSObjectType(),
        User.getSObjectType()
    };

    @TestVisible
    private static Set<Id> disabledActions = new Set<Id>();
    @TestVisible
    private static Boolean disableAllActions = false;

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void run(
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    ) {
        if (disableAllActions) {
            return;
        }

        Schema.SObjectType triggerSObjectType = getTriggerSObjectType(oldList, newList);
        List<TriggerInvokableAction> triggerActions = getTriggerActions(
            triggerSObjectType,
            operationType
        );

        invokeTriggerActions(triggerActions, oldList, newList, oldMap, newMap, operationType);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @TestVisible
    private static void invokeTriggerActions(
        List<TriggerInvokableAction> invokableActions,
        List<SObject> oldList,
        List<SObject> newList,
        Map<Id, SObject> oldMap,
        Map<Id, SObject> newMap,
        System.TriggerOperation operationType
    ) {
        for (TriggerInvokableAction action : invokableActions) {
            action.run(oldList, newList, oldMap, newMap, operationType);
        }
    }

    @TestVisible
    private static List<TriggerInvokableAction> getTriggerActions(
        Schema.SObjectType objectType,
        System.TriggerOperation operationType
    ) {
        List<Trigger_Action__mdt> actionMetadata = getTriggerActionMetadata(
            objectType,
            operationType
        );

        List<TriggerInvokableAction> invokableActions = new List<TriggerInvokableAction>();

        for (Trigger_Action__mdt metadataRecord : actionMetadata) {
            if (!disabledActions.contains(metadataRecord.Id)) {
                invokableActions.add(
                    new TriggerInvokableAction(
                        metadataRecord.Namespace__c,
                        metadataRecord.Apex_Class_Name__c
                    )
                );
            }
        }

        return invokableActions;
    }

    @TestVisible
    private static Schema.SObjectType getTriggerSObjectType(
        List<SObject> oldList,
        List<SObject> newList
    ) {
        return newList == null ? oldList.getSObjectType() : newList.getSObjectType();
    }

    public static void disableAllTriggerActions() {
        disableAllActions = true;
    }

    public static void enableAllTriggerActions() {
        disableAllActions = false;
    }

    public static void disableTriggerAction(Id actionId) {
        disabledActions.add(actionId);
    }

    public static void enableTriggerAction(Id actionId) {
        disabledActions.remove(actionId);
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    @TestVisible
    private static List<Trigger_Action__mdt> getTriggerActionMetadata(
        Schema.SObjectType objectType,
        System.TriggerOperation operationType
    ) {
        if (SPECIAL_SOBJECT_TYPES.contains(objectType)) {
            return [
                SELECT Id, Namespace__c, Apex_Class_Name__c, Invoke_Order__c, Trigger_Context__c
                FROM Trigger_Action__mdt
                WHERE
                    Is_Active__c = TRUE
                    AND Trigger_Context__c = :String.valueOf(operationType)
                    AND Trigger_Object_Special__c = :String.valueOf(objectType)
                WITH SYSTEM_MODE
                ORDER BY Invoke_Order__c ASC
            ];
        }

        return [
            SELECT Id, Namespace__c, Apex_Class_Name__c, Invoke_Order__c, Trigger_Context__c
            FROM Trigger_Action__mdt
            WHERE
                Is_Active__c = TRUE
                AND Trigger_Context__c = :String.valueOf(operationType)
                AND Trigger_Object__r.QualifiedApiName = :String.valueOf(objectType)
            WITH SYSTEM_MODE
            ORDER BY Invoke_Order__c ASC
        ];
    }
}
