/**
 * @description       : 
 * This class is responsible for scheduling the ShipmentStatusBatch to run periodically.
 * It implements the Schedulable interface and defines the execute method to run the batch.
 * The batch can be scheduled using a cron expression to run at specific intervals. 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
global class ShipmentStatusBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ShipmentStatusBatch batch = new ShipmentStatusBatch();
        Database.executeBatch(batch);
    }
}   