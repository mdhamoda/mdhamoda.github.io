/**Batch class to manage shipment status updates
 * @batchable
 * @allowsCallouts
 * @description       : This batch class processes shipment requests with the status 'Dispatching' and updates their status.
 * It is designed to be run periodically to ensure that shipment statuses are kept up-to-date.
 * @group             : Shipment Management
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
global class ShipmentStatusBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, Status__c FROM ShipmentRequest__c WHERE Status__c = 'Dispatching']
        );
    }

    global void execute(Database.BatchableContext bc, List<ShipmentRequest__c> scope) {
        // if(scope.size()>0) CarrierDispatchService.manageShipmentStatus(scope);
        if(scope.size()>0) CarrierDispatchService.updateShipmentStatus(scope);
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: send notification or do logging
    }

}
