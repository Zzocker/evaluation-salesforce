public with sharing class FileUploadController {

    @AuraEnabled
    public static Map<String, Object> fetchEvalDetails(String recordId) {
        Map<String, Object> candidateDocResp = fetchCandidateDoc(recordId);
        Map<String, Object> candidateData = (Map<String, Object>) candidateDocResp.get('data');
        String candidateDocId = (String) candidateData.get('id');
        Map<String, Object> documentsResp = fetchDocuments(candidateDocId);

        List<Object> documentList = (List<Object>) documentsResp.get('data');
        List<Object> newDocumentList = new List<Object>();


        for (Object docObj : documentList) {
            Map<String, Object> doc = (Map<String, Object>) docObj;
            String docId = (String) doc.get('id');
            Map<String, Object> docDetails = fetchDocumentById(docId);
            Object docData = docDetails.get('data');
            newDocumentList.add(docData);
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('candidateDoc', candidateDocResp.get('data'));
        result.put('documentList', newDocumentList);
        return result;
    }

    public static Map<String, Object> fetchCandidateDoc(String recordId) {
        try {
            // Configure your external API endpoint for fetching evaluation details
            String endpoint = 'https://eval-api.trential.dev/v1/eval/candidate-docs/698d78d10378e595d7be299f'; // + recordId;

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

    public static Map<String, Object> fetchDocumentById(String documentId) {
        try {
            // Configure your external API endpoint for fetching evaluation details
            String endpoint = 'https://eval-api.trential.dev/v1/eval/documents/' + documentId + '?responseType=complete-without-meta';

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
    public static Map<String, Object> uploadDocument(String fileName, String fileBase64, String contentType, String recordId) {
        Map<String, Object> uploadFileResp = uploadFile(fileName, fileBase64, contentType);
        Object fileData = uploadFileResp.get('data');
        Map<String, Object> sendDocForEvalResp = sendDocumentForEvaluation(fileData, recordId);
        return sendDocForEvalResp;
    }

    private static Map<String, Object> sendDocumentForEvaluation(Object fileData, String recordId) {
        try {
            // Configure your external API endpoint for creating evaluation document
            String endpoint = 'https://eval-api.trential.dev/v1/eval/documents';

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', 'api_test_8ae43865-28c1-4a46-81b7-f8421a640c74');

            // Create request body
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('files', fileData);
            requestBody.put('candidateIdentifier', recordId);

            req.setBody(JSON.serialize(requestBody));

            // Make the callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Process response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                // Parse and return the response
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return responseData;
            } else {
                throw new AuraHandledException('API Error: ' + res.getStatus() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error sending document for evaluation: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    private static Map<String, Object> uploadFile(String fileName, String fileBase64, String contentType) {
        try {
            // Configure your external API endpoint here
            String endpoint = 'https://eval-api.trential.dev/v1/file/files'; // REPLACE WITH YOUR ACTUAL ENDPOINT

            // Generate boundary for multipart/form-data
            String boundary = '----WebKitFormBoundary' + EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 16);

            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(120000); // 120 seconds timeout

            // Set headers for multipart/form-data
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            // Add any authentication headers if needed
            // req.setHeader('Authorization', 'Bearer YOUR_TOKEN');

            // Build multipart body
            Blob bodyBlob = buildMultipartBody(boundary, fileName, fileBase64, contentType);
            req.setBodyAsBlob(bodyBlob);
            req.setHeader('x-api-key', 'api_test_8ae43865-28c1-4a46-81b7-f8421a640c74');


            // Make the callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Process response
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                // Log success
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return responseData;
            } else {
                throw new AuraHandledException('API Error: ' + res.getStatus() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error uploading file: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    private static Blob buildMultipartBody(String boundary, String fileName, String fileBase64, String contentType) {
        String header = '--' + boundary + '\r\n';
        header += 'Content-Disposition: form-data; name="file"; filename="' + fileName + '"\r\n';
        header += 'Content-Type: ' + contentType + '\r\n\r\n';

        String footer = '\r\n--' + boundary + '--';

        // Decode the base64 file content
        Blob fileBlob = EncodingUtil.base64Decode(fileBase64);

        // Concatenate blobs using hex encoding (most reliable method in Apex)
        String hexHeader = EncodingUtil.convertToHex(Blob.valueOf(header));
        String hexFile = EncodingUtil.convertToHex(fileBlob);
        String hexFooter = EncodingUtil.convertToHex(Blob.valueOf(footer));

        return EncodingUtil.convertFromHex(hexHeader + hexFile + hexFooter);
    }
}
