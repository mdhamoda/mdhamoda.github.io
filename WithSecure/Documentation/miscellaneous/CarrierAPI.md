# CarrierAPI Class

`RESTRESOURCE`

:

**Last** 

modified on  : 06-26-2025

**Last** 

modified by  : Manigandan Dhamodaran 
 
CarrierAPI- This Apex REST service processes carrier dispatch shipment requests.&lt;br/&gt; 
Accepts a single shipment request and creates or updates a DispatchCarrier__c record.&lt;br/&gt; 
If the TrackingID starts with &#x27;123&#x27;, it simulates a processing delay for testing/debugging.

**UrlMapping** 

/CarrierAPI

**Author** : Manigandan Dhamodaran

**Date** Last Modified on: 2025-06-26

## Methods
### `handleCarrierData(shipmentRequest)`

`HTTPPOST`

Processes the HTTP POST request containing a shipment dispatch request.&lt;br/&gt; 
Validates input, performs upsert on DispatchCarrier__c using External_Id__c, and returns results.&lt;br/&gt; 
If tracking ID starts with &#x27;123&#x27;, simulates latency for testing.&lt;br/&gt; 
Handles and returns detailed success/failure responses.

**Name** 

handleCarrierData

**HttpMethod** 

POST

**RestResource** 

/CarrierAPI

#### Signature
```apex
global static List<CarrierResponseWrapper> handleCarrierData(List<CarrierRequestWrapper> shipmentRequest)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| shipmentRequest | List&lt;CarrierRequestWrapper&gt; | List of CarrierRequestWrapper objects (limited to one) |

#### Return Type
**List&lt;CarrierResponseWrapper&gt;**

List of CarrierResponseWrapper responses

## Classes
### CarrierRequestWrapper Class

### CarrierResponseWrapper Class
