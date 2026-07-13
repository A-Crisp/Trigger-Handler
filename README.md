# Trigger Handler

A metadata-table driven trigger framework for Salesforce. Instead of writing logic
directly inside Apex triggers, each trigger is a thin dispatcher that hands control
to a central `TriggerHandler`, which looks up which actions should run against a
custom metadata table (`Trigger_Action__mdt`) and invokes them in order.

This means adding, removing, reordering, or disabling logic for an object's trigger
is a metadata/configuration change, not a code change to the trigger itself.

## How it works

1. Every SObject has (at most) one trigger, and that trigger does nothing but
   forward the trigger context to `TriggerHandler.run(...)`.
2. `TriggerHandler` determines the SObject type and `System.TriggerOperation`
   context for the current trigger invocation, then queries `Trigger_Action__mdt`
   for all active records matching that object and context.
3. Matching records are ordered by `Invoke_Order__c` and instantiated via
   `Type.forName`, then each one's `run(...)` method is called in sequence.
4. Each action is a class implementing the `TriggerAction` interface, containing
   the actual business logic for that one piece of functionality.

```
Trigger (e.g. ContactTrigger)
    -> TriggerHandler.run(...)
        -> query Trigger_Action__mdt (by SObject + TriggerOperation, ordered)
            -> TriggerInvocableAction (instantiates the Apex class by name)
                -> TriggerAction.run(...) (your logic)
```

## Key components

-   **`TriggerHandler`** - Entry point called from every trigger. Looks up
    applicable `Trigger_Action__mdt` records and invokes the corresponding actions
    in order. Also exposes static methods to disable/enable actions at runtime
    (see below).
-   **`TriggerAction`** (interface) - Implement this on any class that should
    contain trigger logic. It exposes a single `run` method with the same
    signature as a trigger context (`oldList`, `newList`, `oldMap`, `newMap`,
    `operationType`).
-   **`TriggerInvocableAction`** - Internal wrapper that resolves an Apex class by
    namespace + name (via `Type.forName`) and invokes it as a `TriggerAction`.
-   **`Trigger_Action__mdt`** - Custom metadata type that configures which action
    classes run for which object and trigger context.

## Configuring an action (`Trigger_Action__mdt`)

Each custom metadata record wires one Apex class to one object/context:

| Field                       | Purpose                                                                                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Apex_Class_Name__c`        | Name of the class implementing `TriggerAction`.                                                                                                         |
| `Namespace__c`              | Leave blank for local classes. Provide the namespace if the class is located within a managed package.                                                  |
| `Trigger_Object__c`         | The SObject to run against. An EntityDefinition lookup, works for most SObjects.                                                                        |
| `Trigger_Object_Special__c` | Picklist for objects not selectable via `Trigger_Object__c` (e.g. `Task`, `Event`, `EmailMessage`, `User`). Values should be added to this as required. |
| `Trigger_Context__c`        | Which trigger event this action runs on, values match the TriggerOperation enum                                                                         |
| `Invoke_Order__c`           | Invocation order. Lower values run first for a given object + context.                                                                                  |
| `Is_Active__c`              | Whether the action should be invoked. Defaults to `true`.                                                                                               |

Exactly one of `Trigger_Object__c` / `Trigger_Object_Special__c` can be populated per record.
A class can be present within multiple actions, for example, to have it invoked in both an AFTER_INSERT and AFTER_UPDATE operation.

## Adding a new trigger action

1. Create a class implementing `TriggerAction`:

    ```apex
    public with sharing class MyAccountAction implements TriggerAction {
        public void run(
            List<SObject> oldList,
            List<SObject> newList,
            Map<Id, SObject> oldMap,
            Map<Id, SObject> newMap,
            System.TriggerOperation operationType
        ) {
            // your logic here
        }
    }
    ```

2. Create a `Trigger_Action__mdt` record pointing at that class, the target
   object, the trigger context it should run in, and an invoke order.
3. Make sure the object has a trigger that calls `TriggerHandler.run(...)`
   (see `ContactTrigger.trigger` for the standard pattern - the same seven
   lines work for any object).

No changes to `TriggerHandler` or the trigger itself are needed to add, reorder, or retire logic.

## Disabling actions at runtime

`TriggerHandler` exposes static toggles useful for tests or one-off contexts
(e.g. inbound Apex REST API calls) where trigger logic should be skipped:

```apex
TriggerHandler.disableAllTriggerActions();
// ... do work that should bypass all trigger actions ...
TriggerHandler.enableAllTriggerActions();

TriggerHandler.disableTriggerAction(actionMdtRecordId);
TriggerHandler.enableTriggerAction(actionMdtRecordId);
```

## Development

This is a standard Salesforce DX project.

```bash
pnpm install
sf project deploy start
sf apex run test
```
