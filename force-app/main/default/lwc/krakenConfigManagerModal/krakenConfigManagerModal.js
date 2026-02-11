import { LightningElement, api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFieldOptions from '@salesforce/apex/KrakenDataTableController.getFieldOptions';
import getObjectOptions from '@salesforce/apex/KrakenDataTableController.getObjectOptions';
import saveConfig from '@salesforce/apex/KrakenDataTableController.saveConfig';
import updateConfig from '@salesforce/apex/KrakenDataTableController.updateConfig';

export default class KrakenConfigManagerModal extends LightningModal {
    @api configId = '';
    @api displayName = '';
    @api objectApiName = '';
    @api selectedFields = [];

    @track localDisplayName = '';
    @track localObjectApiName = '';
    @track localSelectedFields = [];
    @track objectOptions = [];
    @track fieldOptions = [];
    @track error;

    get modalTitle() {
        return this.configId ? 'Edit Configuration' : 'New Configuration';
    }

    connectedCallback() {
        this.localDisplayName = this.displayName;
        this.localObjectApiName = this.objectApiName;
        this.localSelectedFields = Array.isArray(this.selectedFields) ? this.selectedFields : this.selectedFields ? this.selectedFields.split(',').map(f => f.trim()) : [];
    }

    @wire(getObjectOptions)
    wiredObjectOptions({ error, data }) {
        if (data) {
            this.objectOptions = data.map(obj => ({
                label: obj.label,
                value: obj.value
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.objectOptions = [];
            console.error('Error fetching object options:', error);
        }
    }

    @wire(getFieldOptions, { objectName: '$localObjectApiName' })
    wiredFieldOptions({ error, data }) {
        if (data) {
            this.fieldOptions = data.map(field => ({
                label: field.label,
                value: field.value
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.fieldOptions = [];
            console.error('Error fetching field options:', error);
        }
    }

    handleDisplayNameChange(event) {
        this.localDisplayName = event.target.value;
    }

    handleObjectChange(event) {
        this.localObjectApiName = event.target.value;
        this.localSelectedFields = []; // Reset fields when object changes
    }

    handleFieldChange(event) {
        this.localSelectedFields = event.detail.value;
    }

    handleSave() {
        if (!this.localDisplayName || !this.localObjectApiName || this.localSelectedFields.length === 0) {
            this.error = 'All fields are required.';
            return;
        }

        const savePromise = this.configId
            ? updateConfig({
                  configId: this.configId,
                  displayName: this.localDisplayName,
                  objectName: this.localObjectApiName,
                  selectedFields: this.localSelectedFields.join(',')
              })
            : saveConfig({
                  displayName: this.localDisplayName,
                  objectName: this.localObjectApiName,
                  selectedFields: this.localSelectedFields.join(',')
              });

        savePromise
            .then(() => {
                this.dispatchEvent(new CustomEvent('save'));
                this.close();
            })
            .catch(error => {
                this.error = error.body ? error.body.message : error.message;
                console.error('Error saving configuration:', error);
            });
    }

    handleCancel() {
        this.close();
    }
}