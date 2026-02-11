import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTreeData from '@salesforce/apex/ESCCDeviceController.getTreeData';
import getTotalCount from '@salesforce/apex/ESCCDeviceController.getTotalCount';
import getCSVData from '@salesforce/apex/ESCCDeviceController.getCSVData';

export default class EsccDeviceTreeGrid extends NavigationMixin(LightningElement) {
    @track treeData = [];
    @track selectedViews = new Set();
    @track pageSize = 10;
    @track currentPage = 1;
    @track totalRecords = 0;
    @track isLoading = false;

    viewDisplayContacts = 'Display Contacts';
    viewEISAC = 'E-ISAC';
    viewMyOrg = 'My Org';
    viewMine = 'Mine';
    
    pageSizeOptions = [
        { label: '10', value: 10 },
        { label: '25', value: 25 },
        { label: '50', value: 50 }
    ];
    
    columns = [
        { label: 'Organization / Contact Name', fieldName: 'name', type: 'text', sortable: true },
        { label: 'Title', fieldName: 'title', type: 'text', sortable: true },
        { label: 'Device Level', fieldName: 'deviceLevel', type: 'text', sortable: true },
        { label: 'Device Type', fieldName: 'deviceType', type: 'text', sortable: true },
        { label: 'Device Number', fieldName: 'deviceNumber', type: 'phone', sortable: true },
        {
            type: 'action',
            typeAttributes: { rowActions: [
                { label: 'View', name: 'view' },
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ] }
        }
    ];
    
    get selectedViewsArray() {
        return Array.from(this.selectedViews);
    }
    
    get variantDisplayContacts() {
        return this.selectedViews.has(this.viewDisplayContacts) ? 'brand' : 'neutral';
    }
    
    get variantEISAC() {
        return this.selectedViews.has(this.viewEISAC) ? 'brand' : 'neutral';
    }
    
    get variantMyOrg() {
        return this.selectedViews.has(this.viewMyOrg) ? 'brand' : 'neutral';
    }
    
    get variantMine() {
        return this.selectedViews.has(this.viewMine) ? 'brand' : 'neutral';
    }
    
    get offset() {
        return (this.currentPage - 1) * this.pageSize;
    }
    
    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }
    
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }
    
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }
    
    get currentRowCount() {
        if (!this.treeData) return 0;
        return this.treeData.reduce((acc, parent) => acc + (parent._children ? parent._children.length : 0), 0);
    }
    
    get rowRange() {
        const start = this.offset + 1;
        const end = Math.min(this.offset + this.currentRowCount, this.totalRecords);
        return `${start}-${end} of ${this.totalRecords}`;
    }
    
    get pageInfo() {
        return `${this.currentPage} of ${this.totalPages}`;
    }
    
    @wire(getTotalCount, { viewFilters: '$selectedViewsArray' })
    wiredTotalCount({ error, data }) {
        if (data) {
            this.totalRecords = data;
        } else if (error) {
            // Handle error
        }
    }
    
    @wire(getTreeData, { viewFilters: '$selectedViewsArray', limitSize: '$pageSize', offset: '$offset' })
    wiredTreeData({ error, data }) {
        if (data) {
            this.treeData = data.map(parent => ({
                ...parent,
                _children: parent.children || []
            }));
        } else if (error) {
            // Handle error
        }
    }
    
    handleViewChange(event) {
        const view = event.target.dataset.view;
        if (this.selectedViews.has(view)) {
            this.selectedViews.delete(view);
        } else {
            this.selectedViews.add(view);
        }
        this.selectedViews = new Set(this.selectedViews); // Trigger reactivity
        this.currentPage = 1;
    }
    
    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.currentPage = 1;
    }
    
    handlePrevious() {
        if (!this.isPreviousDisabled) this.currentPage--;
    }
    
    handleNext() {
        if (!this.isNextDisabled) this.currentPage++;
    }
    
    handleAddNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Resilient_Communication_Device__c',
                actionName: 'new'
            }
        });
    }
    
    async handleExport() {
        this.isLoading = true;
        try {
            const csv = await getCSVData({ viewFilters: this.selectedViewsArray });
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'resilient_devices.csv';
            a.click();
            URL.revokeObjectURL(url);
        } catch (error) {
            // Handle error
        } finally {
            this.isLoading = false;
        }
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (!row._children) { // Actions on children only
            switch (actionName) {
                case 'view':
                case 'edit':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.id,
                            objectApiName: 'Resilient_Communication_Device__c',
                            actionName: actionName
                        }
                    });
                    break;
                case 'delete':
                    // Implement delete logic, e.g., imperative Apex call
                    break;
            }
        }
    }
}