# ShipmentStatusBatch Class

Batch class to manage shipment status updates

**Batchable** 

**AllowsCallouts** 

**Last** 

modified on  : 06-26-2025

**Last** 

modified by  : Manigandan Dhamodaran

**Group** : Shipment Management

**Author** : Manigandan Dhamodaran

**Implements**

Database.Batchable&lt;sObject&gt;, 
Database.AllowsCallouts

## Methods
### `start(bc)`

#### Signature
```apex
global Database.QueryLocator start(Database.BatchableContext bc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bc | Database.BatchableContext |  |

#### Return Type
**Database.QueryLocator**

---

### `execute(bc, scope)`

#### Signature
```apex
global void execute(Database.BatchableContext bc, List<ShipmentRequest__c> scope)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bc | Database.BatchableContext |  |
| scope | List&lt;ShipmentRequest__c&gt; |  |

#### Return Type
**void**

---

### `finish(bc)`

#### Signature
```apex
global void finish(Database.BatchableContext bc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bc | Database.BatchableContext |  |

#### Return Type
**void**