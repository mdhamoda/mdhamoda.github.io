/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
public with sharing class TripTriggerHandler extends TriggerHandler {

    private Map<Id, Trip__c> newTripMap;
    private Map<Id, Trip__c> oldTripMap;

    public TripTriggerHandler() {
        if(!Test.isRunningTest()){
            this.setMaxLoopCount(2);
        }
        
        this.newTripMap = (Map<Id, Trip__c>) Trigger.newMap;
        this.oldTripMap = (Map<Id, Trip__c>) Trigger.oldMap;
    }

    public override void afterUpdate() {
        if (TriggerHandler.isBypassed('TripTriggerHandler')) {
                // ... do something if the Account trigger handler is bypassed!
                return;
            }
            // Call BookingCalloutHandler
            BookingCalloutHandler bookingHandler = new BookingCalloutHandler();
            bookingHandler.processTrips(oldTripMap,newTripMap);
    }
}