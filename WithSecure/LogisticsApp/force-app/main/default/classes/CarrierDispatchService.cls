/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 * Handles the dispatch and status synchronization of `ShipmentRequest__c` records with an external carrier system via REST API. 
 * Provides methods to dispatch shipments and update their statuses by querying a connected Salesforce org (Org B).<br><br>
 * 
 * **Key Features:**<br>
 * - Validates and dispatches a single shipment request marked 'Ready for Dispatch'.<br>
 * - Sends JSON payloads to a carrier API using a Named Credential.<br>
 * - Updates `ShipmentRequest__c` status based on success/failure from API response.<br>
 * - Queries Org B to retrieve dispatched shipment statuses using SOQL callout.<br><br>
 *
 * **Named Credential Used:**<br>
 * - `NCCarrierAPICredential`<br>
 *   • POST endpoint: `/apexrest/CarrierAPI`<br>
 *   • GET endpoint: `/data/v62.0/query?q=...`<br><br>
 * 
 * **Sample JSON Payload (Dispatch Request):**<br>
 * ```json
 * {
 *   "shipmentRequest": [
 *     {
 *       "ShipmentRequestId": "a01xx0000001234",
 *       "Name": "SR-00001",
 *       "Origin": "New York",
 *       "Region": "East",
 *       "Carrier": "DHL",
 *       "TrackingID": "TRK123456",
 *       "EstimatedDelivery": "2025-07-01"
 *     }
 *   ]
 * }
 * ```<br><br>
 * 
 * **Sample JSON Response (Dispatch API):**<br>
 * ```json
 * [
 *   {
 *     "ShipmentRequestId": "a01xx0000001234",
 *     "Name": "SR-00001",
 *     "Status": "Dispatched",
 *     "RequestStatus": "Success",
 *     "Message": "Shipment successfully dispatched."
 *   }
 * ]
 * ```<br><br>
 * 
 * **Use Case Scenarios:**<br>
 * - ✅ Successful dispatch of one shipment.<br>
 * - ✅ Successful update of dispatched shipment.<br>
 * - ❌ Error if no shipment found or status is incorrect.<br>
 * - ❌ Error if more than one shipment ID provided.<br>
 * - ❌ Dispatch failure due to HTTP/network error.<br>
 * - ❌ Carrier returns failure response — shipment is marked accordingly.<br>
 * 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 */


