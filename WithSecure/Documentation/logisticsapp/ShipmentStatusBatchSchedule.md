# ShipmentStatusBatchSchedule Class

: 
This class is responsible for scheduling the ShipmentStatusBatch to run periodically. 
It implements the Schedulable interface and defines the execute method to run the batch. 
The batch can be scheduled using a cron expression to run at specific intervals.

**Last** 

modified on  : 06-26-2025

**Last** 

modified by  : Manigandan Dhamodaran

**Group** : LogisticsApp

**Author** : Manigandan Dhamodaran

**Implements**

Schedulable

## Methods
### `execute(sc)`

#### Signature
```apex
global void execute(SchedulableContext sc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sc | SchedulableContext |  |

#### Return Type
**void**