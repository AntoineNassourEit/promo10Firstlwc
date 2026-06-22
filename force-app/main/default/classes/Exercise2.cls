public class Exercise2 {
    public static void countContactOccurences(List<Contact> currentContacts, Map<Id, Contact> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        
        if (currentContacts != null) {
            for (Contact con : currentContacts) {
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
                if (oldMap != null && oldMap.containsKey(con.Id)) {
                    Contact oldCon = oldMap.get(con.Id);
                    if (oldCon.AccountId != null && oldCon.AccountId != con.AccountId) {
                        accountIds.add(oldCon.AccountId);
                    }
            }
        }
        }
        
        if (accountIds.isEmpty()) {
            return;
        }
        
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (Id accId : accountIds) {
            accountsToUpdate.put(accId, new Account(Id = accId, Contact_Count__c = 0));
        }
        
        List<AggregateResult> results = [
            SELECT AccountId, COUNT(Id) total
            FROM Contact
            WHERE AccountId IN :accountIds 
            AND (FirstName = null OR LastName = 'Smith')
            GROUP BY AccountId
            ];
        
        for (AggregateResult ar : results) {
            Id accId = (Id)ar.get('AccountId');
            Integer count = (Integer)ar.get('total');
            if (accountsToUpdate.containsKey(accId)) {
                accountsToUpdate.get(accId).Contact_Count__c = count;
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
        
      
}
    
}