public with sharing class CarrierDispatchService {

    public class CarrierRequestWrapper {
        public String ShipmentRequestId;
        public String Name;
        public String Origin;
        public String Region;
        public String Carrier;
        public String TrackingID;
        public Date EstimatedDelivery;
    }

    public class CarrierResponseWrapper {
        public String ShipmentRequestId;
        public String Name;
        public String Status;
        public String RequestStatus;
        public String Message;
    }

    public class DispatchResultWrapper {
        @AuraEnabled public String Status;
        @AuraEnabled public String Message;
    }


    /**
     * @description
     * Dispatches a single `ShipmentRequest__c` record by sending a POST request to the carrier API.
     * The shipment must be in 'Ready for Dispatch' status to proceed.
     *
     * @param shipmentRequestIds A list of one ShipmentRequest Id to be dispatched.
     *
     * @return DispatchResultWrapper 
     * - Status: 'Success' or 'Error'
     * - Message: Human-readable message explaining the result
     *
     * @example
     * DispatchResultWrapper result = CarrierDispatchService.dispatchShipments(new List<Id>{'a01xx0000001234'});
     */
    @AuraEnabled
    public static DispatchResultWrapper dispatchShipments(List<Id> shipmentRequestIds) {
        DispatchResultWrapper result = new DispatchResultWrapper();
        // Query ShipmentRequest__c records
        
        List<ShipmentRequest__c> shipmentRequests = [SELECT Id, Name, Origin__c, Region__c, Carrier__c,
                        Status__c, Tracking_ID__c, Estimated_Delivery__c
                        FROM ShipmentRequest__c
                        WHERE Id IN :shipmentRequestIds
                        AND Status__c = 'Ready for Dispatch'];

        if (shipmentRequests.isEmpty()) {
            result.Status = 'Error';
            result.Message = 'No shipment requests found with the status "Ready for Dispatch".';
            return result;
        }

        if (shipmentRequests.size()>1) {
            result.Status = 'Error';
            result.Message = 'Multiple shipment requests cannot be dispatched at once.';
            return result;
        }

        // Build request payload
        List<CarrierRequestWrapper> requestList = new List<CarrierRequestWrapper>();
        Map<String, ShipmentRequest__c> shipmentMap = new Map<String, ShipmentRequest__c>();

        for (ShipmentRequest__c sr : shipmentRequests) {
            CarrierRequestWrapper req = new CarrierRequestWrapper();
            req.ShipmentRequestId = sr.Id;
            req.Name = sr.Name;
            req.Origin = sr.Origin__c;
            req.Region = sr.Region__c;
            req.Carrier = sr.Carrier__c;
            req.TrackingID = sr.Tracking_ID__c;
            req.EstimatedDelivery = sr.Estimated_Delivery__c;
            requestList.add(req);
            shipmentMap.put(sr.Id, sr);
        }

        // Serialize the request
        Map<String, Object> fullPayload = new Map<String, Object>();
        List<CarrierRequestWrapper> shipmentRequesttoDispatch = requestList.isEmpty() ? null : requestList;
        // CarrierRequestWrapper shipmentRequesttoDispatch = requestList.isEmpty() ? null : requestList[0];
        fullPayload.put('shipmentRequest', shipmentRequesttoDispatch);
        String jsonBody = JSON.serialize(fullPayload);
        // HTTP Callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:NCCarrierAPICredential/apexrest/CarrierAPI');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            ShipmentRequest__c sr = shipmentMap.get(shipmentRequesttoDispatch[0].shipmentRequestId);
            sr.Status__c = 'Dispatch Failed';
            update sr;
            result.Status = 'Error';
            result.Message = 'Dispatch Failed: ' + e.getMessage();
            return result;
        }

        // Handle the response
        if (res.getStatusCode() == 200) {
            system.debug('respbody'+res.getBody());
            List<CarrierResponseWrapper> responseList = (List<CarrierResponseWrapper>) JSON.deserialize(res.getBody(), List<CarrierResponseWrapper>.class);
            List<ShipmentRequest__c> toUpdate = new List<ShipmentRequest__c>();
            // CarrierResponseWrapper resp = (CarrierResponseWrapper) JSON.deserialize(res.getBody(), CarrierResponseWrapper.class);
            for (CarrierResponseWrapper resp : responseList) {
                if(resp!= null && resp.RequestStatus == 'Success') {
                    ShipmentRequest__c sr = shipmentMap.get(resp.ShipmentRequestId);
                    sr.Status__c = 'Dispatching';
                    toUpdate.add(sr);
                    // update sr;
                    result.Status = 'Success';
                    result.Message = 'Shipment dispatching: ' + resp.Status;
                    
                } else {
                    ShipmentRequest__c sr = shipmentMap.get(shipmentRequesttoDispatch[0].ShipmentRequestId);
                    sr.Status__c = 'Dispatch Failed';
                    toUpdate.add(sr);
                    //update sr;
                    result.Status = 'Error';
                    result.Message = 'Shipment dispatching: ' + resp.Message;
                    }
                }
                if(toUpdate.size() > 0) {
                update toUpdate;
                }
            } else {
                ShipmentRequest__c sr = shipmentMap.get(shipmentRequesttoDispatch[0].ShipmentRequestId);
                sr.Status__c = 'Dispatch Failed';
                update sr;
                result.Status = 'Error';
                result.Message = 'Shipment dispatching: ' + res.getStatusCode() +' '+ res.getStatus()+ '' + res.getBody();
            }
            return result;
    }

    // public static void manageShipmentStatus(List <ShipmentRequest__c> shipmentRequests) {
    //     if (shipmentRequests == null || shipmentRequests.isEmpty()) {
    //         return;
    //     }
    //     // Extract Ids
    //     List<String> shipmentIds = new List<String>();
    //     for (ShipmentRequest__c sr : shipmentRequests) {
    //         shipmentIds.add(sr.Id);
    //     }
    //     if (shipmentIds.isEmpty()) {
    //         return;
    //     }
    //     // Call REST API in Org B
    //     Http http = new Http();
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:NCCarrierAPICredential/apexrest/CarrierAPI/getShipmentStatusAPI');
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type', 'application/json');

    //     // You need to set the authorization header (Bearer token) for Org B's API here
    //     req.setHeader('Authorization', 'Bearer YOUR_ACCESS_TOKEN');

    //     // Serialize shipment Ids as JSON array
    //     req.setBody(JSON.serialize(shipmentIds));

    //     HttpResponse res = http.send(req);

    //     if (res.getStatusCode() == 200) {
    //         // Parse response
    //         Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    //         System.debug('Response from Org B: ' + responseMap);
    //         if (responseMap.containsKey('shipments')) {
    //         System.debug('Response from Org B: ' + responseMap.keySet());
    //             List<Object> shipmentsList = (List<Object>) responseMap.get('shipments');
    //             List<ShipmentRequest__c> toUpdate = new List<ShipmentRequest__c>();

    //             for (Object o : shipmentsList) {
    //                 Map<String, Object> shipment = (Map<String, Object>) o;
    //                 String shipmentId = (String) shipment.get('ShipmentRequestId');
    //                 String status = (String) shipment.get('Status');

    //                 if (status == 'Dispatched') {
    //                     toUpdate.add(new ShipmentRequest__c(Id = shipmentId, Status__c = 'Dispatched'));
    //                 }
    //             }

    //             if (!toUpdate.isEmpty()) {
    //                 update toUpdate;
    //             }
    //         }
    //     } else {
    //         System.debug('Error calling Org B API: ' + res.getStatus());
    //     }
    // }

    /**
     * @description
     * Updates local `ShipmentRequest__c` records by querying Org B to determine if shipments have been dispatched.
     * Uses a SOQL query via GET callout and updates status to 'Dispatched' if matched.
     *
     * @param shipmentRequests List of ShipmentRequest__c records whose status needs to be synced.
     *
     * @return void
     *
     * @example
     * CarrierDispatchService.updateShipmentStatus([   new ShipmentRequest__c(Id = 'a01xx0000001234')]);
     */
    public static void updateShipmentStatus(List <ShipmentRequest__c> shipmentRequests) {
    List<String> shipmentIds = new List<String>();
    for (ShipmentRequest__c sr : shipmentRequests) {
        shipmentIds.add(sr.Id);
    }

    if (shipmentIds.isEmpty()) return;

    // Build SOQL for Org B query: escape and join IDs into string
    String idListString = '\'' + String.join(shipmentIds, '\',\'') + '\'';
    String soql = 'SELECT External_Id__c, Status__c FROM DispatchCarrier__c WHERE External_Id__c IN (' + idListString + ') AND Status__c = \'Dispatched\'';

    // Encode SOQL for URL
    String encodedSOQL = EncodingUtil.urlEncode(soql, 'UTF-8');

    // REST API endpoint for Org B (standard query endpoint via Named Credential)
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:NCCarrierAPICredential/data/v62.0/query?q=' + encodedSOQL);
    req.setMethod('GET');  // Standard query is GET
    req.setHeader('Content-Type', 'application/json');

    Http http = new Http();
    HttpResponse res = http.send(req);

    if (res.getStatusCode() == 200) {
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) result.get('records');

        // Build map of External_Id__c to DispatchCarrier data
        Set<String> dispatchedIds = new Set<String>();
        for (Object obj : records) {
            Map<String, Object> record = (Map<String, Object>) obj;
            dispatchedIds.add((String) record.get('External_Id__c'));
        }

        // Update ShipmentRequest__c in Org A
        List<ShipmentRequest__c> updates = new List<ShipmentRequest__c>();
        for (ShipmentRequest__c sr : shipmentRequests) {
            if (dispatchedIds.contains(sr.Id)) {
                sr.Status__c = 'Dispatched';
                updates.add(sr);
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    } else {
        System.debug('Error from Org B: ' + res.getStatus() + ' ' + res.getBody());
    }

    }
}