@isTest
public class ContactTriggerHandlerTest {
    
    @isTest
    static void TestContactCount() {
        Account testAcc = new Account(Name = 'Account to Test');
        insert testAcc;
        
        List<Contact> contactsToInsert = new List<Contact>{
            new Contact(LastName = 'Doe', AccountId = testAcc.Id), 
            new Contact(FirstName = 'Alice', LastName = 'Brown', AccountId = testAcc.Id),
            new Contact(FirstName = 'Alice', LastName = 'James', AccountId = testAcc.Id),
            new Contact(FirstName = 'Bob', LastName = 'Smith', AccountId = testAcc.Id),   
            new Contact(FirstName = 'Charlie', LastName = 'James', AccountId = testAcc.Id) 
        };
        
        insert contactsToInsert;
        
        Test.startTest();
        
        Account checkAccAfterInsert = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(2, checkAccAfterInsert.Contact_Count__c, 'Expected 2 matching contacts on initial insert.');
        
        Contact conToUpdate = [SELECT Id, FirstName FROM Contact WHERE LastName = 'Doe' AND FirstName = null LIMIT 1];
        conToUpdate.FirstName = 'John'; 
        update conToUpdate;
        
        Contact conToDelete = [SELECT Id FROM Contact WHERE LastName = 'Smith' LIMIT 1];
        delete conToDelete;
        
        Account checkAccAfterDelete = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(0, checkAccAfterDelete.Contact_Count__c, 'Expected count to drop to 0 after deleting the remaining match.');
        
        undelete conToDelete;
        Test.stopTest();
        
        Account checkAccAfterUndelete = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(1, checkAccAfterUndelete.Contact_Count__c, 'Expected count to return to 1 after undeleting record.');
    } 
}