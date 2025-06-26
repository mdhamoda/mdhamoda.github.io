/**
 * @description       : Shipment status polling API from Org A to Org B
 * @author            : Manigandan Dhamodaran
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 *  * @group ShipmentDispatchApp
**/
@RestResource(urlMapping='/CarrierAPI/getShipmentStatusAPI')
global with sharing class GetShipmentStatusAPI {

    // Input wrapper
    global class ShipmentStatusRequest {
        String shipmentRequestIds;
    }

    // Individual shipment response wrapper
    global class ShipmentStatusWrapper {
        public String ShipmentRequestId;
        public String Status;
        public String Name;
        public String Message;
        public String RequestStatus;
    }

    // Entire response object
    global class ShipmentStatusResponse {
        public List<ShipmentStatusWrapper> shipments;
        public String RequestStatus;
        public String Message;
    }

    @HttpPost
    global static ShipmentStatusResponse checkShipmentStatuses() {
        ShipmentStatusResponse response = new ShipmentStatusResponse();
         // Get the JSON body as a string
        String jsonBody = RestContext.request.requestBody.toString();
        // Deserialize JSON array to List<String>
        List<String> inputList = (List<String>) JSON.deserialize(jsonBody, List<String>.class);
        response.shipments = new List<ShipmentStatusWrapper>();
        Set<String> inputSet = new Set<String>();
        inputSet.addAll(inputList);
        if (inputSet.isEmpty()) {
            response.RequestStatus = 'Error';
            response.Message = 'No shipmentRequestIds provided.';
            return response;
        }
        

        try {
            // Query existing DispatchCarrier records
            Map<String, DispatchCarrier__c> carrierMap = new Map<String, DispatchCarrier__c>();
            for (DispatchCarrier__c dc : [SELECT Name, External_Id__c, Status__c
                                            FROM DispatchCarrier__c
                                            WHERE (Status__c='Dispatched' OR Status__c='Dispatch Failed') AND External_Id__c  IN :inputSet]) {
                    carrierMap.put(dc.External_Id__c, dc);
                }

            // Build response for each requested shipment
            for (String shipmentId : inputSet) {
                ShipmentStatusWrapper wrapper = new ShipmentStatusWrapper();
                wrapper.ShipmentRequestId = shipmentId;

                if (carrierMap.containsKey(shipmentId)) {
                    DispatchCarrier__c dc = carrierMap.get(shipmentId);
                    wrapper.Status = dc.Status__c;
                    wrapper.Name = dc.Name;
                    wrapper.RequestStatus = 'Success';
                    wrapper.Message = 'Found';
                } else {
                    wrapper.Status = 'Not Found';
                    wrapper.RequestStatus = 'Error';
                    wrapper.Message = 'Shipment not found';
                }

                response.shipments.add(wrapper);
            }

            response.RequestStatus = 'Success';
            response.Message = 'Statuses fetched successfully.';
        } catch (Exception e) {
            response.RequestStatus = 'Error';
            response.Message = 'Exception occurred: ' + e.getMessage();
        }

        return response;
    }
}
