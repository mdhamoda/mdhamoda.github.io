/**
 * Controller class to manage and interact with `ShipmentRequest__c` records.<br>
 * Supports retrieval of shipments by region, updates from UI, and publishing platform events.
 *
 * <br><br><b>🔧 Key Features:</b><br>
 * - Retrieves shipments with optional region filter (cacheable for LWC/Aura)<br>
 * - Updates a list of ShipmentRequest__c records with error handling<br>
 * - Publishes platform events (`ShipmentRequestEvent__e`) for shipment changes
 *
 * <br><br><b>⚙️ Use Cases:</b><br>
 * - Display shipment requests filtered by region in UI<br>
 * - Update shipment status or details via client components<br>
 * - Trigger downstream processing via event publication
 *
 * <br><br><b>📤 Event:</b><br>
 * - Platform Event Published: `ShipmentRequestEvent__e`
 *
 * <br><br><b>@AuraEnabled Methods:</b><br>
 * - `getShipmentsByRegion(String region)` → `List<ShipmentRequest__c>`<br>
 * <br>
 * - `updateShipments(List<ShipmentRequest__c>)` → `void`
 *
 * <br><br><b>@return</b><br>
 * - `getShipmentsByRegion()` returns up to 200 shipment records filtered by region or all if `'All'` is passed<br>
 * - `updateShipments()` updates provided records and throws `AuraHandledException` on DML failure
 *
 * <br><br><b>@namedcredential</b><br>
 * - None
 *
 * <br><br><b>@sampleinput</b><br>
 * `getShipmentsByRegion('East')`
 *
 * <br><br><b>@sampleoutput</b><br>
 * List of `ShipmentRequest__c` records sorted by `CreatedDate`
 *
 * <br><br><b>@exampleevent</b><br>
 * {
 *   "ShipmentId__c": "a01xx0000001234",<br>
 *   <br>
 *   "Status__c": "Dispatched"
 * }
 * @group LogisticsApp
 * @author            : Manigandan Dhamodaran
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
 */

public with sharing class ShipmentRequestController {
    
    @AuraEnabled(cacheable=true)
    public static List<ShipmentRequest__c> getShipmentsByRegion(String region) {
        if(region != null && region != 'All') {
            // Filter shipments by the selected region
        return [
            SELECT Id, Name, Origin__c, Destination__c, Region__c, Carrier__c, Status__c, Tracking_ID__c, Estimated_Delivery__c, In_Review_Start_Time__c, In_Review_User__r.Name
            FROM ShipmentRequest__c
            WHERE Region__c = :region
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
        } else {
        return [
            SELECT Id, Name, Origin__c, Destination__c, Region__c, Carrier__c, Status__c, Tracking_ID__c, Estimated_Delivery__c, In_Review_Start_Time__c, In_Review_User__r.Name
            FROM ShipmentRequest__c
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
     }
    }
    
    @AuraEnabled
    public static void updateShipments(List<ShipmentRequest__c> shipmentsToUpdate) {
        try {
            if(shipmentsToUpdate.size()>0) update shipmentsToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Update failed: ' + e.getMessage());
        }
    }

    public static void publishShipmentEvent(List<ShipmentRequest__c> shipments) {
        if(shipments == null || shipments.isEmpty()) {
            return;
        }
            // Create and publish ShipmentRequestEvent__e events
        List<ShipmentRequestEvent__e> eventsToPublish = new List<ShipmentRequestEvent__e>();
        for (ShipmentRequest__c shipment : shipments) {
            ShipmentRequestEvent__e event = new ShipmentRequestEvent__e();
            event.ShipmentId__c = shipment.Id;
            event.Status__c = shipment.Status__c;
            eventsToPublish.add(event);
        }
        EventBus.publish(eventsToPublish);
    }
}
