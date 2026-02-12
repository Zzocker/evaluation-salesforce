import { LightningElement, api, wire } from 'lwc';
import uploadFileToAPI from '@salesforce/apex/FileUploadController.uploadFileToAPI';
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

    // Wire service to fetch evaluation details
    @wire(fetchEvalDetails, { recordId: '$recordId' })
    wiredEvalDetails({ error, data }) {
        this.isLoadingDetails = false;
        if (data) {
            this.evalDetails = data;
            this.detailsError = '';
        } else if (error) {
            this.detailsError = error.body ? error.body.message : 'Error fetching evaluation details';
            this.evalDetails = null;
            console.error('Error fetching details:', error);
        }
    }

    get disableUpload() {
        return !this.fileData || this.isUploading;
    }

    get formattedEvalDetails() {
        if (!this.evalDetails) return [];
        return Object.keys(this.evalDetails).map(key => ({
            key: key.charAt(0).toUpperCase() + key.slice(1).replace(/([A-Z])/g, ' $1'),
            value: this.evalDetails[key]
        }));
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

        uploadFileToAPI({
            fileName: this.fileData.filename,
            fileBase64: this.fileData.base64,
            contentType: this.fileData.contentType,
            recordId: this.recordId
        })
            .then(result => {
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
