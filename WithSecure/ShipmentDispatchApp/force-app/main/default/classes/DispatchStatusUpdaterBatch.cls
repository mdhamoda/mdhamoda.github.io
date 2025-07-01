/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : Manigandan Dhamodaran
 *  * @group ShipmentDispatchApp
**/
global class DispatchStatusUpdaterBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c 
            FROM DispatchCarrier__c 
            WHERE Status__c = 'Dispatching'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<DispatchCarrier__c> scope) {
        List<DispatchCarrier__c> toUpdate = new List<DispatchCarrier__c>();
        Boolean assignDispatched = true; // Start with 'Dispatched'

        for (DispatchCarrier__c record : scope) {
            record.Status__c = assignDispatched ? 'Dispatched' : 'Dispatch Failed';
            assignDispatched = !assignDispatched; // Toggle for next record
            toUpdate.add(record);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('DispatchStatusUpdaterBatch completed.');
        scheduleNextBatch();
    }

    global void scheduleNextBatch() {
        String datetimeVal = DateTime.now().format('yyyyMMdd_HHmmss');
        Integer intervalVal = 10;
        if (!Test.isRunningTest()) {
            System.scheduleBatch(
                new DispatchStatusUpdaterBatch(),
                'DispatchStatusUpdaterBatch_' + DatetimeVal,
                intervalVal
            );
        } 
    }
}
