/**
 * @description       : 
    * This trigger handles the ShipmentRequest__c object lifecycle events.
    *   It manages the status transitions, timestamps, and user assignments for the In Review state.
    * It also publishes shipment events when records are inserted or updated.
    * It ensures that only the user who initiated the review can modify the record while it is in the In Review state.
    * It prevents other users from making changes to the record during this period.
    * It adds an error message if a user tries to update a record that is locked by another user.
    * This trigger is designed to maintain data integrity and enforce business rules related to shipment requests.
    * It is executed before and after insert and update operations on the ShipmentRequest__c object.
    * This trigger is part of a larger Salesforce application that manages shipment requests and their review processes.
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
trigger ShipmentRequestTrigger on ShipmentRequest__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        ShipmentRequestController.publishShipmentEvent(Trigger.new);
        if (Trigger.isInsert || Trigger.isUpdate) {

        for (ShipmentRequest__c shipment : Trigger.new) {
            if (shipment.Status__c == 'In Review' && shipment.In_Review_Start_Time__c == null) {
                shipment.In_Review_Start_Time__c = DateTime.now();
                if(shipment.In_Review_User__c==null)shipment.In_Review_User__c = UserInfo.getUserId();
                
            }
            if (Trigger.isUpdate && shipment.Status__c != 'In Review' && shipment.In_Review_Start_Time__c != null && 
            String.valueOf(Trigger.oldMap.get(shipment.Id).In_Review_User__c).substring(0, 15) == String.valueOf(UserInfo.getUserId()).substring(0, 15)) { 
                shipment.In_Review_Start_Time__c = null;
                shipment.In_Review_User__c = null;
            }
        }

        for (ShipmentRequest__c shipment : Trigger.new) {
            if (!Trigger.isInsert && Trigger.isUpdate && Trigger.oldMap.get(shipment.Id).Status__c == 'In Review' && shipment.In_Review_Start_Time__c != null && Trigger.oldMap.get(shipment.Id).In_Review_User__c != null && String.valueOf(Trigger.oldMap.get(shipment.Id).In_Review_User__c).substring(0, 15) != String.valueOf(UserInfo.getUserId()).substring(0, 15)) {
                system.debug('log error'+  shipment.In_Review_User__c +'.');
                shipment.addError('Record is locked and In Review by '+ shipment.In_Review_User__c +'.');
            }
        }
        
        }
    }
}