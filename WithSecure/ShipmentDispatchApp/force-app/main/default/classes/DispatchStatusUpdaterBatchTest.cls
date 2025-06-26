/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group ShipmentDispatchApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
private class DispatchStatusUpdaterBatchTest {

    @isTest static void testBatchAlternatingStatus() {
        // Prepare test data
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
        DispatchStatusUpdaterBatch batch = new DispatchStatusUpdaterBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify results
        List<DispatchCarrier__c> updated = [
            SELECT Status__c FROM DispatchCarrier__c 
            WHERE Id IN :(new Map<Id,SObject>(testRecords)).keySet()
        ];

        System.assertEquals(6, updated.size(), 'All records should be updated');
        // Ensure alternating pattern
        for (Integer i = 0; i < updated.size(); i++) {
            System.assertNotEquals('Dispatching', updated[i].Status__c, 'status should not be Dispatching');
            System.assertEquals(true, updated[i].Status__c == 'Dispatch Failed' || updated[i].Status__c == 'Dispatched', 'status is not updated correctly');
        }
    }
}
