@isTest
private class FileUploadControllerTest {

    @isTest
    static void testUploadFileToAPI_Success() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new FileUploadMockSuccess());

        // Test data
        String fileName = 'test.pdf';
        String fileBase64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String contentType = 'application/pdf';
        String recordId = 'a00XXXXXXXXXXXXXXX'; // Sample record ID

        Test.startTest();
        String result = FileUploadController.uploadFileToAPI(fileName, fileBase64, contentType, recordId);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('success'), 'Response should indicate success');
    }

    @isTest
    static void testUploadFileToAPI_Error() {
        // Set up mock response for error
        Test.setMock(HttpCalloutMock.class, new FileUploadMockError());

        String fileName = 'test.pdf';
        String fileBase64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String contentType = 'application/pdf';
        String recordId = 'a00XXXXXXXXXXXXXXX';

        Test.startTest();
        try {
            FileUploadController.uploadFileToAPI(fileName, fileBase64, contentType, recordId);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('API Error'), 'Should contain API Error message');
        }
        Test.stopTest();
    }

    // Mock class for successful HTTP response
    private class FileUploadMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "File uploaded successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock class for error HTTP response
    private class FileUploadMockError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "error", "message": "Invalid file"}');
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            return res;
        }
    }
}
