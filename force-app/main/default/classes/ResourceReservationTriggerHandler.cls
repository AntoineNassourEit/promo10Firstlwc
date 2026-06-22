public with sharing class ResourceReservationTriggerHandler extends TriggerHandler implements ITriggerHandler {
    public Boolean isDisabled() {
        return TriggerHandler.isBypassed('ResourceReservationTriggerHandler');
    }

    public override void beforeInsert() {
        Exercise5.validateOverlappingReservations(
            (List<Resource_Reservation__c>) Trigger.new, 
            null
        );
    }

    public override void beforeUpdate() {
        Exercise5.validateOverlappingReservations(
            (List<Resource_Reservation__c>) Trigger.new, 
            (Map<Id, Resource_Reservation__c>) Trigger.oldMap
        );
    }
    public override void afterInsert() {}
    public override void afterUpdate() {}
    public override void beforeDelete() {}
    public override void afterDelete() {}
    public override void afterUnDelete() {}
}