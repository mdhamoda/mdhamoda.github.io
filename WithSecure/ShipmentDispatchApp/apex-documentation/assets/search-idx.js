export default [
    {
        "title": "Home",
        "fileName": "index.html",
        "text": "Home Project Home Use the apexdox.homePagePath  setting to point to an HTML file that contains details about your project. The body of the HTML will show up here instead of this default!"
    },
    {
        "title": "CarrierAPI",
        "fileName": "CarrierAPI.html",
        "text": "CarrierAPI : 🔧 Key Features:  - Retrieves shipments with optional region filter(cacheable for LWC/Aura) - Updates a list of ShipmentRequest__c records with error handling - Publishes platform events(ShipmentRequestEvent__e ) for shipment changes ⚙️ Use Cases:  - Display shipment requests filtered by region in UI - Update shipment status or details via client components - Trigger downstream processing via event publication 📤 Event:  - Platform Event Published: ShipmentRequestEvent__e  @AuraEnabled Methods:  - getShipmentsByRegion(String region)  → List<ShipmentRequest__c>  - updateShipments(List<ShipmentRequest__c>)  → void  @return  - getShipmentsByRegion()  returns up to 200 shipment records filtered by region or all if 'All'  is passed - updateShipments()  updates provided records and throws AuraHandledException  on DML failure @namedcredential  - None @sampleinput  getShipmentsByRegion('East')  @sampleoutput  List of ShipmentRequest__c  records sorted by CreatedDate Signature @RestResource(urlMapping='/CarrierAPI') global with sharing class CarrierAPI Authors : Manigandan Dhamodaran, : Manigandan Dhamodaran @last modified on  : 06-26-2025 @last modified by  : Manigandan Dhamodaran Example event { \"ShipmentId__c\": \"a01xx0000001234\", \"Status__c\": \"Dispatched\" } CarrierAPI Methods handleCarrierData(shipmentRequest) simulateLatency(milliseconds) handleCarrierData(shipmentRequest) Signature @HttpPost global static List<CarrierResponseWrapper> handleCarrierData(List<CarrierRequestWrapper> shipmentRequest) simulateLatency(milliseconds) Signature private static List<CarrierResponseWrapper> simulateLatency(Integer milliseconds) CarrierAPI.CarrierRequestWrapper Signature global class CarrierRequestWrapper CarrierAPI.CarrierRequestWrapper Properties Name Signature Carrier public String Carrier EstimatedDelivery public Date EstimatedDelivery Name public String Name Origin public String Origin Region public String Region ShipmentRequestId public String ShipmentRequestId TrackingID public String TrackingID CarrierAPI.CarrierResponseWrapper Signature global class CarrierResponseWrapper CarrierAPI.CarrierResponseWrapper Properties Name Signature Message public String Message Name public String Name RequestStatus public String RequestStatus ShipmentRequestId public String ShipmentRequestId Status public String Status"
    },
    {
        "title": "CarrierAPITest",
        "fileName": "CarrierAPITest.html",
        "text": "CarrierAPITest : Signature @isTest private class CarrierAPITest Author : Manigandan Dhamodaran CarrierAPITest Methods testHandleCarrierData_EmptyInput() testHandleCarrierData_MissingShipmentRequestId() testHandleCarrierData_SuccessfulInsert() testHandleCarrierData_TooManyRequests() testHandleCarrierData_TriggerSimulatedLatency() testHandleCarrierData_UpdateExisting() testHandleCarrierData_EmptyInput() Signature @isTest static void testHandleCarrierData_EmptyInput() testHandleCarrierData_MissingShipmentRequestId() Signature @isTest static void testHandleCarrierData_MissingShipmentRequestId() testHandleCarrierData_SuccessfulInsert() Signature @isTest static void testHandleCarrierData_SuccessfulInsert() testHandleCarrierData_TooManyRequests() Signature @isTest static void testHandleCarrierData_TooManyRequests() testHandleCarrierData_TriggerSimulatedLatency() Signature @isTest static void testHandleCarrierData_TriggerSimulatedLatency() testHandleCarrierData_UpdateExisting() Signature @isTest static void testHandleCarrierData_UpdateExisting()"
    },
    {
        "title": "DispatchStatusUpdaterBatch",
        "fileName": "DispatchStatusUpdaterBatch.html",
        "text": "DispatchStatusUpdaterBatch : Signature global class DispatchStatusUpdaterBatch implements Database.Batchable<SObject> Author : Manigandan Dhamodaran DispatchStatusUpdaterBatch Methods execute(bc, scope) finish(bc) start(bc) execute(bc, scope) Signature global void execute(Database.BatchableContext bc, List<DispatchCarrier__c> scope) finish(bc) Signature global void finish(Database.BatchableContext bc) start(bc) Signature global Database.QueryLocator start(Database.BatchableContext bc)"
    },
    {
        "title": "DispatchStatusUpdaterBatchTest",
        "fileName": "DispatchStatusUpdaterBatchTest.html",
        "text": "DispatchStatusUpdaterBatchTest : Signature @isTest private class DispatchStatusUpdaterBatchTest Author : Manigandan Dhamodaran DispatchStatusUpdaterBatchTest Methods testBatchAlternatingStatus() testBatchAlternatingStatus() Signature @isTest static void testBatchAlternatingStatus()"
    },
    {
        "title": "DispatchStatusUpdaterScheduler",
        "fileName": "DispatchStatusUpdaterScheduler.html",
        "text": "DispatchStatusUpdaterScheduler : Signature global class DispatchStatusUpdaterScheduler implements Schedulable Author : Manigandan Dhamodaran DispatchStatusUpdaterScheduler Methods execute(sc) execute(sc) Signature global void execute(SchedulableContext sc)"
    },
    {
        "title": "DispatchStatusUpdaterSchedulerTest",
        "fileName": "DispatchStatusUpdaterSchedulerTest.html",
        "text": "DispatchStatusUpdaterSchedulerTest : Signature @isTest private class DispatchStatusUpdaterSchedulerTest Author : Manigandan Dhamodaran DispatchStatusUpdaterSchedulerTest Methods testSchedulerFiresBatch() testSchedulerFiresBatch() Signature @isTest static void testSchedulerFiresBatch()"
    },
    {
        "title": "GetShipmentStatusAPI",
        "fileName": "GetShipmentStatusAPI.html",
        "text": "GetShipmentStatusAPI : Shipment status polling API from Org A to Org B Signature @RestResource(urlMapping='/CarrierAPI/getShipmentStatusAPI') global with sharing class GetShipmentStatusAPI Author : Manigandan Dhamodaran @last modified on  : 06-25-2025 @last modified by  : Manigandan Dhamodaran GetShipmentStatusAPI Methods checkShipmentStatuses() checkShipmentStatuses() Signature @HttpPost global static ShipmentStatusResponse checkShipmentStatuses() GetShipmentStatusAPI.ShipmentStatusRequest Signature global class ShipmentStatusRequest GetShipmentStatusAPI.ShipmentStatusResponse Signature global class ShipmentStatusResponse GetShipmentStatusAPI.ShipmentStatusResponse Properties Name Signature Message public String Message RequestStatus public String RequestStatus shipments public List<ShipmentStatusWrapper> shipments GetShipmentStatusAPI.ShipmentStatusWrapper Signature global class ShipmentStatusWrapper GetShipmentStatusAPI.ShipmentStatusWrapper Properties Name Signature Message public String Message Name public String Name RequestStatus public String RequestStatus ShipmentRequestId public String ShipmentRequestId Status public String Status"
    }
];
