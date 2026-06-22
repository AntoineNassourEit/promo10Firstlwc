public with sharing class CompetitorTriggerHandler extends TriggerHandler implements ITriggerHandler {

    private Map<Id, Competitor__c> newMap;
    private Map<Id, Competitor__c> oldMap;
    private List<Competitor__c> TriggerNew;
    private List<Competitor__c> TriggerOld;
    
    public CompetitorTriggerHandler() {
        this.newMap     = (Map<Id, Competitor__c>) Trigger.newMap;
        this.oldMap     = (Map<Id, Competitor__c>) Trigger.oldMap;
        this.TriggerNew = (List<Competitor__c>) Trigger.New;
        this.TriggerOld = (List<Competitor__c>) Trigger.Old;
    }
    
    // Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    // Check if the trigger is disabled from transaction
    public Boolean isDisabled() {
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
        // 1. Pull the Opportunity from the Quote parent lookup first
        Exercise3.syncQuoteCompetitorToOpp(TriggerNew);
        
        // 2. Validate everything right after the lookup is set
        Exercise3.checkCompetitorLinks(TriggerNew, null, newMap);
    }
    
    public override void afterInsert() {
        // Automatically create the companion Opportunity competitor record
        Exercise3.createCompanionOppCompetitors(TriggerNew);
    }
    
    public override void beforeUpdate() {
        // Only validation context needed on update for these features
        Exercise3.checkCompetitorLinks(TriggerNew, oldMap, newMap);
    }
    
    public override void afterUpdate() {
        // Handle automated record creation on updates if the Quote changes
        Exercise3.createCompanionOppCompetitors(TriggerNew);
    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}