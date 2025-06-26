1. Go to Salesforce set up
2. Search for "External Client Apps" and Select Settings on the left hand side
3. Under External Client App Settings, Enable Allow creation of connected apps and click on New Connected App
![image](https://github.com/user-attachments/assets/fa341747-17c1-496e-8551-1d438694875d)

4. Name your Connected App, "CaerrierAPI App"
5. Enter a valid email for Connected App Email
6. Under API(Enable Oauth Settings), check Enable OAuth settings.
7. Enter Call back URL as "http://localhost:8081/callback".
8. Check Use Digital Signatures
9. Upload the certificate from Org A here by clicking Choose files.
![image](https://github.com/user-attachments/assets/5eefb8b0-1a8e-4f38-85c1-4375bf32bd01)

10. Under Selected OAuth scopes, select below options
![image](https://github.com/user-attachments/assets/5493a87a-4f8d-4672-851d-271ec94f6aeb)
     
11. Check Require Secret for web server flow, Require secret for refresh token refresh, Enable Client Credentials Flow, Enable Token Exchange flow, Require Secret for Token exchange flow and ENable refresh token rotation
12. Click Save. We are not done yet, We need to uodate policies for session token and also associate a user to connected app
13. Once you save click on Manage and under IP Relaxation, relax IP restrictions, otheroption is to update trusted sites with Org A domain name
14. Under Refresh token policy, select,"Refresh token is valid until revoked". This typically means the session will not end abruptly during callout.
15. Permitted user is Admin Approved users are pre-Authorized
16. Session policies is Timeout value of 24 hours.
![image](https://github.com/user-attachments/assets/645a5a82-6137-4e3c-8e89-8cddf93cf6f9)

17. Under Client Credentials Flow select the user that will perform teh integration. Preferably a system admin here as per assumption.
18. Under profiles, please select System Administrator
29. Click save
20. Copy the consumer key and secret that will be updated to Org A Named credentials.
![image](https://github.com/user-attachments/assets/2a44985c-1ded-413c-81ae-33a59361c513)

    
22. 
