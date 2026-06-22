@isTest
private class OfferTriggerHandler_Test {

    @isTest
    static void testSingleOfferInsertion() {
        // Create an independent parent opportunity
        Opportunity oppAlpha = new Opportunity(
            Name = 'Opp Alpha',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'EIT'
        );
        insert oppAlpha;
        
        // Insert the very first offer
        Offer__c offer1 = new Offer__c(Name = 'Offer 1', Opportunity__c = oppAlpha.Id);
        
        Test.startTest();
        insert offer1;
        Test.stopTest();
        
        // Re-query to verify the trigger auto-calculated the field correctly
        offer1 = [SELECT Identifier__c FROM Offer__c WHERE Id = :offer1.Id];
        System.assertEquals('EIT-000', offer1.Identifier__c, 'The first offer should start at index 000');
    }

    @isTest
    static void testBulkOfferInsertion() {
        // Create an independent parent opportunity
        Opportunity oppAlpha = new Opportunity(
            Name = 'Opp Alpha',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'EIT'
        );
        insert oppAlpha;
        
        // Prepare multiple offers to insert simultaneously (Simulating Bulk Data Load)
        List<Offer__c> bulkOffers = new List<Offer__c>();
        for (Integer i = 0; i < 5; i++) {
            bulkOffers.add(new Offer__c(Name = 'Bulk Offer ' + i, Opportunity__c = oppAlpha.Id));
        }
        
        Test.startTest();
        insert bulkOffers;
        Test.stopTest();
        
        // Re-query records and verify the numbers increment sequentially within the same transaction batch
        List<Offer__c> insertedOffers = [SELECT Identifier__c FROM Offer__c WHERE Opportunity__c = :oppAlpha.Id ORDER BY CreatedDate ASC];
        
        System.assertEquals(5, insertedOffers.size(), 'All 5 bulk records should be inserted');
        System.assertEquals('EIT-000', insertedOffers[0].Identifier__c);
        System.assertEquals('EIT-001', insertedOffers[1].Identifier__c);
        System.assertEquals('EIT-002', insertedOffers[2].Identifier__c);
        System.assertEquals('EIT-003', insertedOffers[3].Identifier__c);
        System.assertEquals('EIT-004', insertedOffers[4].Identifier__c);
    }

    @isTest
    static void testOfferReparenting() {
        // Create both opportunities directly inside the test method
        Opportunity oppAlpha = new Opportunity(
            Name = 'Opp Alpha',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'EIT'
        );
        Opportunity oppBeta = new Opportunity(
            Name = 'Opp Beta',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Identifier__c = 'ABC'
        );
        insert new List<Opportunity>{oppAlpha, oppBeta};
        
        // Setup an initial offer under Alpha (will be EIT-000)
        Offer__c offer = new Offer__c(Name = 'Moving Offer', Opportunity__c = oppAlpha.Id);
        insert offer;
        
        // Setup an existing baseline offer under Beta so Beta's next sequence is 001
        Offer__c baselineBetaOffer = new Offer__c(Name = 'Baseline Beta', Opportunity__c = oppBeta.Id);
        insert baselineBetaOffer;
        
        Test.startTest();
        // Change the parent opportunity (Re-parenting)
        offer.Opportunity__c = oppBeta.Id;
        update offer;
        Test.stopTest();
        
        // Verify the identifier updated dynamically to match Opp Beta's sequence baseline
        offer = [SELECT Identifier__c FROM Offer__c WHERE Id = :offer.Id];
        System.assertEquals('ABC-001', offer.Identifier__c, 'The identifier should dynamically update to match the new parent sequence');
    }
}