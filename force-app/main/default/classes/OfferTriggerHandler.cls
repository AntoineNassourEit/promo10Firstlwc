public with sharing class OfferTriggerHandler extends TriggerHandler implements ITriggerHandler {

    // --- ITriggerHandler Interface Contract Implementation ---
    public Boolean isDisabled() {
        // Automatically tie into Kevin O'Hara's framework bypass mechanism
        return TriggerHandler.isBypassed('OfferTriggerHandler');
    }

    public override void beforeInsert() {
        Exercise4.executeIdentifierLogic((List<Offer__c>) Trigger.new, null);
    }

    public override void beforeUpdate() {
        Exercise4.executeIdentifierLogic((List<Offer__c>) Trigger.new, (Map<Id, Offer__c>) Trigger.oldMap);
    }

    // Clear empty overrides for remaining interface expectations
    public override void afterInsert() {}
    public override void afterUpdate() {}
    public override void beforeDelete() {}
    public override void afterDelete() {}
    public override void afterUnDelete() {}
}