# File Upload LWC Setup Guide

This guide will help you deploy and configure the File Upload Lightning Web Component for the Student custom object.

## Components Created

1. **Lightning Web Component**: `fileUploader`
   - HTML template with file input and upload UI
   - JavaScript controller for file handling
   - Meta XML configuration for Student__c object

2. **Apex Class**: `FileUploadController`
   - Handles HTTP callouts to external API
   - Processes file data and API responses

3. **Test Class**: `FileUploadControllerTest`
   - Provides test coverage for the Apex controller

## Setup Steps

### 1. Configure External API Endpoint

Edit the file: `force-app/main/default/classes/FileUploadController.cls`

Update line 6 with your actual API endpoint:
```apex
String endpoint = 'https://your-api-endpoint.com/upload'; // REPLACE WITH YOUR ACTUAL ENDPOINT
```

If your API requires authentication, uncomment and update line 14:
```apex
req.setHeader('Authorization', 'Bearer YOUR_TOKEN');
```

### 2. Configure Remote Site Settings

Before you can make HTTP callouts to external APIs, you must add the API domain to Salesforce Remote Site Settings:

1. In Salesforce Setup, search for **Remote Site Settings**
2. Click **New Remote Site**
3. Fill in the details:
   - **Remote Site Name**: `External_File_Upload_API` (or any name you prefer)
   - **Remote Site URL**: `https://your-api-endpoint.com` (your API's base URL)
   - **Active**: Checked
4. Click **Save**

### 3. Deploy to Salesforce

Deploy all components to your Salesforce org:

```bash
sf project deploy start --source-dir force-app/main/default
```

Or deploy specific components:
```bash
sf project deploy start --source-dir force-app/main/default/lwc/fileUploader
sf project deploy start --source-dir force-app/main/default/classes
```

### 4. Add Component to Student Record Page

1. Navigate to a **Student record** in Salesforce
2. Click the **gear icon** (⚙️) in the top right
3. Select **Edit Page**
4. In the Lightning App Builder:
   - Find **fileUploader** in the custom components list (left sidebar)
   - Drag it to the desired section on the record page (typically in the main content area or a tab)
   - Adjust the component size and placement as needed
5. Click **Save**
6. Click **Activate** (if this is a new page layout)
   - Choose activation options (Org Default, App/Record Type, etc.)
7. Click **Save** again

### 5. Test the Component

1. Navigate to a Student record
2. You should see the "File Upload" component
3. Click **Choose File** and select a file (max 6MB)
4. Click **Upload & Send to API**
5. The component will:
   - Show a loading spinner
   - Send the file to your external API
   - Display success or error message

## File Constraints

- **Maximum file size**: 6MB (Salesforce base64 encoding limitation)
- **Accepted formats**: Configured in HTML template (currently: .pdf, .doc, .docx, .txt, .jpg, .png)
- To modify accepted formats, edit `fileUploader.html` line 7

## API Request Format

The Apex controller sends a JSON request to your API with this structure:

```json
{
  "fileName": "example.pdf",
  "fileContent": "base64EncodedFileContent",
  "contentType": "application/pdf",
  "recordId": "a00XXXXXXXXXXXXXXX"
}
```

Ensure your external API can handle this format, or modify the `FileUploadController.cls` accordingly.

## Customization Options

### Change Accepted File Types

Edit `fileUploader.html` line 7:
```html
accept=".pdf,.doc,.docx,.txt,.jpg,.png,.csv,.xlsx"
```

### Adjust Timeout

Edit `FileUploadController.cls` line 11:
```apex
req.setTimeout(120000); // 120 seconds (max allowed by Salesforce)
```

### Customize API Request Body

Edit `FileUploadController.cls` lines 18-23 to match your API's expected format:
```apex
Map<String, Object> requestBody = new Map<String, Object>{
    'fileName' => fileName,
    'fileContent' => fileBase64,
    'contentType' => contentType,
    'recordId' => recordId,
    'customField' => 'customValue' // Add your custom fields
};
```

## Troubleshooting

### "Unauthorized endpoint" error
- Make sure you've added the API endpoint to Remote Site Settings
- The URL in Remote Site Settings must match the protocol (http/https) and domain

### "Timeout" errors
- Check if your API responds within 120 seconds
- Consider implementing asynchronous processing for large files

### Component not visible on record page
- Verify the component is configured for `Student__c` object in `fileUploader.js-meta.xml`
- Check that the component is added to the page layout
- Ensure proper permissions for the user profile

### File size errors
- Files larger than 6MB cannot be processed due to Salesforce governor limits
- Consider implementing chunked file upload for larger files

## Running Tests

Run the test class to verify the Apex controller:

```bash
sf apex run test --test-level RunSpecifiedTests --tests FileUploadControllerTest --result-format human
```

## Security Considerations

1. **Authentication**: Implement proper API authentication (Bearer token, API key, OAuth)
2. **File Validation**: Add server-side validation for file types and content
3. **Error Handling**: Avoid exposing sensitive error details to end users
4. **Field-Level Security**: Ensure proper permissions on Student__c object
5. **Named Credentials**: For production, consider using Named Credentials instead of hardcoded endpoints

## Next Steps

- Implement Named Credentials for better security
- Add file type validation on the server side
- Create a custom object to log file upload history
- Add email notifications for successful/failed uploads
- Implement retry logic for failed API calls
