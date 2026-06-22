public with sharing class Exercise3 {

    // Context guard to prevent the auto-created record from triggering validation against its twin
    private static Boolean isAutoCreatingCompanion = false;

    /**
     * SECTION 1: VALIDATION LOGIC
     * Validates that an Account isn't already related to a Quote or an Opportunity via another Competitor.
     * Context: BEFORE INSERT, BEFORE UPDATE
     */
    public static void checkCompetitorLinks(List<Competitor__c> newList, Map<Id, Competitor__c> oldMap, Map<Id, Competitor__c> newMap) {
        // If this execution was spawned by our own companion auto-creation, bypass validation
        if (isAutoCreatingCompanion) {
            return;
        }

        Map<Id, Competitor__c> accountIdsToCompetitorForQuotesMap = new Map<Id, Competitor__c>();
        Map<Id, Competitor__c> accountIdsToCompetitorForOppsMap = new Map<Id, Competitor__c>();

        for (Competitor__c comp : newList) {
            // Quote Link Validation Check
            if ((oldMap == null || oldMap.get(comp.Id).Quote__c != comp.Quote__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                && (comp.Quote__c != null && comp.Account__c != null)) {
                
                accountIdsToCompetitorForQuotesMap.put(comp.Account__c, comp);
            }

            // Opportunity Link Validation Check
            if ((oldMap == null || oldMap.get(comp.Id).Opportunity__c != comp.Opportunity__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                && (comp.Opportunity__c != null && comp.Account__c != null)) {
                
                accountIdsToCompetitorForOppsMap.put(comp.Account__c, comp);
            }
        }

        // Run validation against existing Quote competitors
        if (!accountIdsToCompetitorForQuotesMap.isEmpty()) {
            for (Competitor__c comp : [SELECT Id, Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForQuotesMap.keySet() AND Quote__c != null]) {
                if (newMap == null || !newMap.containsKey(comp.Id)) {
                    accountIdsToCompetitorForQuotesMap.get(comp.Account__c).addError('This account is already related to a quote through a competitor');
                }
            }
        }

        // Run validation against existing Opportunity competitors
        if (!accountIdsToCompetitorForOppsMap.isEmpty()) {
            for (Competitor__c comp : [SELECT Id, Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForOppsMap.keySet() AND Opportunity__c != null]) {
                if (newMap == null || !newMap.containsKey(comp.Id)) {
                    accountIdsToCompetitorForOppsMap.get(comp.Account__c).addError('This account is already related to an opportunity through a competitor');
                }
            }
        }
    }

    /**
     * SECTION 2: AUTOMATION LOGIC
     * Automatically creates a companion Opportunity Competitor record when a Quote Competitor is created.
     * Context: AFTER INSERT, AFTER UPDATE
     */
    public static void createCompanionOppCompetitors(List<Competitor__c> newList) {
        // Guard clause to prevent infinite loops if something else triggers an update
        if (isAutoCreatingCompanion) {
            return;
        }

        Set<Id> quoteIds = new Set<Id>();
        
        for (Competitor__c comp : newList) {
            if (comp.Quote__c != null && comp.Account__c != null) {
                quoteIds.add(comp.Quote__c);
            }
        }
        
        if (quoteIds.isEmpty()) return;
        
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([
            SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds AND OpportunityId != null
        ]);
        
        if (quoteMap.isEmpty()) return;
        
        List<Competitor__c> competitorsToInsert = new List<Competitor__c>();
        
        for (Competitor__c comp : newList) {
            if (quoteMap.containsKey(comp.Quote__c)) {
                Id oppId = quoteMap.get(comp.Quote__c).OpportunityId;
                
                Competitor__c newOppComp = new Competitor__c();
                newOppComp.Account__c = comp.Account__c;
                newOppComp.Opportunity__c = oppId;
                
                competitorsToInsert.add(newOppComp);
            }
        }
        
        if (!competitorsToInsert.isEmpty()) {
            // Set flag to true BEFORE DML operation to safely bypass validation rules
            isAutoCreatingCompanion = true;
            try {
                insert competitorsToInsert;
            } finally {
                // ALWAYS reset flags in a finally block to ensure future operations work normally
                isAutoCreatingCompanion = false;
            }
        }
    }

    /**
     * SECTION 3: SYNC LOOKUP LOGIC
     * Context: BEFORE INSERT
     */
    public static void syncQuoteCompetitorToOpp(List<Competitor__c> newList) {
        Set<Id> quoteIds = new Set<Id>();
        for (Competitor__c comp : newList) {
            if (comp.Quote__c != null) {
                quoteIds.add(comp.Quote__c);
            }
        }
        
        if (quoteIds.isEmpty()) return;
        
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([
            SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds AND OpportunityId != null
        ]);
        
        for (Competitor__c comp : newList) {
            if (comp.Quote__c != null && quoteMap.containsKey(comp.Quote__c)) {
                comp.Opportunity__c = quoteMap.get(comp.Quote__c).OpportunityId;
            }
        }
    }
}