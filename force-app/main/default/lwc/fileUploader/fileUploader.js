import { LightningElement, api } from 'lwc';
import uploadDocument from '@salesforce/apex/FileUploadController.uploadDocument';
import fetchEvalDetails from '@salesforce/apex/FileUploadController.fetchEvalDetails';

export default class FileUploader extends LightningElement {
    @api recordId; // Automatically gets the Student record ID when placed on record page

    // File upload properties
    fileData;
    fileName = '';
    fileSize = '';
    isUploading = false;
    successMessage = '';
    errorMessage = '';

    // Evaluation details properties
    evalDetails = null;
    isLoadingDetails = true;
    detailsError = '';

    // Load evaluation details when component is connected
    connectedCallback() {
        this.loadEvalDetails();
    }

    // Load evaluation details
    loadEvalDetails() {
        this.isLoadingDetails = true;
        this.detailsError = '';

        fetchEvalDetails({ recordId: this.recordId })
            .then(data => {
                this.evalDetails = data;
                this.detailsError = '';
            })
            .catch(error => {
                this.detailsError = error.body ? error.body.message : 'Error fetching evaluation details';
                this.evalDetails = null;
                console.error('Error fetching details:', error);
            })
            .finally(() => {
                this.isLoadingDetails = false;
            });
    }

    // Reload evaluation details
    handleReload() {
        this.loadEvalDetails();
    }

    get disableUpload() {
        return !this.fileData || this.isUploading;
    }

    // Candidate document getters
    get candidateDoc() {
        return this.evalDetails?.candidateDoc;
    }

    get candidateName() {
        const names = this.candidateDoc?.info?.names;
        if (names && names.length > 0) {
            return names[0].value;
        }
        return 'N/A';
    }

    get candidateDOB() {
        return this.candidateDoc?.info?.dateOfBirth || 'N/A';
    }

    get candidateEvalUrl() {
        const candidateId = this.candidateDoc?.id;
        return candidateId ? `https://eval.trential.dev/candidate/${candidateId}` : '#';
    }

    // Document list getters
    get documentList() {
        return this.evalDetails?.documentList || [];
    }

    get hasDocuments() {
        return this.documentList.length > 0;
    }

    get documentCount() {
        return this.documentList.length;
    }

    // Handle view file button click
    handleViewFile(event) {
        const fileUrl = event.target.dataset.url;
        if (fileUrl) {
            window.open(fileUrl, '_blank');
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            // Check file size (max 6MB for base64 encoding in Salesforce)
            const maxSize = 6 * 1024 * 1024;
            if (file.size > maxSize) {
                this.errorMessage = 'File size must be less than 6MB';
                this.fileData = null;
                this.fileName = '';
                this.fileSize = '';
                return;
            }

            this.fileName = file.name;
            this.fileSize = this.formatFileSize(file.size);
            this.errorMessage = '';
            this.successMessage = '';

            // Read file as base64
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                this.fileData = {
                    filename: file.name,
                    base64: base64,
                    contentType: file.type
                };
            };
            reader.onerror = () => {
                this.errorMessage = 'Error reading file';
                this.fileData = null;
            };
            reader.readAsDataURL(file);
        }
    }

    handleUpload() {
        if (!this.fileData) {
            this.errorMessage = 'Please select a file first';
            return;
        }

        this.isUploading = true;
        this.errorMessage = '';
        this.successMessage = '';

        uploadDocument({
            fileName: this.fileData.filename,
            fileBase64: this.fileData.base64,
            contentType: this.fileData.contentType,
            recordId: this.recordId
        })
            .then(result => {
                console.log('result = ', result)
                this.successMessage = `File uploaded successfully! Response: ${result}`;
                this.fileData = null;
                this.fileName = '';
                this.fileSize = '';
                // Reset file input
                const fileInput = this.template.querySelector('lightning-input[type="file"]');
                if (fileInput) {
                    fileInput.value = '';
                }
            })
            .catch(error => {
                this.errorMessage = error.body ? error.body.message : 'Error uploading file';
                console.error('Upload error:', error);
            })
            .finally(() => {
                this.isUploading = false;
            });
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }
}
