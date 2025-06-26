/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 *  * @group ShipmentDispatchApp
**/
@isTest
private class CarrierAPITest {

    @isTest
    static void testHandleCarrierData_SuccessfulInsert() {
        CarrierAPI.CarrierRequestWrapper req = new CarrierAPI.CarrierRequestWrapper();
        req.ShipmentRequestId = 'TEST001';
        req.Name = 'Test Shipment';
        req.Origin = 'EMEA';
        req.Region = 'EMEA';
        req.Carrier = 'DHL';
        req.TrackingID = 'ABC123456';
        req.EstimatedDelivery = Date.today().addDays(5);

        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(new List<CarrierAPI.CarrierRequestWrapper>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Success', responses[0].RequestStatus);
        System.assertEquals('Dispatching', responses[0].Status);
        System.assertEquals('TEST001', responses[0].ShipmentRequestId);
    }

    @isTest
    static void testHandleCarrierData_UpdateExisting() {
        // Create a DispatchCarrier__c record to simulate update
        DispatchCarrier__c existing = new DispatchCarrier__c(
            External_Id__c = 'EXIST001',
            Name = 'Old Name',
            Status__c = 'Dispatching',
            Tracking_ID__c = 'XYZ789'
        );
        insert existing;

        CarrierAPI.CarrierRequestWrapper req = new CarrierAPI.CarrierRequestWrapper();
        req.ShipmentRequestId = 'EXIST001';
        req.Name = 'Updated Name';
        req.Origin = 'EMEA';
        req.Region = 'EMEA';
        req.Carrier = 'FedEx';
        req.TrackingID = 'XYZ789';
        req.EstimatedDelivery = Date.today().addDays(3);

        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(new List<CarrierAPI.CarrierRequestWrapper>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Success', responses[0].RequestStatus);
        System.assertEquals('Dispatching', responses[0].Status);
    }

    @isTest
    static void testHandleCarrierData_MissingShipmentRequestId() {
        CarrierAPI.CarrierRequestWrapper req = new CarrierAPI.CarrierRequestWrapper();
        req.Name = 'No ID';
        req.TrackingID = 'NOP123';

        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(new List<CarrierAPI.CarrierRequestWrapper>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Error', responses[0].RequestStatus);
        System.assertEquals('Missing ShipmentRequestId', responses[0].Message);
    }

    @isTest
    static void testHandleCarrierData_EmptyInput() {
        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(new List<CarrierAPI.CarrierRequestWrapper>());
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Error', responses[0].RequestStatus);
        System.assertEquals('No shipment requests provided.', responses[0].Message);
    }

    @isTest
    static void testHandleCarrierData_TooManyRequests() {
        CarrierAPI.CarrierRequestWrapper req1 = new CarrierAPI.CarrierRequestWrapper();
        req1.ShipmentRequestId = 'REQ001';
        CarrierAPI.CarrierRequestWrapper req2 = new CarrierAPI.CarrierRequestWrapper();
        req2.ShipmentRequestId = 'REQ002';

        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(
            new List<CarrierAPI.CarrierRequestWrapper>{ req1, req2 }
        );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Error', responses[0].RequestStatus);
        System.assertEquals('Too many shipment requests. Limit is 1.', responses[0].Message);
    }

    @isTest
    static void testHandleCarrierData_TriggerSimulatedLatency() {
        CarrierAPI.CarrierRequestWrapper req = new CarrierAPI.CarrierRequestWrapper();
        req.ShipmentRequestId = 'LATENCY001';
        req.Name = 'Latency Shipment';
        req.TrackingID = '123-TRIGGER'; // This will trigger simulateLatency()

        Test.startTest();
        List<CarrierAPI.CarrierResponseWrapper> responses = CarrierAPI.handleCarrierData(
            new List<CarrierAPI.CarrierRequestWrapper>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals('Error', responses[0].RequestStatus);
        System.assert(responses[0].Message.contains('CPU time limit'), 'Latency simulation should fail safely');
    }
}
