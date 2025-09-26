/**
 * @description  : Reusable HTTP callout mock utility for tests.
 *                 Allows setting a mock response for any endpoint with a custom status code and JSON body.
 *
 * Example usage:
 * 
 *  @IsTest
 *  static void testCalloutSuccess() {
 *      String jsonResponse = '{"result":"success","message":"Operation completed"}';
 *      HttpCalloutMockUtility.setMock('MyAPI', 200, jsonResponse);
 *
 *      Test.startTest();
 *      // Call your method that performs the callout here
 *      Test.stopTest();
 *  }
 *
 *  @IsTest
 *  static void testCalloutError() {
 *      String jsonResponse = '{"error":"Internal Server Error"}';
 *      HttpCalloutMockUtility.setMock('MyAPI', 500, jsonResponse);
 *
 *      Test.startTest();
 *      // Call your method that performs the callout here
 *      Test.stopTest();
 *  }
 * 
 * @author       : Manigandan Dhamodaran
 * @group        : LogisticsApp
 * @last modified: 09-26-2025
 */
@IsTest
public class HttpCalloutMockUtility {

    public class GenericHttpMock implements HttpCalloutMock {
        public String endpointContains;
        public Integer statusCode;
        public String responseBody;

        public GenericHttpMock(String endpointContains, Integer statusCode, String responseBody) {
            this.endpointContains = endpointContains;
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode != null ? statusCode : 200);
            res.setBody(responseBody != null ? responseBody : '{}');
            return res;
        }
    }

    /**
     * Utility method to set the mock in a test
     */
    public static void setMock(String endpointContains, Integer statusCode, String responseBody) {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock(endpointContains, statusCode, responseBody));
    }
}
