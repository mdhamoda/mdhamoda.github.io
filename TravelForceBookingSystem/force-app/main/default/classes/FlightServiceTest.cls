/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-26-2025
 * @last modified by  : Manigandan Dhamodaran
**/
@IsTest
public class FlightServiceTest {

    @TestSetup
    static void setupTestData() {
        // Create a Contact
        Contact c = TestDataFactoryUtility.createContact(
            new Contact(FirstName='John', LastName='Doe'), 
            true,
            null
        );

        // Create a Trip for that Contact
        Trip__c trip = TestDataFactoryUtility.createTrip(c, Date.today(), true, null);

        // Create a Flight
        Flight__c flight = TestDataFactoryUtility.createFlight(DateTime.now().addHours(2), true, null);

        // Create Tickets for the Flight
        TestDataFactoryUtility.createTicketsForFlight(flight, 3, null);
    }

    @IsTest
    static void testGetAvailableFlights() {
        Trip__c trip = [SELECT Id FROM Trip__c LIMIT 1];

        Test.startTest();
        List<FlightService.FlightWrapper> flights = FlightService.getAvailableFlights(trip.Id);
        Test.stopTest();

        System.assertNotEquals(0, flights.size(), 'There should be available flights');
        System.assertNotEquals(null, flights[0].idvalue, 'FlightWrapper should contain Id');
        System.assert(flights[0].availableTickets > 0, 'AvailableTickets should be greater than zero');
    }

    @IsTest
    static void testAssignFlight() {
        Trip__c trip = [SELECT Id, Contact__c, Status__c, Flight__c, Ticket__c FROM Trip__c LIMIT 1];
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];

        Test.startTest();
        Trip__c updatedTrip = FlightService.assignFlight(trip.Id, flight.Id);
        Test.stopTest();

        System.assertEquals('Flight booked', updatedTrip.Status__c, 'Trip status should be Flight booked');
        System.assertEquals(flight.Id, updatedTrip.Flight__c, 'Flight should be assigned');
        System.assertNotEquals(null, updatedTrip.Ticket__c, 'Ticket should be assigned to Trip');

        Ticket__c ticket = [SELECT Id, Contact__c FROM Ticket__c WHERE Id = :updatedTrip.Ticket__c];
        System.assertEquals(trip.Contact__c, ticket.Contact__c, 'Ticket should be assigned to Trip Contact');
    }

    @IsTest
    static void testCancelTrip() {
        Trip__c trip = [SELECT Id, Contact__c FROM Trip__c LIMIT 1];
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];

        Trip__c assignedTrip = FlightService.assignFlight(trip.Id, flight.Id);
        Id ticketId = assignedTrip.Ticket__c;

        Test.startTest();
        Trip__c cancelledTrip = FlightService.cancelTrip(assignedTrip.Id);
        Test.stopTest();

        System.assertEquals('Flight search', cancelledTrip.Status__c, 'Trip status should be reset');
        System.assertEquals(null, cancelledTrip.Flight__c, 'Flight should be cleared');
        System.assertEquals(null, cancelledTrip.Ticket__c, 'Ticket should be cleared');

        Ticket__c ticket = [SELECT Id, Contact__c FROM Ticket__c WHERE Id = :ticketId];
        System.assertEquals(null, ticket.Contact__c, 'Ticket Contact should be cleared');
    }

}
