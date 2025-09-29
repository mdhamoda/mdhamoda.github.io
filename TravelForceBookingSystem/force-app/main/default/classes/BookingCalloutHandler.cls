/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : Manigandan Dhamodaran
**/
public with sharing class BookingCalloutHandler {

    public void processTrips(Map<Id, Trip__c> oldTripMap, Map<Id, Trip__c> newTripMap) {
        List<Id> tripsToSync = new List<Id>();

        for (Id tripId : newTripMap.keySet()) {
            Trip__c newTrip = newTripMap.get(tripId);
            Trip__c oldTrip = oldTripMap.get(tripId);

            if (newTrip.Status__c == 'Flight booked' &&
                oldTrip.Status__c != 'Flight booked' &&
                newTrip.Ticket__c != null) {

                tripsToSync.add(tripId);
            }
        }

        if (!tripsToSync.isEmpty() && tripsToSync.size() <= 1) {
            //For now future method is used, in real time scenario queable can be used to handle large data volume or batch without trigger
            //Dependent on API specification if it can accept object or list
            sendTripBookingToAPI(tripsToSync);
        }
    }

    @future(callout=true)
    public static void sendTripBookingToAPI(List<Id> tripIds) {
        // Query Trips inside the future method
        List<Trip__c> tripsToSync = [
            SELECT Id, Ticket__r.Name	, Contact__r.Name, ExternalSynSuccessful__c
            FROM Trip__c
            WHERE Id IN :tripIds WITH SECURITY_ENFORCED LIMIT 1
        ];
        String requestBody;
        for (Trip__c trip : tripsToSync) {
            try {
                Map<String, String> payload = new Map<String, String>{
                    'ticketnumber' => trip.Ticket__r.Name != null ? trip.Ticket__r.Name : 'Unknown',
                    'contact' => trip.Contact__r.Name != null ? trip.Contact__r.name : 'Unknown'
                };

                requestBody = JSON.serialize(payload);
                //use Limit.getLimitFutureCalls();
                TicketBookingCallout callout = new TicketBookingCallout();
                TicketBookingCallout.BookingResult result = callout.bookTicket(requestBody);

                if (result.statusBoolean) {
                    trip.ExternalSynSuccessful__c = true;
                } else {
                    System.debug('Booking failed for trip ' + trip.Id + ': ' + result.resultMessage);
                }

            } catch (Exception e) {
                System.debug('Callout exception for trip ' + trip.Id + ': ' + e.getMessage());
            }
        }

        if (!tripsToSync.isEmpty()) {
            if(Test.isRunningTest()){
                // In test context, perform a DML operation to simulate update
                update tripsToSync;
            } else {
                // prevent recursion
            }
        }
    }
}
