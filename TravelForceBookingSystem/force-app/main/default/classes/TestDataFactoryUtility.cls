/**
 * @description       : Test data factory utility for creating Contact, Case, Trip, Flight, Ticket
 * @author            : Manigandan Dhamodaran
 * @last modified on  : 09-26-2025
 */
public class TestDataFactoryUtility {

    // -----------------------------
    // Contact
    // -----------------------------
    public static Contact createContact(Contact exampleContact, Boolean doInsert, Map<String, Object> additionalFields) {
        Map<String, Object> fields = new Map<String, Object>{
            'FirstName' => exampleContact.FirstName,
            'LastName'  => exampleContact.LastName,
            'Email'     => exampleContact.FirstName.toLowerCase() + '.' + exampleContact.LastName.toLowerCase() + '@example.com'
        };
        if (additionalFields != null) fields.putAll(additionalFields);

        Contact c = (Contact) TestDataFactory.createSObject('Contact', fields, doInsert);
        return c;
    }

    // -----------------------------
    // Trip Case
    // -----------------------------
    public static Case createTripCase(Contact contact, Boolean doInsert, Map<String, Object> additionalFields) {
        Map<String, Object> fields = new Map<String, Object>{
            'ContactId' => contact.Id,
            'Subject'   => 'Test Trip Case',
            'Status'    => 'New',
            'Origin'    => 'Phone'
        };
        if (additionalFields != null) fields.putAll(additionalFields);

        Case tripCase = (Case) TestDataFactory.createSObject('Case', fields, doInsert);
        return tripCase;
    }

    // -----------------------------
    // Trip
    // -----------------------------
    public static Trip__c createTrip(Contact contact, Date preferredStart, Boolean doInsert, Map<String, Object> additionalFields) {
        Map<String, Object> fields = new Map<String, Object>{
            'Contact__c' => contact.Id,
            'Preferred_Trip_Start__c' => preferredStart,
            'Status__c' => 'Flight search',
            'Name__c' => 'Test Trip 001'
        };
        if (additionalFields != null) fields.putAll(additionalFields);

        Trip__c trip = (Trip__c) TestDataFactory.createSObject('Trip__c', fields, doInsert);
        return trip;
    }

    // -----------------------------
    // Flight
    // -----------------------------
    public static Flight__c createFlight(DateTime startDateTime, Boolean doInsert, Map<String, Object> additionalFields) {
        Map<String, Object> fields = new Map<String, Object>{
            'Start__c' => startDateTime
        };
        if (additionalFields != null) fields.putAll(additionalFields);

        Flight__c flight = (Flight__c) TestDataFactory.createSObject('Flight__c', fields, doInsert);
        return flight;
    }

    // -----------------------------
    // Ticket
    // -----------------------------
    public static Ticket__c createTicket(Flight__c flight, Boolean doInsert, Map<String, Object> additionalFields) {
        Map<String, Object> fields = new Map<String, Object>{
            'Flight__c' => flight.Id
        };
        if (additionalFields != null) fields.putAll(additionalFields);

        Ticket__c ticket = (Ticket__c) TestDataFactory.createSObject('Ticket__c', fields, doInsert);
        return ticket;
    }

    // -----------------------------
    // Helper: create multiple Tickets for a Flight
    // -----------------------------
    public static List<Ticket__c> createTicketsForFlight(Flight__c flight, Integer count, Map<String, Object> additionalFields) {
        List<Ticket__c> tickets = new List<Ticket__c>();
        for (Integer i = 0; i < count; i++) {
            tickets.add(createTicket(flight, true, additionalFields));
        }
        return tickets;
    }
}
