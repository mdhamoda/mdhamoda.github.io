/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group ShipmentDispatchApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
private class DispatchStatusUpdaterSchedulerTest {

    @isTest static void testSchedulerFiresBatch() {
        // Create some dispatching records
        List<DispatchCarrier__c> testRecords = new List<DispatchCarrier__c>();
        for (Integer i = 0; i < 6; i++) {
            testRecords.add(new DispatchCarrier__c(
                Name = 'Test Shipment ' + i,
                Status__c = 'Dispatching',
                Tracking_Id__c = 'Tracking_' + i,
                External_Id__c = 'SR' + i
            ));
        }
        insert testRecords;

        Test.startTest();
        String jobId = System.schedule(
            'TestScheduler',
            '0 0 0 1 1 ? 2050',  // Dummy cron
            new DispatchStatusUpdaterScheduler());
        Test.stopTest();
        // Verify results
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully.');
        }
}
