/**
 * DEPLOY ERROR TEST: Trigger handler missing dependency
 *
 * Expected error: "Invalid type: NonExistentTriggerHandler"
 * Error category: Trigger handler missing dependency
 */
trigger DeployErrorTriggerHandler on Account (before insert, before update) {
    NonExistentTriggerHandler handler = new NonExistentTriggerHandler();
    handler.handleBeforeInsert(Trigger.new);
}
