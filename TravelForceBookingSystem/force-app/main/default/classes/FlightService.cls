/**
 * @description       : Flight service for handling trips, flights, and tickets
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
public with sharing class FlightService {

    // Wrapper for exposing flight details to LWC
    public class FlightWrapper {
        @AuraEnabled public Id idvalue;
        @AuraEnabled public String flightName;
        @AuraEnabled public DateTime start;
        @AuraEnabled public Integer availableTickets;
    }

    /**
     * Get flights within the next 50 days that still have available tickets
     */
    @AuraEnabled(cacheable=true)
    public static List<FlightWrapper> getAvailableFlights(Id tripId) {
        Date startDate = System.today();
        Date endDate = startDate.addDays(50);

        List<Flight__c> flights = [
            SELECT Id, Name, Start__c,
                   (SELECT Id FROM Tickets__r WHERE Contact__c = null)
            FROM Flight__c
            WHERE DAY_ONLY(Start__c) >= :startDate
              AND DAY_ONLY(Start__c) <= :endDate
              AND Id IN (SELECT Flight__c FROM Ticket__c WHERE Contact__c = null)
            WITH SECURITY_ENFORCED
            ORDER BY Start__c ASC
            LIMIT 50
        ];

        List<FlightWrapper> result = new List<FlightWrapper>();
        for (Flight__c f : flights) {
            FlightWrapper fw = new FlightWrapper();
            fw.idvalue = f.Id;
            fw.flightName = f.Name;
            fw.start = f.Start__c;
            fw.availableTickets = f.Tickets__r.size();
            result.add(fw);
        }
        return result;
    }

    /**
     * Assign a flight to a trip and allocate a ticket to the trip’s contact
     */
    @AuraEnabled
    public static Trip__c assignFlight(Id tripId, Id flightId) {
        Trip__c trip = [
            SELECT Id, Contact__c, Status__c, Flight__c, Ticket__c 
            FROM Trip__c 
            WHERE Id = :tripId 
            LIMIT 1
        ];

        trip.Flight__c = flightId;
        trip.Status__c = 'Flight booked';

        List<Ticket__c> freeTickets = [
            SELECT Id, Flight__c, Contact__c
            FROM Ticket__c
            WHERE Flight__c = :flightId AND Contact__c = null
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!freeTickets.isEmpty() && trip.Contact__c != null) {
            Ticket__c ticket = freeTickets[0];
            ticket.Contact__c = trip.Contact__c;
            update ticket;

            trip.Ticket__c = ticket.Id;
        }

        update trip;
        return trip;
    }

    /**
     * Cancel a trip → free up its ticket and reset trip fields
     */
    @AuraEnabled
    public static Trip__c cancelTrip(Id tripId) {
        Trip__c trip = [
            SELECT Id, Flight__c, Ticket__c, Status__c
            FROM Trip__c
            WHERE Id = :tripId
            LIMIT 1
        ];

        // Step 1: Free up the ticket (if any)
        if (trip.Ticket__c != null) {
            freeUpTicket(trip.Ticket__c);
        }

        // Step 2: Clear the trip fields
        clearTripFields(trip);

        return trip;
    }

    // ----------------- Helpers -----------------

    /**
     * Free up a ticket by setting Contact__c = null
     */
    private static void freeUpTicket(Id ticketId) {
        Ticket__c t = [
            SELECT Id, Contact__c
            FROM Ticket__c
            WHERE Id = :ticketId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        t.Contact__c = null;

        if (Schema.sObjectType.Ticket__c.fields.Contact__c.isUpdateable()) {
            try {
                update t;
            } catch (Exception e) {
                System.debug('Error updating ticket: ' + e.getMessage());
                // TODO: handle using custom label + error wrapper
            }
        }
    }

    /**
     * Reset flight, ticket, and status fields on a trip
     */
    private static void clearTripFields(Trip__c trip) {
        trip.Flight__c = null;
        trip.Ticket__c = null;
        trip.Status__c = 'Flight search';

        if (Schema.sObjectType.Trip__c.fields.Flight__c.isUpdateable() &&
            Schema.sObjectType.Trip__c.fields.Ticket__c.isUpdateable() &&
            Schema.sObjectType.Trip__c.fields.Status__c.isUpdateable()) {
            try {
                update trip;
            } catch (Exception e) {
                System.debug('Error updating trip: ' + e.getMessage());
                // TODO: handle using custom label + error wrapper
            }
        }
    }
}
