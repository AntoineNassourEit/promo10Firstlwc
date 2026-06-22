public with sharing class Exercise5 {

   public static void validateOverlappingReservations(List<Resource_Reservation__c> newReservations, Map<Id, Resource_Reservation__c> oldReservationsMap) {
        
        //Step 1 
        Set<String> resourcesToCheck = new Set<String>();
        Date earliestStart = null;
        Date latestEnd = null;

        for(Resource_Reservation__c newRes : newReservations){
            if (newRes.Reserved_Resource__c == null || newRes.Start_Date__c == null || newRes.End_Date__c == null) {
                continue; 
            }
            if (oldReservationsMap != null && oldReservationsMap.containsKey(newRes.Id)) {
                Resource_Reservation__c oldRes = oldReservationsMap.get(newRes.Id);
   
                if (newRes.Reserved_Resource__c == oldRes.Reserved_Resource__c &&
                    newRes.Start_Date__c == oldRes.Start_Date__c &&
                    newRes.End_Date__c == oldRes.End_Date__c) {
                    continue; 
                }
            }
            resourcesToCheck.add(newRes.Reserved_Resource__c);
            if (earliestStart == null || newRes.Start_Date__c < earliestStart) {
                earliestStart = newRes.Start_Date__c;
            }
            if (latestEnd == null || newRes.End_Date__c > latestEnd) {
                latestEnd = newRes.End_Date__c;
            }
        }

        if (resourcesToCheck.isEmpty()) return;

        //Step 2
        List<Resource_Reservation__c> existingReservations = [
            SELECT Id, Reserved_Resource__c, Start_Date__c, End_Date__c 
            FROM Resource_Reservation__c 
            WHERE Reserved_Resource__c IN :resourcesToCheck
              AND Start_Date__c < :latestEnd 
              AND End_Date__c > :earliestStart
        ];

        //Step 3
        for(Resource_Reservation__c newRes : newReservations){
            for(Resource_Reservation__c existingRes : existingReservations){
            

                if (newRes.Reserved_Resource__c == existingRes.Reserved_Resource__c) {
                    Boolean isOverlapping = (newRes.Start_Date__c < existingRes.End_Date__c) && (newRes.End_Date__c > existingRes.Start_Date__c);
                    
                    if (isOverlapping) {
                        newRes.addError('Conflict detected: The resource "' + newRes.Reserved_Resource__c +'" is already reserved during this timeframe. (Conflict Record ID: ' + existingRes.Id + ').');
                        break; 
                    }
                }
            }
        }
    }
}