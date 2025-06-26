/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : LogisticsApp
 * @last modified on  : 06-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@isTest
public class ShipmentRequestTriggerTest {

    @testSetup
    static void setupData() {
        // Create dummy user for test
        User testUser = new User(
            Username = 'testuser1@example.random2234',
            Alias = 'tuser1',
            LastName = 'tuser1',
            Email = 'testuser1@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }

    @isTest
    static void testInsertInReviewStatus() {
        ShipmentRequest__c sr = new ShipmentRequest__c(
            Name = 'Test Shipment',
            Status__c = 'In Review'
        );

        Test.startTest();
        insert sr;
        Test.stopTest();

        sr = [SELECT Status__c, In_Review_Start_Time__c, In_Review_User__c FROM ShipmentRequest__c WHERE Id = :sr.Id];
        System.assertEquals('In Review', sr.Status__c);
        System.assertNotEquals(null, sr.In_Review_Start_Time__c);
        System.assertEquals(UserInfo.getUserId(), sr.In_Review_User__c);
    }

    @isTest
    static void testUpdateExitReviewAsSameUser() {
        ShipmentRequest__c sr = new ShipmentRequest__c(
            Name = 'Test Shipment',
            Status__c = 'In Review'
        );
        insert sr;

        sr.Status__c = 'Ready for Dispatch';
        Test.startTest();
        update sr;
        Test.stopTest();

        sr = [SELECT Status__c, In_Review_Start_Time__c, In_Review_User__c FROM ShipmentRequest__c WHERE Id = :sr.Id];
        System.assertEquals('Ready for Dispatch', sr.Status__c);
        System.assertEquals(null, sr.In_Review_Start_Time__c);
        System.assertEquals(null, sr.In_Review_User__c);
    }

    @isTest
    static void testUpdateReviewLockedByAnotherUser() {
        User anotherUser = [SELECT Id FROM User WHERE Username = 'testuser1@example.random2234'];

        // Create record in In Review state by original user
        ShipmentRequest__c sr = new ShipmentRequest__c(
            Name = 'Locked Shipment',
            In_Review_User__c = anotherUser.Id
        );
                insert sr;
        Test.startTest();
        sr.Status__c = 'In Review';
        sr.In_Review_Start_Time__c = System.now();
        try {
            update sr;
            sr.Status__c = 'Ready for Dispatch';
            update sr;
            System.assert(false, 'Expected a DMLException due to addError');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Record is locked and In Review'), 'Expected lock error');
        }
        Test.stopTest();
    }

    // Optional: Test that the controller method is invoked
    @isTest
    static void testTriggerCallsControllerPublishEvent() {
        // You might want to inject or mock the controller in real frameworks.
        // For now, just basic coverage:
        ShipmentRequest__c sr = new ShipmentRequest__c(Name='Pub Event Test', Status__c='Dispatched');
        Test.startTest();
        insert sr;
        Test.stopTest();

        // There's no assert here unless ShipmentRequestController is made mockable or logs actions.
    }
}
