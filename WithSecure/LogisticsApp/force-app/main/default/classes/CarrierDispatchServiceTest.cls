/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
public class CarrierDispatchServiceTest {

    // Mock HTTP callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public String recordId;
        public String apiSpec;
        public String unitTestSpec;

        public MockHttpResponseGenerator(String recordId, String apiSpec, String unitTestSpec) {
            this.recordId = recordId;
            this.apiSpec = apiSpec;
            this.unitTestSpec = unitTestSpec;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String jsonBody;
            if ( req.getEndpoint().contains('CarrierAPI') && apiSpec == 'CarrierAPI') {
                // Return fake success response for dispatch API
                jsonBody = '[{"ShipmentRequestId":"'+recordId+'","Name":"Test Name","Status":"Dispatched","RequestStatus":"Success","Message":"Shipment dispatching successful."}]';
                res.setBody(jsonBody);
                if (apiSpec == 'CarrierAPI' && unitTestSpec =='Status_500') {
                    // Simulate error response for unit test
                    res.setStatusCode(500);
                    jsonBody = '{"error":"Internal_Server_Error"}';
                    res.setBody(jsonBody);
                } else if (apiSpec == 'CarrierAPI' && unitTestSpec == 'ErrorStatus') {
                    // Simulate error status response for unit test
                    jsonBody = '[{"ShipmentRequestId":"'+recordId+'","Name":"Test Name","Status":"Error","RequestStatus":"Error","Message":"Error_dispatching_shipment"}]';
                    res.setBody(jsonBody);
                }
            } else if (req.getEndpoint().contains('/query') && apiSpec == 'ShipmentStatusQueryAPI') {
                // Return fake response from Org B's query
                jsonBody = '{"records" : [{"External_Id__c":"'+recordId+'","Status__c":"Dispatched"}]}';
                res.setBody(jsonBody);
            }
            return res;
        }
    }

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
            Status__c = 'Ready for Dispatch'
        );
        insert sr;
    }

    @isTest
    static void testDispatchShipments_success() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(sr.id, 'CarrierAPI',''));

        Test.startTest();
        CarrierDispatchService.DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(new List<Id>{sr.Id});
        Test.stopTest();

        System.assertEquals('Success', result.Status);
        System.assert(result.Message.contains('Shipment dispatching'));
    }

    @isTest
    static void testDispatchShipments_FailedResponse() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(sr.id, 'CarrierAPI','Status_500'));

        Test.startTest();
        CarrierDispatchService.DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(new List<Id>{sr.Id});
        Test.stopTest();

        System.assertEquals('Error', result.Status);
        System.assert(result.Message.contains('Internal_Server_Error'));
    }

    @isTest
    static void testDispatchShipments_ErrorStatus() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(sr.id, 'CarrierAPI','ErrorStatus'));

        Test.startTest();
        CarrierDispatchService.DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(new List<Id>{sr.Id});
        Test.stopTest();

        System.assertEquals('Error', result.Status);
        System.assert(result.Message.contains('Error_dispatching_shipment'));
    }

    @isTest
    static void testDispatchShipments_noEligibleRecords() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];
        sr.Status__c = 'Dispatched';
        update sr;

        Test.startTest();
        CarrierDispatchService.DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(new List<Id>{sr.Id});
        Test.stopTest();

        System.assertEquals('Error', result.Status);
        System.assertEquals('No shipment requests found with the status "Ready for Dispatch".', result.Message);
    }

    @isTest
    static void testDispatchShipments_multipleRecords() {
        ShipmentRequest__c sr2 = new ShipmentRequest__c(
            Name = 'Second Shipment',
            Origin__c = 'EMEA',
            Destination__c = 'India',
            Carrier__c = 'TestCarrier',
            Tracking_ID__c = 'TRK654321',
            Estimated_Delivery__c = Date.today().addDays(3),
            Status__c = 'Ready for Dispatch'
        );
        insert sr2;

        List<ShipmentRequest__c> srs = [SELECT Id FROM ShipmentRequest__c WHERE Status__c = 'Ready for Dispatch'];
        List<Id> ids = new List<Id>();
        for (ShipmentRequest__c s : srs) ids.add(s.Id);

        Test.startTest();
        CarrierDispatchService.DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(ids);
        Test.stopTest();

        System.assertEquals('Error', result.Status);
        System.assertEquals('Multiple shipment requests cannot be dispatched at once.', result.Message);
    }

    @isTest
    static void testUpdateShipmentStatus() {
        ShipmentRequest__c sr = [SELECT Id FROM ShipmentRequest__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(sr.id, 'ShipmentStatusQueryAPI',''));
        sr.Status__c = 'Dispatching';
        update sr;

        Test.startTest();
        CarrierDispatchService.updateShipmentStatus(new List<ShipmentRequest__c>{sr});
        Test.stopTest();

        ShipmentRequest__c updatedSR = [SELECT Status__c FROM ShipmentRequest__c WHERE Id = :sr.Id];
        System.assertEquals('Dispatched', updatedSR.Status__c);
    }

}
