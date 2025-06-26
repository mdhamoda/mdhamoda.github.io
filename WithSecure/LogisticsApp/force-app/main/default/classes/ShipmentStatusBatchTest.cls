/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
private class ShipmentStatusBatchTest {

    @testSetup
    static void setupData() {
        // Insert test ShipmentRequest__c
        ShipmentRequest__c sr = new ShipmentRequest__c(
            Name = 'Test Shipment',
            Origin__c = 'EMEA',
            Region__c = 'EMEA',
            Carrier__c = 'TestCarrier',
            Tracking_ID__c = 'TRK123456',
            Estimated_Delivery__c = Date.today().addDays(5),
            Status__c = 'Dispatching'
        );
        insert sr;
    }

    @isTest
    static void testBatchExecution() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new CarrierDispatchServiceTest.MockHttpResponseGenerator(sr.Id, 'ShipmentStatusQueryAPI', null));

        Test.startTest();
        ShipmentStatusBatch batch = new ShipmentStatusBatch();
        Database.executeBatch(batch, 200); // batch size is optional
        Test.stopTest();

        // Optional: check that records are updated as expected
        ShipmentRequest__c updated = [SELECT Id, Status__c FROM ShipmentRequest__c WHERE Id = :sr.Id];
        
            System.assertEquals('Dispatched', updated.Status__c, 'Shipment should be updated to Dispatched');
    }
}
