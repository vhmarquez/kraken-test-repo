import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAllConfigs from '@salesforce/apex/KrakenDataTableController.getAllConfigs';
import deleteConfig from '@salesforce/apex/KrakenDataTableController.deleteConfig';

export default class KrakenConfigManager extends LightningElement {
    @track configs = [];
    @track error;
    @track showModal = false;
    @track wiredConfigsResult;
    @track editConfigId = '';
    @track editDisplayName = '';
    @track editObjectApiName = '';
    @track editSelectedFields = [];

    columns = [
        { label: 'Display Name', fieldName: 'DisplayName__c', type: 'text' },
        { label: 'Object', fieldName: 'ObjectApiName__c', type: 'text' },
        { label: 'Fields', fieldName: 'SelectedFields__c', type: 'text' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    @wire(getAllConfigs)
    wiredConfigs(result) {
        this.wiredConfigsResult = result;
        const { error, data } = result;
        if (data) {
            this.configs = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.configs = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load configurations: ' + this.error,
                    variant: 'error'
                })
            );
        }
    }

    openNewConfigModal() {
        this.editConfigId = '';
        this.editDisplayName = '';
        this.editObjectApiName = '';
        this.editSelectedFields = [];
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.editConfigId = '';
        this.editDisplayName = '';
        this.editObjectApiName = '';
        this.editSelectedFields = [];
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.editConfigId = row.Id;
            this.editDisplayName = row.DisplayName__c;
            this.editObjectApiName = row.ObjectApiName__c;
            this.editSelectedFields = row.SelectedFields__c ? row.SelectedFields__c.split(',').map(f => f.trim()) : [];
            this.showModal = true;
        } else if (actionName === 'delete') {
            if (confirm('Are you sure you want to delete this configuration?')) {
                deleteConfig({ configId: row.Id })
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Configuration deleted successfully',
                                variant: 'success'
                            })
                        );
                        return refreshApex(this.wiredConfigsResult);
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed to delete configuration: ' + (error.body ? error.body.message : error.message),
                                variant: 'error'
                            })
                        );
                    });
            }
        }
    }

    async handleSaveConfig() {
        this.showModal = false;
        this.editConfigId = '';
        this.editDisplayName = '';
        this.editObjectApiName = '';
        this.editSelectedFields = [];
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Configuration saved successfully',
                variant: 'success'
            })
        );
        try {
            await refreshApex(this.wiredConfigsResult);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to refresh configurations: ' + (error.body ? error.body.message : error.message),
                    variant: 'error'
                })
            );
        }
    }
}