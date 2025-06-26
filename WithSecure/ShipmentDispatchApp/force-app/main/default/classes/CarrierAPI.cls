/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 * 
 * CarrierAPI- This Apex REST service processes carrier dispatch shipment requests.<br/>
 * Accepts a single shipment request and creates or updates a DispatchCarrier__c record.<br/>
 * If the TrackingID starts with '123', it simulates a processing delay for testing/debugging.
 * @group ShipmentDispatchApp
 * Last Modified on: 2025-06-26
 * @urlMapping /CarrierAPI
 */


@RestResource(urlMapping='/CarrierAPI')
global with sharing class CarrierAPI {

    // Request Wrapper
    global class CarrierRequestWrapper {
        public String ShipmentRequestId;
        public String Name;
        public String Origin;
        public String Region;
        public String Carrier;
        public String TrackingID;
        public Date EstimatedDelivery;
    }

    // Response Wrapper
    global class CarrierResponseWrapper {
        public String ShipmentRequestId;
        public String Name;
        public String Status = 'Dispatching';
        public String RequestStatus;
        public String Message;
    }

    private static List<CarrierResponseWrapper> simulateLatency(Integer milliseconds) {
    Long start = DateTime.now().getTime();
    CarrierResponseWrapper errorResp = new CarrierResponseWrapper();
    List<CarrierResponseWrapper> errorRespList = new List<CarrierResponseWrapper>();
    while (DateTime.now().getTime() - start < milliseconds) {
        // Busy wait loop (simulate latency, not ideal in real logic)
        if(Limits.getCpuTime() > Limits.getLimitCpuTime() - 4000) {
            // If CPU time is close to limit, exit to avoid hitting governor limits
            errorResp.RequestStatus = 'Error';
            errorResp.Message = 'CPU time limit exceeded during latency simulation.';
            errorRespList.add(errorResp);
            return errorRespList;
        }
    }
    return errorRespList;
    }


     /**
     * @name handleCarrierData
     * @description Processes the HTTP POST request containing a shipment dispatch request.<br/>
     * Validates input, performs upsert on DispatchCarrier__c using External_Id__c, and returns results.<br/>
     * If tracking ID starts with '123', simulates latency for testing.<br/>
     * Handles and returns detailed success/failure responses.
     * @param shipmentRequest List of CarrierRequestWrapper objects (limited to one)
     * @return List of CarrierResponseWrapper responses
     * @httpMethod POST
     * @restResource /CarrierAPI
     */

    @HttpPost
    global static List<CarrierResponseWrapper> handleCarrierData(List<CarrierRequestWrapper> shipmentRequest) {
        // This method is now global static to allow access from other classes
    // global static List<CarrierResponseWrapper> handleCarrierData() {
    // global static CarrierResponseWrapper handleCarrierData(CarrierRequestWrapper shipmentRequest) {
        List<CarrierResponseWrapper> responseList = new List<CarrierResponseWrapper>();
        // List<CarrierRequestWrapper>  shipmentRequest = (List<CarrierRequestWrapper>)JSON.deserialize(RestContext.request.requestBody.toString(), List<CarrierRequestWrapper>.class);
        if (shipmentRequest == null || shipmentRequest.isEmpty()) {
            CarrierResponseWrapper errorResp = new CarrierResponseWrapper();
            errorResp.RequestStatus = 'Error';
            errorResp.Message = 'No shipment requests provided.';
            responseList.add(errorResp);
            return responseList;
        }
        if(shipmentRequest.size() > 1) {
            CarrierResponseWrapper errorResp = new CarrierResponseWrapper();
            errorResp.RequestStatus = 'Error';
            errorResp.Message = 'Too many shipment requests. Limit is 1.';
            responseList.add(errorResp);
            return responseList;
        }
        Map<String, CarrierRequestWrapper> inputMap = new Map<String, CarrierRequestWrapper>();
        for (CarrierRequestWrapper req : shipmentRequest) {
            if (req.ShipmentRequestId != null) {
                inputMap.put(req.ShipmentRequestId, req);
            } else {
                CarrierResponseWrapper errorResp = new CarrierResponseWrapper();
                errorResp.Name = req.Name;
                errorResp.RequestStatus = 'Error';
                errorResp.Message = 'Missing ShipmentRequestId';
                responseList.add(errorResp);
                return responseList;
            }
        }

        // Query existing DispatchCarrier records
        Map<String, DispatchCarrier__c> existingMap = new Map<String, DispatchCarrier__c>();
        for (DispatchCarrier__c dc : [
            SELECT Id, External_Id__c FROM DispatchCarrier__c 
            WHERE External_Id__c IN :inputMap.keySet()
        ]) {
            existingMap.put(dc.External_Id__c, dc);
        }

        List<DispatchCarrier__c> toUpsert = new List<DispatchCarrier__c>();
        Map<String, CarrierResponseWrapper> responseMap = new Map<String, CarrierResponseWrapper>();

        // Prepare records for upsert
        for (CarrierRequestWrapper req : shipmentRequest) {
            CarrierResponseWrapper resp = new CarrierResponseWrapper();
            resp.ShipmentRequestId = req.ShipmentRequestId;
            resp.Name = req.Name;

            try {
                DispatchCarrier__c dc = existingMap.containsKey(req.ShipmentRequestId)
                    ? existingMap.get(req.ShipmentRequestId)
                    : new DispatchCarrier__c();

                dc.External_Id__c = req.ShipmentRequestId;
                dc.Name = req.Name;
                dc.Origin__c = req.Origin;
                dc.Region__c = req.Region;
                dc.Carrier__c = req.Carrier;
                dc.Status__c = 'Dispatching';
                dc.Tracking_Id__c = req.TrackingID;
                dc.Estimated_Delivery__c = req.EstimatedDelivery;

                toUpsert.add(dc);
                responseMap.put(req.ShipmentRequestId, resp);
                if(req.TrackingID.startsWith('123')){
                    // Simulate latency for specific tracking IDs
                    return simulateLatency(5000*12*5); // 5 seconds
                }
            } catch (Exception e) {
                resp.RequestStatus = 'Error';
                resp.Status = 'Dispatch Failed';
                resp.Message = 'Exception while preparing record: ' + e.getMessage();
                responseList.add(resp);
                return responseList;
            }
        }

        // Upsert records and handle individual success/errors
        if (!toUpsert.isEmpty()) {
            try {
                Database.UpsertResult[] results = Database.upsert(toUpsert, DispatchCarrier__c.External_Id__c, false);
                for (Integer i = 0; i < results.size(); i++) {
                    DispatchCarrier__c record = toUpsert[i];
                    CarrierResponseWrapper resp = responseMap.get(record.External_Id__c);
                    resp.ShipmentRequestId = record.External_Id__c;
                    if (results[i].isSuccess()) {
                        resp.Status = 'Dispatching';
                        resp.RequestStatus = 'Success';
                        resp.Message = 'Successfully upserted.';
                    } else {
                        resp.Status = 'Dispatch Failed';
                        resp.RequestStatus = 'Error';
                        resp.Message = results[i].getErrors()[0].getMessage();
                    }
                    responseList.add(resp);
                }
            } catch (Exception e) {
                // This block should rarely hit due to partial success mode
                for (DispatchCarrier__c dc : toUpsert) {
                    CarrierResponseWrapper resp = responseMap.get(dc.External_Id__c);
                    resp.RequestStatus = 'Error';
                    resp.Message = 'Bulk exception: ' + e.getMessage();
                    responseList.add(resp);
                }
                return responseList;
            }
        }

        return responseList;
    }

    
}
