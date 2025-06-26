/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group ShipmentDispatchApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
global class DispatchStatusUpdaterScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        DispatchStatusUpdaterBatch batch = new DispatchStatusUpdaterBatch();
        Database.executeBatch(batch, 200); // Batch size = 200
    }
}
