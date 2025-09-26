/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-25-2025
 * @last modified by  : Manigandan Dhamodaran
**/
trigger TripTrigger on Trip__c (before insert, before update, after insert, after update, after delete, after undelete) {
    TripTriggerHandler handler = new TripTriggerHandler();
    handler.run();
}