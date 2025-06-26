# Reference Guide

## :

### [DispatchStatusUpdaterBatch](DispatchStatusUpdaterBatch.md)

:

## : LogisticsApp

### [ShipmentStatusBatchSchedule](logisticsapp\ShipmentStatusBatchSchedule.md)

: 
This class is responsible for scheduling the ShipmentStatusBatch to run periodically. 
It implements the Schedulable interface and defines the execute method to run the batch. 
The batch can be scheduled using a cron expression to run at specific intervals.

## : Shipment Management

### [ShipmentStatusBatch](shipment-management\ShipmentStatusBatch.md)

Batch class to manage shipment status updates

## Custom Objects

### [ShipmentRegionOwnership__mdt](custom-objects\ShipmentRegionOwnership__mdt.md)

### [ShipmentRequestEvent__e](custom-objects\ShipmentRequestEvent__e.md)

### [ShipmentRequest__c](custom-objects\ShipmentRequest__c.md)

### [DispatchCarrier__c](custom-objects\DispatchCarrier__c.md)

## ShipmentDispatchApp

### [DispatchStatusUpdaterScheduler](shipmentdispatchapp\DispatchStatusUpdaterScheduler.md)

:

### [GetShipmentStatusAPI](shipmentdispatchapp\GetShipmentStatusAPI.md)

: Shipment status polling API from Org A to Org B

## ShipmentDispatchApp
Last Modified on: 2025-06-26

### [CarrierAPI](shipmentdispatchapp-last-modified-on-2025-06-26\CarrierAPI.md)

:

## Triggers

### [ShipmentRequestTrigger](triggers\ShipmentRequestTrigger.md)

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