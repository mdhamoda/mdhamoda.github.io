# ShipmentRequestTrigger Trigger

## Trigger On ShipmentRequest__c

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

**Last** 

modified on  : 06-26-2025

**Last** 

modified by  : Manigandan Dhamodaran

**Group** : LogisticsApp

**Author** : Manigandan Dhamodaran

**Run**
* Before Insert
* Before Update
* After Insert
* After Update