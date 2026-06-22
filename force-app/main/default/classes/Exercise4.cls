public with sharing class Exercise4 {
    
    public static void executeIdentifierLogic(List<Offer__c> triggerNew, Map<Id, Offer__c> triggerOldMap) {
        Set<Id> oppIds = new Set<Id>();
        List<Offer__c> offersToProcess = new List<Offer__c>();
        
        for (Offer__c off : triggerNew) {
            Boolean isInsert = (triggerOldMap == null);
            Boolean isReparented = (!isInsert && off.Opportunity__c != triggerOldMap.get(off.Id).Opportunity__c);
            
            if ((isInsert || isReparented) && off.Opportunity__c != null) {
                oppIds.add(off.Opportunity__c);
                offersToProcess.add(off);
            }
        }
        
        if (oppIds.isEmpty()) return;
        
       
        Map<Id, Opportunity> oppsWithOffers = new Map<Id, Opportunity>([
            SELECT Id, Identifier__c, 
                   (SELECT Id FROM Offers__r ORDER BY CreatedDate ASC) 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ]);
        
        Map<Id, Integer> oppToNextCountMap = new Map<Id, Integer>();
        for (Id oppId : oppsWithOffers.keySet()) {
            oppToNextCountMap.put(oppId, oppsWithOffers.get(oppId).Offers__r.size());
        }
        
        for (Offer__c off : offersToProcess) {
            Opportunity parentOpp = oppsWithOffers.get(off.Opportunity__c);
            
            if (parentOpp != null && parentOpp.Identifier__c != null) {
                Integer nextCount = oppToNextCountMap.get(off.Opportunity__c);
                String formattedCounter = String.valueOf(nextCount).leftPad(3, '0');
                
                off.Identifier__c = parentOpp.Identifier__c + '-' + formattedCounter;
                
                // Keep incrementing mapping accurate across single bulk payloads
                oppToNextCountMap.put(off.Opportunity__c, nextCount + 1);
            }
        }
    }
}