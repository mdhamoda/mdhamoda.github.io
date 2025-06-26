# Dispatch Carrier

## API Name
`DispatchCarrier__c`

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
### Estimated Delivery

Estimated Delivery

**API Name**

`Estimated_Delivery__c`

**Type**

*DateTime*

---
### External Id

Org A Shipment record Id

**API Name**

`External_Id__c`

**Type**

*Text*

---
### Origin

Shipment sent from Origin Location

**API Name**

`Origin__c`

**Type**

*Picklist*

#### Possible values are
* EMEA
* Africa
* Asia
* Europe
* US
* LATAM
* India
* Finland
* Germany
* Sweden
* Norway
* Denmark

---
### Region

Shipment Destination

**API Name**

`Region__c`

**Type**

*Picklist*

#### Possible values are
* EMEA
* APAC
* AMER

---
### Status

Shipment status updated to Dispatched and Dispatch Failed.

**API Name**

`Status__c`

**Type**

*Picklist*

#### Possible values are
* Dispatching
* Dispatched
* Dispatch Failed
* Delivered

---
### Tracking ID

Tracking Id of Shipment

**API Name**

`Tracking_ID__c`

**Type**

*Text*