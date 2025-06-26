# ShipmentRequest

## API Name
`ShipmentRequest__c`

## Fields
### Carrier

Shipment carrier partner

**API Name**

`Carrier__c`

**Type**

*Picklist*

#### Possible values are
* DHL
* UPS
* Fedex

---
### Destination

**API Name**

`Destination__c`

**Type**

*Picklist*

---
### Estimated Delivery

**API Name**

`Estimated_Delivery__c`

**Type**

*Date*

---
### In Review Start Time

When Shipment is In Review, A 5 min counter starts

**API Name**

`In_Review_Start_Time__c`

**Type**

*DateTime*

---
### In Review User

Record is in In Review by User

**API Name**

`In_Review_User__c`

**Type**

*Lookup*

---
### Origin

**API Name**

`Origin__c`

**Type**

*Picklist*

---
### Region

**API Name**

`Region__c`

**Type**

*Picklist*

---
### Status

**API Name**

`Status__c`

**Type**

*Picklist*

#### Possible values are
* Assigned to Agent
* In Review
* Ready for Dispatch
* Dispatching
* Dispatched
* Dispatch Failed
* Delivered

---
### Tracking ID

**API Name**

`Tracking_ID__c`

**Type**

*Text*