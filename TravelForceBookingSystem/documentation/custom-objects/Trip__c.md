# Trip

Booked trips for a passenger

## API Name
`Trip__c`

## Fields
### Case

Customer case for booking request

**API Name**

`Case__c`

**Type**

*Lookup*

---
### Contact
**Required**

Trip is booked for customer contact

**API Name**

`Contact__c`

**Type**

*Lookup*

---
### ExternalSynSuccessful

This is checked by the system when trip or booking is synced to external booking system

**API Name**

`ExternalSynSuccessful__c`

**Type**

*Checkbox*

---
### Flight

Flight Available on this trip

**API Name**

`Flight__c`

**Type**

*Lookup*

---
### Name

Contact.Name + Preferred trip start date

**API Name**

`Name__c`

**Type**

*Text*

---
### Preferred Trip Start

The date the trip is preferred to start

**API Name**

`Preferred_Trip_Start__c`

**Type**

*Date*

---
### Status

**API Name**

`Status__c`

**Type**

*Picklist*

#### Possible values are
* Flight search
* Flight booked

---
### Ticket

Ticket reserved for this flight

**API Name**

`Ticket__c`

**Type**

*Lookup*