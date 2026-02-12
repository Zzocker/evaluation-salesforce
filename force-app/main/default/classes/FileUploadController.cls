public with sharing class FileUploadController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchEvalDetails(String recordId) {
        Map<String, Object> candidateDocResp = fetchCandidateDoc(recordId);
        Map<String, Object> candidateData = (Map<String, Object>) candidateDocResp.get('data');
        String candidateDocId = (String) candidateData.get('id');
        Map<String, Object> documentsResp = fetchDocuments(candidateDocId);

        Map<String, Object> result = new Map<String, Object>();
        result.put('candidateDoc', candidateDocResp.get('data'));
        result.put('documentList', documentsResp.get('data'));
        return result;
    }

    public static Map<String, Object> fetchCandidateDoc(String recordId) {
        try {
            // Configure your external API endpoint for fetching evaluation details
            String endpoint = 'https://eval-api.trential.dev/v1/eval/candidate-docs/6944ec4452b670a75d904425'; // + recordId;

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', 'api_test_8ae43865-28c1-4a46-81b7-f8421a640c74');

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

    public static Map<String, Object> fetchDocuments(String candidateDocsId) {
        try {
            // Configure your external API endpoint for fetching evaluation details
            String endpoint = 'https://eval-api.trential.dev/v1/eval/documents?limit=100&candidateDocsId=' + candidateDocsId;

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', 'api_test_8ae43865-28c1-4a46-81b7-f8421a640c74');

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
