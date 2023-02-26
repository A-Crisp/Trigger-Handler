trigger ContactTrigger on Contact(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandler.run(
        Trigger.old,
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap,
        Trigger.operationType
    );
}
