public with sharing class FileUploadController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchEvalDetails(String recordId) {
        try {
            // Configure your external API endpoint for fetching evaluation details
            String endpoint = 'https://4e9f-14-143-183-70.ngrok-free.app/eval/' + recordId;

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers
            req.setHeader('Content-Type', 'application/json');
            // Add any authentication headers if needed
            // req.setHeader('Authorization', 'Bearer YOUR_TOKEN');

            // Make the callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Process response
            if (res.getStatusCode() == 200) {
                // Parse and return the response
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return responseData;
            } else {
                throw new AuraHandledException('API Error: ' + res.getStatus() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error fetching evaluation details: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String uploadFileToAPI(String fileName, String fileBase64, String contentType, String recordId) {
        try {
            // Configure your external API endpoint here
            String endpoint = 'https://4e9f-14-143-183-70.ngrok-free.app/upload'; // REPLACE WITH YOUR ACTUAL ENDPOINT

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers
            req.setHeader('Content-Type', 'application/json');
            // Add any authentication headers if needed
            // req.setHeader('Authorization', 'Bearer YOUR_TOKEN');

            // Create request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'fileName' => fileName,
                'fileContent' => fileBase64,
                'contentType' => contentType,
                'recordId' => recordId
            };

            req.setBody(JSON.serialize(requestBody));

            // Make the callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Process response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                // Log success
                System.debug('File uploaded successfully: ' + fileName);
                return res.getBody();
            } else {
                throw new AuraHandledException('API Error: ' + res.getStatus() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error uploading file: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}
