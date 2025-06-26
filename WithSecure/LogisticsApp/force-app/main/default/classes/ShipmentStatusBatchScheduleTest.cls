/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
public class ShipmentStatusBatchScheduleTest {

    @isTest
    static void testScheduleBatchClass() {
        // Use a dummy future cron expression (runs at Jan 1, 2050)
        String cronExp = '0 0 0 1 1 ? 2050';

        Test.startTest();
        String jobId = System.schedule('Test ShipmentStatusBatchSchedule', cronExp, new ShipmentStatusBatchSchedule());
        Test.stopTest();

        // Just verify the job was scheduled
        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
}
