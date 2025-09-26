/*------------------------------------------------------------  
Author:        Ian Huang
Company:       Salesforce.com
Description:   An abstract base class for rest callouts
Test Class:    TBC
History        <Changed By>         <Date>      <Change Descirption>
------------------------------------------------------------*/
public inherited sharing abstract class RestCalloutBase {

    public final Integer HTTP_REQUEST_TIME_OUT = 120000;
    
    protected HttpRequest request;
    protected HttpResponse response;
    
    private String path;

    public RestCalloutBase(String httpMethod, String path) {
        this.path = path;
        request  = new HttpRequest();

        request.setMethod(httpMethod);
        //TODO: update named credential 
        request.setEndpoint('callout:TravelForceAPI/' + this.path);
        request.setTimeout(HTTP_REQUEST_TIME_OUT);
        //set common header values
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('DateTime', System.now().format('yyyy-MM-dd'));
    }

    public virtual HttpResponse send(String namedCredential, String restEndpoint, String requestBody) {
        if(requestBody==null) return null;
        
        Datetime sendingOn = Datetime.now();
        //Use feature flag to enable logging
        //Use feature flag to enable callout
        //Use feature flag to enable system debug log
        try {    
            if(String.isNotEmpty(namedCredential)) {
                request.setEndpoint(namedCredential);
            }if(String.isNotEmpty(restEndpoint)) {
                request.setEndpoint(namedCredential+restEndpoint);
            }
            if(String.isNotEmpty(requestBody)) {
                request.setBody(requestBody);
            }

            long startTime = DateTime.now().getTime();
            system.debug('Callout Request: ' + request);
            system.debug('Callout EndPoint: ' + request.getEndpoint());
            system.debug('Callout RequestBody: ' + requestBody);
            response = new http().send(request);
            system.debug('Callout Response: ' + response);
	 //ApplicationLogHelper.debugLog(request.toString());
	 //ApplicationLogHelper.debugLog(response.toString());
	 //ApplicationLogHelper.debugLog(response.getBody());

	    long endTime = DateTime.now().getTime();
	 /*ApplicationLogHelper.logCallout('Class',
					 'RestCalloutBase', 'send', '', '', 
					 'callout:HKT_Ruby_API/' + this.path,
					 'StatusCode: ' + response.getStatusCode(),
	 				  request.getBody(),
					  response.getBody(), 
					  endTime - startTime); */
        } catch(Exception ex) {
            //ApplicationLogHelper.logException('Class', 'RestCalloutBase', 'send', ex);
        }
        return response;
    }
	
}