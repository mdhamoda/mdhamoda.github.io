/**
 * @description       : 
 * @author            : Manigandan Dhamodaran
 * @group             : 
 * @last modified on  : 09-25-2025
 * @last modified by  : Manigandan Dhamodaran
 * Apex class that handles callout to external ticket booking service
 * The class extends a base class for REST callouts and provides a method to book tickets
 * It constructs the HTTP request, sends it, and processes the response
 * The result of the booking operation is returned in a structured format
**/
public with sharing class TicketBookingCallout extends RestCalloutBase {

    public TicketBookingCallout() {
        super('POST', ''); // API endpoint
    }

    public class BookingResult {
        public Integer resultStatus;
        public String resultMessage;
        public Boolean statusBoolean;
    }

    public BookingResult bookTicket(String requestBody) {
        BookingResult result = new BookingResult();

        try {
            if(requestBody != null){
            HttpResponse response = send('','',requestBody);
            if(response != null && response.getStatusCode() == 201) {
                result.resultStatus = response.getStatusCode();
                result.resultMessage = response.getBody();
                result.statusBoolean = response.getStatusCode() == 201;
            } else if(response != null && response.getStatusCode() != 201) {
                result.resultStatus = response.getStatusCode();
                result.resultMessage = response.getBody();
                result.statusBoolean = response.getStatusCode() != 201;
            } else {
                result.resultStatus = null;
                result.resultMessage = 'No response received, Callout to External Booking service failed!';
                result.statusBoolean = false;
            }
            }
        } catch(Exception ex) {
            result.resultStatus = null;
            result.resultMessage = ex.getMessage();
            result.statusBoolean = false;
        }
        return result;
    }
}
