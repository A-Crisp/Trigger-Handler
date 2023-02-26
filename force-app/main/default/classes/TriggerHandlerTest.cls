@IsTest
public with sharing class TriggerHandlerTest {
    @IsTest
    static void getTriggerActionMetadataTest() {
        List<Trigger_Action__mdt> actions = TriggerHandler.getTriggerActionMetadata(
            Contact.getSObjectType(),
            System.TriggerOperation.AFTER_DELETE
        );

        System.Assert.isNotNull(actions);
    }

    @IsTest
    static void getSpecialTriggerActionMetadataTest() {
        List<Trigger_Action__mdt> actions = TriggerHandler.getTriggerActionMetadata(
            User.getSObjectType(),
            System.TriggerOperation.AFTER_DELETE
        );

        System.Assert.isNotNull(actions);
    }

    @IsTest
    static void disableAllTriggerActionsTest() {
        System.Assert.isFalse(TriggerHandler.disableAllActions);
        TriggerHandler.disableAllTriggerActions();
        System.Assert.isTrue(TriggerHandler.disableAllActions);
    }

    @IsTest
    static void enableAllTriggerActionsTest() {
        System.Assert.isFalse(TriggerHandler.disableAllActions);
        TriggerHandler.disableAllTriggerActions();
        System.Assert.isTrue(TriggerHandler.disableAllActions);
        TriggerHandler.enableAllTriggerActions();
        System.Assert.isFalse(TriggerHandler.disableAllActions);
    }

    @IsTest
    static void disableTriggerActionTest() {
        System.Assert.isTrue(TriggerHandler.disabledActions.isEmpty());
        TriggerHandler.disableTriggerAction(Id.valueOf('012000000000000AAA'));
        System.Assert.isFalse(TriggerHandler.disabledActions.isEmpty());
    }

    @IsTest
    static void enableTriggerActionTest() {
        System.Assert.isTrue(TriggerHandler.disabledActions.isEmpty());
        TriggerHandler.disableTriggerAction(Id.valueOf('012000000000000AAA'));
        System.Assert.isFalse(TriggerHandler.disabledActions.isEmpty());
        TriggerHandler.enableTriggerAction(Id.valueOf('012000000000000AAA'));
        System.Assert.isTrue(TriggerHandler.disabledActions.isEmpty());
    }

    @IsTest
    static void invokeTriggerActionsTest() {
        TriggerInvokableAction testAction = new TriggerInvokableAction('', 'TestTriggerAction');

        TriggerHandler.invokeTriggerActions(
            new List<TriggerInvokableAction>{ testAction },
            null,
            null,
            null,
            null,
            null
        );

        System.Assert.isTrue(TestTriggerAction.wasInvoked);
    }

    @IsTest
    static void getTriggerSObjectTypeTest() {
        List<SObject> testList = new List<Contact>();

        System.Assert.areEqual(
            Contact.getSObjectType(),
            TriggerHandler.getTriggerSObjectType(testList, null)
        );
        System.Assert.areEqual(
            TriggerHandler.getTriggerSObjectType(testList, null),
            Contact.getSObjectType()
        );
    }

    @IsTest
    static void getTriggerActionsTest() {
        //Stub test for coverage
        TriggerHandler.getTriggerActions(
            Contact.getSObjectType(),
            System.TriggerOperation.AFTER_DELETE
        );
    }

    @IsTest
    static void runTest() {
        //Stub test for coverage
        TriggerHandler.run(
            new List<Contact>(),
            new List<Contact>(),
            new Map<Id, Contact>(),
            new Map<Id, Contact>(),
            System.TriggerOperation.AFTER_DELETE
        );
    }
}
