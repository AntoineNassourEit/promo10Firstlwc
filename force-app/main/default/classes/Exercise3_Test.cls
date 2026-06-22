@isTest
private class Exercise3_Test {

    @isTest
    static void testSyncQuoteCompetitorToOpp() {
        // Create dependencies isolated within this test execution
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert q;

        // Instantiate the test Competitor record
        Competitor__c comp = new Competitor__c(
            Account__c = acc.Id,
            Quote__c = q.Id
        );
        List<Competitor__c> newList = new List<Competitor__c>{ comp };

        // Execute logic
        Test.startTest();
        Exercise3.syncQuoteCompetitorToOpp(newList);
        Test.stopTest();

        // Verify results
        Assert.areEqual(opp.Id, newList[0].Opportunity__c, 'Opportunity ID should match the Quote\'s Opportunity ID.');
    }

    @isTest
    static void testCreateCompanionOppCompetitors() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert q;

        Competitor__c comp = new Competitor__c(
            Account__c = acc.Id,
            Quote__c = q.Id
        );
        List<Competitor__c> newList = new List<Competitor__c>{ comp };

        Test.startTest();
        Exercise3.createCompanionOppCompetitors(newList);
        Test.stopTest();

        // Verify that a companion Opportunity Competitor record was auto-created and inserted
        List<Competitor__c> insertedComps = [SELECT Id, Account__c, Opportunity__c, Quote__c FROM Competitor__c];
        Assert.areEqual(1, insertedComps.size(), 'A companion competitor record should have been auto-inserted.');
        Assert.areEqual(acc.Id, insertedComps[0].Account__c, 'Account ID must match.');
        Assert.isNull(insertedComps[0].Quote__c, 'Companion should be an Opportunity link, not a Quote link.');
    }

    @isTest
    static void testCheckCompetitorLinks_ValidInsert() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert q;

        Competitor__c comp = new Competitor__c(
            Account__c = acc.Id,
            Quote__c = q.Id
        );
        List<Competitor__c> newList = new List<Competitor__c>{ comp };

        Test.startTest();
        Exercise3.checkCompetitorLinks(newList, null, null);
        Test.stopTest();

        Assert.isFalse(newList[0].hasErrors(), 'No errors should be appended to a valid record.');
    }

    @isTest
    static void testCheckCompetitorLinks_DuplicateQuoteValidation() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert q;

        // Insert baseline duplicate record directly to database
        Competitor__c existingComp = new Competitor__c(
            Account__c = acc.Id,
            Quote__c = q.Id
        );
        insert existingComp;

        // Create a separate instance to pass into validation logic
        Competitor__c duplicateComp = new Competitor__c(
            Account__c = acc.Id,
            Quote__c = q.Id
        );
        List<Competitor__c> newList = new List<Competitor__c>{ duplicateComp };

        Test.startTest();
        Exercise3.checkCompetitorLinks(newList, null, null);
        Test.stopTest();

        Assert.isTrue(newList[0].hasErrors(), 'The record should have been marked with a validation error.');
        Assert.areEqual('This account is already related to a quote through a competitor', newList[0].getErrors()[0].getMessage());
    }

    @isTest
    static void testCheckCompetitorLinks_DuplicateOppValidation() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        // Insert baseline duplicate record directly to database
        Competitor__c existingComp = new Competitor__c(
            Account__c = acc.Id,
            Opportunity__c = opp.Id
        );
        insert existingComp;

        // Create a separate instance to pass into validation logic
        Competitor__c duplicateComp = new Competitor__c(
            Account__c = acc.Id,
            Opportunity__c = opp.Id
        );
        List<Competitor__c> newList = new List<Competitor__c>{ duplicateComp };

        Test.startTest();
        Exercise3.checkCompetitorLinks(newList, null, null);
        Test.stopTest();

        Assert.isTrue(newList[0].hasErrors(), 'The record should have been marked with a validation error.');
        Assert.areEqual('This account is already related to an opportunity through a competitor', newList[0].getErrors()[0].getMessage());
    }
}