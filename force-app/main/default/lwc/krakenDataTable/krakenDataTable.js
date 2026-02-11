import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/KrakenDataTableController.getRecords';
import updateRecords from '@salesforce/apex/KrakenDataTableController.updateRecords';
import getConfig from '@salesforce/apex/KrakenDataTableController.getConfig';

export default class KrakenDataTable extends NavigationMixin(LightningElement) {
    @api configId;
    @api editable = false;
    @api showActions = false;
    @api pageSize = 10;

    @track objectApiName;
    @track fields;
    @track columns = [];
    @track data = [];
    @track filteredData = [];
    @track error;
    @track sortedBy = 'Id';
    @track sortedDirection = 'asc';
    @track currentPage = 1;
    @track totalRecords = 0;
    @track totalPages = 1;
    @track searchTerm = '';
    @track draftValues = [];
    @track hasColumns = false;

    wiredResult;
    wiredObjectInfoResult;

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get normalizedConfigId() {
        try {
            if (!this.configId) {
                console.warn('configId is null or undefined');
                return '';
            }
            if (typeof this.configId === 'string' && this.configId.match(/^[a-zA-Z0-9]{15,18}$/)) {
                return this.configId;
            }
            if (Array.isArray(this.configId) && this.configId.length > 0) {
                const firstItem = this.configId[0];
                if (typeof firstItem === 'string' && firstItem.match(/^[a-zA-Z0-9]{15,18}$/)) {
                    return firstItem;
                }
                if (firstItem && typeof firstItem === 'object' && firstItem.value && typeof firstItem.value === 'string' && firstItem.value.match(/^[a-zA-Z0-9]{15,18}$/)) {
                    return firstItem.value;
                }
            }
            if (typeof this.configId === 'object' && this.configId.value && typeof this.configId.value === 'string' && this.configId.value.match(/^[a-zA-Z0-9]{15,18}$/)) {
                return this.configId.value;
            }
            // Handle JSON string case
            if (typeof this.configId === 'string') {
                try {
                    const parsed = JSON.parse(this.configId);
                    if (Array.isArray(parsed) && parsed.length > 0 && parsed[0].value && typeof parsed[0].value === 'string' && parsed[0].value.match(/^[a-zA-Z0-9]{15,18}$/)) {
                        return parsed[0].value;
                    }
                    if (typeof parsed === 'object' && parsed.value && typeof parsed.value === 'string' && parsed.value.match(/^[a-zA-Z0-9]{15,18}$/)) {
                        return parsed.value;
                    }
                } catch (e) {
                    // Not a valid JSON string
                }
            }
            console.warn('Unexpected configId format:', JSON.stringify(this.configId));
            return '';
        } catch (e) {
            console.error('Error normalizing configId:', e, 'Raw configId:', JSON.stringify(this.configId));
            return '';
        }
    }

    connectedCallback() {
        console.log('krakenDataTable configId (raw):', JSON.stringify(this.configId));
        console.log('krakenDataTable normalizedConfigId:', this.normalizedConfigId);
    }

    @wire(getConfig, { configId: '$normalizedConfigId' })
    wiredConfig({ error, data }) {
        if (data) {
            this.objectApiName = data.ObjectApiName__c;
            this.fields = data.SelectedFields__c;
            this.error = undefined;
            console.log('getConfig success:', JSON.stringify(data));
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.objectApiName = null;
            this.fields = null;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load configuration: ' + this.error,
                    variant: 'error'
                })
            );
            console.error('getConfig error:', JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo(result) {
        this.wiredObjectInfoResult = result;
        const { error, data } = result;
        if (data) {
            this.buildColumns(data);
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load object info: ' + this.error,
                    variant: 'error'
                })
            );
            console.error('getObjectInfo error:', JSON.stringify(error));
        }
    }

    @wire(getRecords, {
        objectName: '$objectApiName',
        fieldList: '$fields',
        sortBy: '$sortedBy',
        sortDirection: '$sortedDirection',
        pageNumber: '$currentPage',
        pageSize: '$pageSize'
    })
    wiredRecords(result) {
        this.wiredResult = result;
        const { error, data } = result;
        if (data) {
            this.data = data.records;
            this.totalRecords = data.totalRecords;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.applyFilter();
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.data = [];
            this.filteredData = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load records: ' + this.error,
                    variant: 'error'
                })
            );
            console.error('getRecords error:', JSON.stringify(error));
        }
    }

    buildColumns(objectInfo) {
        if (!this.fields) return;
        const fieldList = this.fields.split(',').map(f => f.trim());
        this.columns = fieldList.map(field => {
            const fieldInfo = objectInfo.fields[field];
            if (!fieldInfo) return null;
            const type = this.mapToDatatableType(fieldInfo.dataType);
            return {
                label: fieldInfo.label,
                fieldName: field,
                type,
                typeAttributes: this.getTypeAttributes(type, fieldInfo),
                editable: this.editable && fieldInfo.updateable,
                sortable: true
            };
        }).filter(c => c);
        if (this.showActions) {
            this.columns.push({
                type: 'action',
                typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] }
            });
        }
        this.hasColumns = this.columns.length > 0;
    }

    mapToDatatableType(dataType) {
        switch (dataType) {
            case 'String':
            case 'TextArea':
            case 'Picklist':
            case 'Multipicklist':
                return 'text';
            case 'Boolean':
                return 'boolean';
            case 'Currency':
                return 'currency';
            case 'Date':
                return 'date-local';
            case 'Datetime':
                return 'date';
            case 'Double':
            case 'Int':
            case 'Long':
                return 'number';
            case 'Percent':
                return 'percent';
            case 'Phone':
                return 'phone';
            case 'Email':
                return 'email';
            case 'Url':
                return 'url';
            default:
                return 'text';
        }
    }

    getTypeAttributes(type, fieldInfo) {
        switch (type) {
            case 'currency':
                return { step: '0.01', currencyCode: 'USD' };
            case 'date':
            case 'date-local':
                return {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    timeZone: 'UTC'
                };
            case 'number':
                return { step: fieldInfo.scale > 0 ? '0.' + '1'.padStart(fieldInfo.scale, '0') : '1' };
            case 'percent':
                return { step: '0.01', minimumFractionDigits: 0, maximumFractionDigits: 2 };
            default:
                return {};
        }
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.currentPage = 1;
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.applyFilter();
    }

    applyFilter() {
        if (!this.data) return;
        if (this.searchTerm === '') {
            this.filteredData = [...this.data];
        } else {
            this.filteredData = this.data.filter(row => {
                return Object.keys(row).some(key => {
                    if (key !== 'Id' && row[key] != null) {
                        return String(row[key]).toLowerCase().includes(this.searchTerm);
                    }
                    return false;
                });
            });
        }
    }

    handleSave(event) {
        const draftValues = event.detail.draftValues;
        updateRecords({ objectName: this.objectApiName, records: draftValues })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated successfully',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    actionName: 'view'
                }
            });
        }
    }
}