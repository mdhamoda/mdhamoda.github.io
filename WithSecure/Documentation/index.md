# Reference Guide

## : LogisticsApp
A Salesforce Lightning Web Component (LWC) that displays shipment requests in a dynamic, interactive table. Features include:

- Region-based filtering
- Live countdown timer for "In Review" shipments
- EMP API subscription for real-time updates
- Editable modal for updating shipment records
- Dispatch functionality with validations
- Record creation and deletion via modal
- Lightning styling with SLDS
*[*Also checkout- Html documentation](https://mdhamoda.github.io/WithSecure/LogisticsApp/apex-documentation/CarrierDispatchService.html)**

### [CarrierAPI](miscellaneous/CarrierAPI.md)
CarrierAPI- This Apex REST service processes carrier dispatch shipment requests.&lt;br/&gt; 
Accepts a single shipment request and creates or updates a DispatchCarrier__c record.&lt;br/&gt; 
If the TrackingID starts with &#x27;123&#x27;, it simulates a processing delay for testing/debugging.


### [DispatchStatusUpdaterBatch](DispatchStatusUpdaterBatch.md)
Batch job updates Dispatch status by making an API call from Org A


### [ShipmentStatusBatch](shipmentdispatchapp/ShipmentStatusBatch.md)

Batch class to manage recent shipment status updates to Dispatched or Dispatch falied by polling Org B

### [ShipmentStatusBatchSchedule](logisticsapp/ShipmentStatusBatchSchedule.md)

:
This class is responsible for scheduling the ShipmentStatusBatch to run periodically. 
It implements the Schedulable interface and defines the execute method to run the batch. 
The batch can be scheduled using a cron expression to run at specific intervals.

## Custom Objects

### [ShipmentRegionOwnership__mdt](custom-objects/ShipmentRegionOwnership__mdt.md)

### [ShipmentRequestEvent__e](custom-objects/ShipmentRequestEvent__e.md)

### [ShipmentRequest__c](custom-objects/ShipmentRequest__c.md)

### [DispatchCarrier__c](custom-objects/DispatchCarrier__c.md)

## ShipmentDispatchApp

### [DispatchStatusUpdaterScheduler](shipmentdispatchapp/DispatchStatusUpdaterScheduler.md)

:

### [GetShipmentStatusAPI](shipmentdispatchapp/GetShipmentStatusAPI.md)


### [CarrierAPI](shipmentdispatchapp-last-modified-on-2025-06-26/CarrierAPI.md)

:
That accepts shipments

## Triggers

### [ShipmentRequestTrigger](triggers/ShipmentRequestTrigger.md)

: 
This trigger handles the ShipmentRequest__c object lifecycle events. 
It manages the status transitions, timestamps, and user assignments for the In Review state. 
It also publishes shipment events when records are inserted or updated. 
It ensures that only the user who initiated the review can modify the record while it is in the In Review state. 
It prevents other users from making changes to the record during this period. 
It adds an error message if a user tries to update a record that is locked by another user. 
This trigger is designed to maintain data integrity and enforce business rules related to shipment requests. 
It is executed before and after insert and update operations on the ShipmentRequest__c object. 
This trigger is part of a larger Salesforce application that manages shipment requests and their review processes.


## Delpoyment Instruction
### Summary 
- Org A has Shipment Request. Org B has Dispatch Carriers,
- When a shipment is created its created with status 'Assigned to Agent' The Region is updated by a mapping based on Destination. The Owner is updated by a mapping based on Region.
- When a shipment is opened by Logistica customer service, the shipment status is changed to in Review and is locked by that user. A server side validation prevents other users from updating this record.
- After reviewing the shipment can be updated to Ready For Dispatch
- With the help of Dispatch button, the shipment is sent to Org B as "Dispatch Carrier". The statu is updated as Dispatching in Org B and Org A. If the integration fails, the shipments is updated to Dispath failed for reprocessing
- The status is updated asynchronously /randomly in Org B to Dispatched or Dispatch Failed.
- A batch job in Org A queries/polls Org B for "Dispatching" records for a recent change in status
- Additionally, a shipment can be created or deleted in Logistica App.
- Platform event is used to track any change in shipment and the Logistica App is subscribe dto any changes(not specific to status)


### Copy LogisticsApp folder to VS code for Org B
### Copy ShipmentDispatchApp folder to VS code for Org B
### Pre Deployment steps:
- Create a certificate in Org A called, "CarrierAPI" or upload the one in asset folder to Org A. If you have created one, download for using in the connected app in Org B
In Org B create a system administrator user with username , withsecurelogisticaapp@testorg123.com. This user is needed in the connected app.
Create a connected App, "LogisticaApp" in Org B. This app will be used for OAuth by Org B.
Details steps will be added her for creating connected app.The connected app will use digital signatures and connect using certificate provided(or retrieved from Org A). Copy the consumer key. thi consumer key has to updated in the Org A named credential/External credential

### Run the command separately for Org A and Org B
  sf project deploy start --source-dir force-app

- sf project deploy start --source-dir force-app

### Post deployment
As a admin in Org A
- Update the named credential consumer key from Org B
- Activate the flow, "Reset Shipmet Status"
- Please schedule a batch job that updates shipment status to Dispatched or Dispatch failed by polling Org B
- Create a user with profile Logistica Customer Service and add permission Set, LogisticaAppPermission
- Login as the new test user and start testing.

As a admin in Org B
- Please schedule a batch job that updates shipment status to Dispatched or Dispatch failed fro Dispatch Carrier records
## 



# 🚚 Logistica – Salesforce-Native Logistics Management Centre

Logistica is a scalable, asynchronous, and integration-heavy Salesforce-native logistics orchestration solution designed to handle global shipment operations. It coordinates requests from external Salesforce orgs, routes them to agents by region, and dispatches them to carrier systems.

## 🌐 Architecture Overview

This system spans two Salesforce developer orgs:

- **Org A – Logistica (Logistics Management Centre)**
- **Org B – Carrier Org (External Shipment Processor)**

![Architecture Diagram](./assets/architecture-diagram.png) <!-- Include an actual diagram if available -->

---

## 🔧 Core Components

### 1. ShipmentRequest__c Object (Org A)

Custom object that captures shipment details:
- **Fields**: Origin__c, Destination__c, Carrier__c, Status__c, Tracking_ID__c, Estimated_Delivery__c

### 2. Region-Based Routing

- Shipments are automatically routed to agents based on the `Destination__c` country, which is mapped to regions (EMEA, Africa, Asia, Europe, US, LATAM).

---

## 🧭 Logistica App (Org A)

A Lightning App providing agents with a real-time interface for managing shipment requests.

### Features:

- Lightning App Page with a custom **LWC Datatable**
- Real-time updates via **Platform Events** or **Lightning Message Service**
- Region-based filtering of visible shipment requests

---

## 📊 Datatable Specifications

| Column                    | Description                        |
|--------------------------|------------------------------------|
| ShipmentRequest Number   | Auto-number for tracking           |
| Destination__c           | Destination country                |
| Carrier__c               | Assigned carrier                   |
| Status__c                | Shipment status                    |
| Tracking_ID__c           | External tracking reference        |
| Estimated_Delivery__c    | Expected delivery date             |

### Row Behaviors

- **In Review**: Highlighted **yellow**, with icon
- **Assigned to Agent**: Highlighted **green**
- **Real-time status updates** for all agents

---

## 🧩 Functional Capabilities

- **View & Edit** assigned shipment records
- **Status transitions**:
  - Assigned → In Review (on record open)
  - In Review → Ready for Dispatch (after verification)
  - Dispatch Failed → Ready for Dispatch (retry)
- **Conflict Detection**:
  - Detects and prevents concurrent agent edits
- **Trigger Dispatch**:
  - Sends a POST request to Org B `/CarrierAPI` endpoint
- **Release In Review**:
  - Manually release record if verification isn't completed within 5 minutes

---

## 🔗 Carrier API Integration (Org B)

- **/CarrierAPI**: Accepts shipment dispatch requests
- **Dispatch Status Polling API**: Allows Org A to check shipment status
- **Batch Job**: Runs every 10 minutes to update statuses (Dispatched or Dispatch Failed)

---

## 🔐 Integration & Resilience

- **OAuth 2.0** authentication from Org A → Org B
- Simulated:
  - Rate limiting
  - API timeouts & retry logic
  - Latency
- API is intentionally **not bulkified**

---

## ✅ Testing Strategy

- **93%+ code coverage** for Career Dispatch service
- **Unit Testing**:
  - Success and Failure test methods are included
- **Tools Used**:
  - `HttpCalloutMock` is used to mimic respose data for Carrier API
  - `Test.startTest()` / `stopTest()`
  - Platform Event mocking

---







# 🔄 Integration Architecture: Salesforce Org A (Logistica) ↔ Org B (Dispatch Carriers)

+-------------------+                        +-----------------------+       
|    Salesforce     |                        |     Salesforce        |       
|     Org A         |                        |       Org B           |       
| (Logistica App)   |                        |  (Dispatch Carriers)  |       
+-------------------+                        +-----------------------+       
         |                                               |                   
         | 1. Shipment Created                           |                   
         |                                               |                   
         |  Status: Assigned to Agent                    |                   
         |  Region mapped from Destination               |                   
         |  Owner mapped from Region                     |                   
         |                                               |                   
         v                                               v                   
+-------------------------+                      +-------------------------+ 
|  Logistica Customer     |                      |  Org B Dispatch System  | 
|  opens Shipment Record  |                      +-------------------------+ 
+-------------------------+                                 |                
         |                                                  |                
         | 2. Agent Reviews record with a action            |                
         |    Status changed to 'In Review'                 |                
         |  Locked for others (server-side validation)     |                 
         | Agent updates 'Ready For Dispatch'               |                
         v                                                  |                
+------------------------------+                            |                
| Shipment marked Ready        |                            |                
| for Dispatch (by CSR)        |                            |                
+------------------------------+                            |                
         |                                                  |                
         | 3. User clicks "Dispatch" (OAuth + Callout)      |                
         |------------------------------------------------->|                
         |  Synchronous                                     |                
         | - Org A: Status = Dispatching                    |                
         | - Org B: Dispatch Carrier created                |                
         |   Status = Dispatching                           |                
         |                                                  |                
         | [If integration fails: Status = Dispatch Failed] |                
         |                                                  |                
         v                                                  v                
                                                                             
+---------------------+    Asynchronous       +---------------------+        
| 5. Batch Job (Org A) | <-------------------  | 4. Status updates in  |     
| Polls Org B for     |                       | Org B:               |       
| Dispatching records |                       | - Dispatched         |       
| to Dispatched or    |                       | - Dispatch Failed    |       
| Dispatch Failed     |                       |                      |       
+---------------------+                       +---------------------+        
                                                                             
         |                                                                   
         | 6. Platform Event: `ShipmentRequestEvent__e`                      
         |-----------------------------------------------------------+       
         | Triggers in Org A for any field change on Shipment        |       
         | - Logistica App LWC subscribed                            |       
         +-----------------------------------------------------------+       
                                                                             
         |                                                                   
         | 7. Users can also:                                                
         | - Create Shipment via Modal                                       
         | - Delete Shipment                                                 
         v                                                                   
+-------------------------------+                                            
| Logistica Shipment Datatable  |                                            
| LWC: Create / Delete / Track  |                                            
+-------------------------------+                                            
